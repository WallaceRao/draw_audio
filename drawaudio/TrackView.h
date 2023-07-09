//
//  TrackView.h
//  drawaudio
//
//  Created by Yonghui Rao on 2023/6/12.
//

#import <Cocoa/Cocoa.h>
#import "WAV.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrackView : NSView

@property (nonatomic,unsafe_unretained) WAV _wav;
-(bool)init:(NSURL *)url;

-(bool)zoomIn;
-(bool)zoomOut;

@property IBOutlet NSTextField *l1;
@property IBOutlet NSTextField *l2;
@property IBOutlet NSTextField *l3;
@property IBOutlet NSTextField *l4;
@property IBOutlet NSTextField *l5;
@property IBOutlet NSTextField *l6;
@property IBOutlet NSTextField *l7;
@property IBOutlet NSTextField *l8;
@property IBOutlet NSTextField *l9;
@property IBOutlet NSTextField *l10;
@property IBOutlet NSTextField *l11;
@property IBOutlet NSTextField *l12;
@property IBOutlet NSTextField *l13;

@end

NS_ASSUME_NONNULL_END
