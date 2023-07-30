//
//  TrackView.h
//  drawaudio
//
//  Created by Yonghui Rao on 2023/6/12.
//

#import <Cocoa/Cocoa.h>
#import "WAV.h"
#import "f0View.h"
#import <AVFoundation/AVFoundation.h>



NS_ASSUME_NONNULL_BEGIN

@interface TrackView : NSView

@property (nonatomic,unsafe_unretained) WAV _wav;

@property IBOutlet f0View  *f0_view;

@property (nonatomic,strong) AVAudioPlayer * theAudio;

@property IBOutlet NSButton  *play_button;

-(IBAction) OnPlayClicked:(id) sender;
-(bool)init:(NSURL *)url;

-(bool)zoomIn;
-(bool)zoomOut;

-(float)getTsStart;
-(float)getTsEnd;
-(float)getTotalDuration;


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
