//
//  mainViewController.h
//  drawaudio
//
//  Created by Yonghui Rao on 2023/6/14.
//

#import <Cocoa/Cocoa.h>
#import "TrackView.h"
#import "f0View.h"
NS_ASSUME_NONNULL_BEGIN

@interface mainViewController : NSViewController

-(bool)setCurFileUrl:(NSURL *)url;

-(NSData *)readFileFromFilePath:(NSURL *)filePath;

-(IBAction) OnImportFileClicked:(id) sender;
-(IBAction) OnZoomInlicked:(id) sender;
-(IBAction) OnZoomOutlicked:(id) sender;

-(IBAction) OnExtractF0:(id) sender;

@property IBOutlet TrackView *origin_view;
@property IBOutlet f0View *f0_view;

@end

NS_ASSUME_NONNULL_END
