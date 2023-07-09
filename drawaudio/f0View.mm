//
//  f0View.m
//  drawaudio
//
//  Created by Yonghui Rao on 2023/7/3.
//

#import "f0View.h"

@implementation f0View

- (void)drawRect:(NSRect)dirtyRect {
    
    // set any NSColor for filling, say white:
    [[NSColor lightGrayColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
    
    /*
    [super drawRect:dirtyRect];
    [[NSColor yellowColor] set];
    size_t sample_count = origin_wav.getSampleCount();
    int step = sample_count / 200000;
    if (step < 1) {
        step = 1;
    }
    for (size_t i = 0; i < sample_count; i = i + step) {
        if (i >= sample_count) {
            break;
        }
        NSRect drawingRect = NSZeroRect;
        int16_t sample = *((int16_t *)origin_wav.getData() + i);
        drawingRect.origin.x = [self bounds].origin.x +  [self bounds].size.width *  (i/(sample_count - 1.0));
        drawingRect.origin.y = [self bounds].origin.y +  [self bounds].size.height / 2 +  [self bounds].size.height / 2 * ((sample)/(32768 - 1.0)) ;
        drawingRect.size.width = 1; //[self bounds].size.width/sample_count;
        drawingRect.size.height = 1; //[self bounds].size.height * sample;
        NSRectFill(drawingRect);
    }
    
    // Drawing code here.
     */
}


-(bool)init:(std::vector<float>)f0_vec{
    _f0_vec = f0_vec;
    return true;
}



@end
