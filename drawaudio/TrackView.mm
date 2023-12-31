//
//  TrackView.m
//  drawaudio
//
//  Created by Yonghui Rao on 2023/6/12.
//

#import "TrackView.h"
#import "libresample/resample_util.h"
#import "opus_util.h"

@implementation TrackView


WAV origin_wav;

NSColor *bg_color = [NSColor lightGrayColor] ;

float total_duration;
float start_ts;
float end_ts;
bool in_mouse_drag = FALSE;

float mouse_drag_start = 0;
float mouse_drag_end = 0;
float mouse_drag_cur = 0;

float play_start_pos = 0;
int play_start_index  = 0;
bool show_play_start_pos = FALSE;
bool refresh_points = TRUE;

bool audio_loaded = FALSE;

std::vector<int16_t> samples;

-(int) getPlayStartIndex {
    if (play_start_pos <= 0) {
        return 0;
    }
    float width =  [self bounds].size.width;
    float ratio  = play_start_pos * 1.0 / width;
    if (ratio >= 1) {
        return samples.size() -1;
    }
    return ratio * samples.size();
}

-(float)getTsStart {
    return start_ts;
}

-(float)getTsEnd {
    return end_ts;
}

-(float)getTotalDuration {
    return total_duration;
}


- (void)drawRect:(NSRect)dirtyRect {
    // set any NSColor for filling, say white:

    [[NSColor lightGrayColor] setFill];
    NSRectFill(dirtyRect);
    //[super drawRect:dirtyRect];

    if (in_mouse_drag) {
        [[NSColor darkGrayColor]  setFill];
        NSRect select_rect = dirtyRect;
        select_rect.origin.x = mouse_drag_start;
        select_rect.size.width = mouse_drag_cur - mouse_drag_start;
        NSRectFill(select_rect);
        NSLog(@"in mouse drag, width = %f", select_rect.size.width);
    }
    
    [[NSColor yellowColor] set];
    size_t sample_count = samples.size();
    size_t start_sample_index = start_ts / total_duration * sample_count;
    size_t end_sample_index = end_ts / total_duration * sample_count;
    size_t show_sample_count = end_sample_index - start_sample_index;
    int step = show_sample_count / 100000;
    if (step < 1) {
        step = 1;
    }
    for (size_t i = start_sample_index; i < end_sample_index; i = i + step) {
        if (i >= sample_count) {
            break;
        }
        NSRect drawingRect = NSZeroRect;
        int16_t sample = samples[i];
        drawingRect.origin.x = [self bounds].origin.x +  [self bounds].size.width *  ((i - start_sample_index)/(show_sample_count - 1.0));
        drawingRect.origin.y = [self bounds].origin.y +  [self bounds].size.height / 2 +  [self bounds].size.height / 2 * ((sample)/(32768 - 1.0)) ;
        drawingRect.size.width = 1; //[self bounds].size.width/sample_count;
        drawingRect.size.height = 1; //[self bounds].size.height * sample;
        NSRectFill(drawingRect);
    }
    bool hide = FALSE;
    float show_dur = end_ts - start_ts;
    float time_step = show_dur / 12.0;
    float label_text = start_ts;
    if (sample_count <= 0 ) {
        label_text = 0;
        label_text = 0;
        start_ts = 0;
        
    }
    label_text = start_ts;
    [[self l1] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l2] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l3] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l4] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l5] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l6] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l7] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l8] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l9] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l10] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l11] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l12] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    [[self l13] setStringValue: [NSString stringWithFormat:@"%.2f", label_text]];
    label_text += time_step;
    /*
    [[self l1] setHidden:hide];
    [[self l2] setHidden:hide];
    [[self l3] setHidden:hide];
    [[self l4] setHidden:hide];
    [[self l5] setHidden:hide];
    [[self l6] setHidden:hide];
    [[self l7] setHidden:hide];
    [[self l8] setHidden:hide];
    [[self l9] setHidden:hide];
    [[self l10] setHidden:hide];
    [[self l11] setHidden:hide];
    [[self l12] setHidden:hide];
    [[self l13] setHidden:hide];
     */
    if (show_play_start_pos) {
        [[NSColor redColor] set];
        NSRect drawingRect = NSZeroRect;
        drawingRect.origin.x = play_start_pos;
        drawingRect.origin.y = 0 ;
        drawingRect.size.width = 1; //[self bounds].size.width/sample_count;
        drawingRect.size.height =  [self bounds].size.height; //[self bounds].size.height * sample;
        NSRectFill(drawingRect);
    } else {
        play_start_pos = 0;
    }
    // Drawing code here.
}

