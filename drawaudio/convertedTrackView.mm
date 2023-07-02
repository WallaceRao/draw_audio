//
//  TrackView.m
//  drawaudio
//
//  Created by Yonghui Rao on 2023/6/12.
//

#import "convertedTrackView.h"

@implementation convertedTrackView

WAV converted_wav;

- (void)drawRect:(NSRect)dirtyRect {
    // set any NSColor for filling, say white:
    [[NSColor lightGrayColor] setFill];
    NSRectFill(dirtyRect);
    
    
    [super drawRect:dirtyRect];
    [[NSColor blueColor] set];
    size_t sample_count = converted_wav.getSampleCount();
    int step = sample_count / 200000;
    if (step < 1) {
        step = 1;
    }
    for (size_t i = 0; i < sample_count; i = i + step) {
        if (i >= sample_count) {
            break;
        }
        NSRect drawingRect = NSZeroRect;
        int16_t sample = *((int16_t *)converted_wav.getData() + i);
        drawingRect.origin.x = [self bounds].origin.x +  [self bounds].size.width *  (i/(sample_count - 1.0));
        drawingRect.origin.y = [self bounds].origin.y +  [self bounds].size.height / 2 +  [self bounds].size.height / 2 * ((sample)/(32768 - 1.0)) ;
        drawingRect.size.width = 1; //[self bounds].size.width/sample_count;
        drawingRect.size.height = 1; //[self bounds].size.height * sample;
        NSRectFill(drawingRect);
    }
    
    // Drawing code here.
}

-(bool)init:(NSURL *)url {
    const char *path = [[url absoluteString] UTF8String];
    path = "/Users/yonghuirao/Desktop/test_wave.wav";
    converted_wav.Read(path);
    [self setNeedsDisplay:YES];
    return true;
}


@end
