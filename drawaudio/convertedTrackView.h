//
//  TrackView.h
//  drawaudio
//
//  Created by Yonghui Rao on 2023/6/12.
//

#import <Cocoa/Cocoa.h>
#import "WAV.h"

NS_ASSUME_NONNULL_BEGIN

@interface convertedTrackView : NSView

@property (nonatomic,unsafe_unretained) WAV _wav;
-(bool)init:(NSURL *)url;


@end

NS_ASSUME_NONNULL_END