-(bool)init:(NSURL *)url {
    const char *path = [[url path] UTF8String];
    //path = "/Users/yonghuirao/Desktop/test_wave.wav";
    origin_wav.Read(path);
    [self setNeedsDisplay:YES];
    total_duration = origin_wav.getSampleCount() * 1.0 / origin_wav.getSampleRate();
    start_ts = 0;
    end_ts = total_duration;
    audio_loaded = true;
    std::vector<int16_t> tmp_samples;
    for (size_t i = 0; i < origin_wav.getSampleCount(); i = i + 1) {
        int16_t sample = *((int16_t *)origin_wav.getData() + i);
        tmp_samples.push_back(sample);
    }
    ResampleUtil util;
    int target_sr = 24000;
    if (origin_wav.getSampleRate() != target_sr) {
        NSLog(@"resample from %d to %d", origin_wav.getSampleRate() ,target_sr);
        util.Init(origin_wav.getSampleRate(), target_sr);
        util.Resample(tmp_samples, samples, true);
        NSLog(@"resample finished %d to %d, sample size from %d to %d", origin_wav.getSampleRate() ,target_sr, tmp_samples.size(),samples.size());
    } else {
        tmp_samples.swap(samples);
    }
    std::vector<char> opus_data;
    Wav2Opus(samples, opus_data);
    return true;
}

-(bool)zoomIn {
    if(!audio_loaded) {
        return false;
    }
    float cur_dur = end_ts - start_ts;
    
    float start = start_ts +  cur_dur / 4;
    float end = end_ts - cur_dur / 4;
    if (end_ts > total_duration) {
        end_ts = total_duration;
    }
    
    if (![self selectDuration:start :end]) {
        play_start_pos = mouse_drag_start;
        show_play_start_pos = true;
    } else {
        show_play_start_pos = FALSE;
    }
    [self setNeedsDisplay:YES];
    return true;
    
}

-(bool)zoomOut {
    if(!audio_loaded) {
        return false;
    }
    float cur_dur = end_ts - start_ts;
    float start = start_ts  - cur_dur / 4;
    float end = end_ts  +  cur_dur / 4;
    if (start <  0) {
        start = 0;
    }
    if (end > total_duration) {
        end = total_duration;
    }
    
    if (![self selectDuration:start :end]) {
        play_start_pos = mouse_drag_start;
        show_play_start_pos = true;
    } else {
        show_play_start_pos = FALSE;
    }
    [self setNeedsDisplay:YES];
    return true;
    
}

- (void)mouseDown:(NSEvent *)theEvent {
    bg_color = [NSColor darkGrayColor];
    in_mouse_drag = TRUE;
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    
    NSLog(@"Mouse down location: %f %f", local_point.x, local_point.y);
    mouse_drag_start = local_point.x;
    mouse_drag_cur = 0;
    mouse_drag_end = 0;
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if(!in_mouse_drag) {
        return;
    }
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    if (local_point.x <= mouse_drag_start) {
        mouse_drag_cur = mouse_drag_start;
        return;
    }
    mouse_drag_cur =  local_point.x;
    [self setNeedsDisplay:YES];
    // NSLog(@"Mouse location: %f %f", mouseLoc.x, mouseLoc.y);
    
}

- (void)mouseUp:(NSEvent *)theEvent {
    bg_color = [NSColor lightGrayColor];
    in_mouse_drag = FALSE;
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    NSLog(@"Mouse up location: %f %f", local_point.x, local_point.y);
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
}

-(float)getTimePointFromPos:(float )pos {
    if (!audio_loaded) {
        return -1;
    }
    if (pos < 0 || pos > [self bounds].size.width) {
        return -1;
    }
    float ratio = pos / [self bounds].size.width;
    float ret = start_ts;
    ret = ret + (end_ts - start_ts) * ratio;
    if (ret > total_duration) {
        ret = total_duration;
    }
    return ret;
}


-(bool)selectDuration:(float )start: (float) end {
    if (start < 0) {
        NSLog(@"start not valid %f",start);
        return false;
    }
    if (end > total_duration) {
        NSLog(@"start not valid %f",start);
        return false;
    }
    if (end - start < 0.1) {
        NSLog(@"selected duration is too small: %f",end - start);
        return false;
    }
    start_ts = start;
    end_ts = end;
    [[self f0_view] select_dur:start  end:end];
    return true;
}

-(IBAction) OnPlayClicked:(id) sender {
    static bool in_play = false;
    void pcm2wav(const int16_t* x, int x_length, int fs, int nbit, std::vector<char>* out_vec);
    if (samples.size() <= 0) {
        return;
    }
    if (!in_play) {
        std::vector<char> out_vec;
        int start_index = [self getPlayStartIndex];
        int play_samples_size = samples.size() - start_index;
        pcm2wav(&samples[start_index], play_samples_size, 24000, 16, &out_vec);
        NSData *wav_data =  [NSData dataWithBytes:&out_vec[0] length:out_vec.size()];
        _theAudio = [[AVAudioPlayer alloc] initWithData:wav_data fileTypeHint:AVFileTypeWAVE error:NULL];
        [_theAudio play];
        [_play_button setTitle:@"Stop"];
        in_play = true;
        [_play_button setNeedsDisplay:YES];

    } else {
        [_theAudio stop];
        [_play_button setTitle:@"Play"];
        in_play = false;
        [_play_button setNeedsDisplay:YES];
    }
}

@end
