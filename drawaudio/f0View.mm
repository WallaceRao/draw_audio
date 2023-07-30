//
//  f0View.m
//  drawaudio
//
//  Created by Yonghui Rao on 2023/7/3.
//

#import "f0View.h"

@implementation f0View


static NSColor *bg_color = [NSColor lightGrayColor] ;

static float total_duration;
static float start_ts;
static float end_ts;
static bool in_mouse_drag = FALSE;

static bool audio_loaded = FALSE;
static std::vector<float> f0_samples;

static size_t start_sample_index = 0;
static size_t end_sample_index = 0;
static std::vector<NSPoint> sample_points_pos;

static size_t selected_sample_index = 0;
static bool selected = false;
static int point_size = 5;

int min_pitch = 0;
int max_pitch = 0;
- (void)drawRect:(NSRect)dirtyRect {
    // set any NSColor for filling, say white:
    [[NSColor lightGrayColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
    
    [[NSColor systemBlueColor] set];
    size_t sample_count = f0_samples.size();
    start_sample_index = start_ts / total_duration * sample_count;
    end_sample_index = end_ts / total_duration * sample_count;
    size_t show_sample_count = end_sample_index - start_sample_index;
    int step = show_sample_count / 100000;
    if (step < 1) {
        step = 1;
    }
    sample_points_pos.clear();
    point_size = 5;
    if (show_sample_count < 30) {
        point_size = 8;
    }
    for (size_t i = start_sample_index; i < end_sample_index; i = i + step) {
        if (i >= sample_count) {
            break;
        }
        NSRect drawingRect = NSZeroRect;
        float sample = f0_samples[i];
        if (sample > 256) {
            sample = 256;
        }
        if (sample < 0) {
            sample = 0;
        }
        drawingRect.origin.x = [self bounds].origin.x + point_size +  ([self bounds].size.width - 2 * point_size)*  ((i - start_sample_index)/(show_sample_count - 1.0)) - point_size/2;
        drawingRect.origin.y = [self bounds].origin.y + point_size +  ([self bounds].size.height - 2 * point_size)  * ((sample)/(256)) - point_size/2;
        drawingRect.size.width = point_size + 3; //[self bounds].size.width/sample_count;
        drawingRect.size.height = point_size; //[self bounds].size.height * sample;
        sample_points_pos.push_back(drawingRect.origin);
        NSRectFill(drawingRect);
    }
}


-(bool)getSelectSampleIndex:(NSPoint)mouse_point {
    // find the nearest point
    int nearest_index = 0;
    float x_min_distance = 10000000;
    if (sample_points_pos.empty()) {
        return false;
    }
    for (int i = 0; i < sample_points_pos.size(); i ++) {
        float x = sample_points_pos[i].x;
        float distance = (x + point_size/2 - mouse_point.x) *  (x + point_size/2 - mouse_point.x);
        if (x_min_distance > distance) {
            x_min_distance = distance;
            nearest_index = i;
        }
    }
    if (x_min_distance > point_size * point_size) {
        // too far
        return false;
    }
    float y_distance = (sample_points_pos[nearest_index].y - mouse_point.y) *  (sample_points_pos[nearest_index].y - mouse_point.y);
    if (y_distance > point_size * point_size) {
        // too far
        return false;
    }
    selected_sample_index = nearest_index + start_sample_index;
    NSLog(@"get selected index: %d", selected_sample_index);
    return true;
}


- (void)mouseDown:(NSEvent *)theEvent {
    return;
    bg_color = [NSColor darkGrayColor];
    in_mouse_drag = TRUE;
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    
    NSLog(@"Mouse down location: %f %f", local_point.x, local_point.y);
    selected = [self getSelectSampleIndex:local_point];
    in_mouse_drag = selected;
    
    //mouse_drag_start = local_point.x;
    //mouse_drag_cur = 0;
    //mouse_drag_end = 0;
    //[self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    if(in_mouse_drag) {
       // return;
    }
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    [self updateToolTip:local_point];
    return;
    NSLog(@"Mouse move location: %f %f", local_point.x, local_point.y);
    selected = [self getSelectSampleIndex:local_point];
    if (selected) {
        [self setToolTip:[NSString stringWithFormat:@"%f", f0_samples[selected_sample_index]]];
        NSLog(@"set tootip:%f, focus view %@",  f0_samples[selected_sample_index], [[self window] firstResponder]);
    } else {
        [self setToolTip:[NSString stringWithFormat:@""]];
        NSLog(@"clear tooltip, %@", [[self window] firstResponder]);

    }
}


- (void)updateToolTip:(NSPoint) local_point {
    selected = [self getSelectSampleIndex:local_point];
    if (selected) {
        [[self window] makeFirstResponder:[self track_view]];
        [self setToolTip:[NSString stringWithFormat:@"%f", f0_samples[selected_sample_index]]];
        NSLog(@"set tootip:%f, focus view %@",  f0_samples[selected_sample_index], [[self window] firstResponder]);
    } else {
        //[self setToolTip:[NSString stringWithFormat:@""]];
        //NSLog(@"clear tooltip, %@", [[self window] firstResponder]);
        
    }
    [self setNeedsDisplay:YES];
    
    
}


- (void)mouseDragged:(NSEvent *)theEvent {
    if(!in_mouse_drag) {
        return;
    }
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    if (selected) {
        float total_height = ([self bounds].size.height - 2 * point_size);
        f0_samples[selected_sample_index] = local_point.y / total_height * 256;
        [self setNeedsDisplay:YES];
    }
    [self updateToolTip:local_point];
    return;
    //if (local_point.x <= mouse_drag_start) {
    //    mouse_drag_cur = mouse_drag_start;
    //    return;
    //}
    //mouse_drag_cur =  local_point.x;
    // NSLog(@"Mouse location: %f %f", mouseLoc.x, mouseLoc.y);
    
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (!in_mouse_drag) {
        return;
    }
    bg_color = [NSColor lightGrayColor];
    in_mouse_drag = FALSE;
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    NSLog(@"Mouse up location: %f %f", local_point.x, local_point.y);
    selected = false;
    /*
    mouse_drag_end = local_point.x;
    // calculate start and end ts
    play_start_pos = mouse_drag_start;
    float start = [self getTimePointFromPos:mouse_drag_start];
    float end = [self getTimePointFromPos:mouse_drag_end];
    
    if (![self selectDuration:start :end]) {
        play_start_pos = mouse_drag_start;
        show_play_start_pos = true;
    } else {
        show_play_start_pos = FALSE;
    }
    [self setNeedsDisplay:YES];
     */
    //[[self window] makeFirstResponder:[[self window] contentView]];
  
}

- (void)updateTrackingAreas {
    [self initTrackingArea];
}

-(void) initTrackingArea {
    NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                     NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
    
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                        options:options
                                                          owner:self
                                                       userInfo:nil];
    
    [self addTrackingArea:area];
}



-(bool)init:(std::vector<float>)f0_vec total_dur:(float) dur {
    f0_samples = f0_vec;
    total_duration = dur;
    start_ts = 0;
    end_ts = total_duration;
    [self setNeedsDisplay:YES];
    
    return true;
}


-(bool)select_dur:(float) start_ts_sec end:(float) end_ts_sec {
    start_ts = start_ts_sec;
    end_ts = end_ts_sec;
    [self setNeedsDisplay:YES];
    return true;
}
@end
