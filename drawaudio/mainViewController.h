//
//  mainViewController.h
//  drawaudio
//
//  Created by Yonghui Rao on 2023/6/14.
//

#import <Cocoa/Cocoa.h>
#import "TrackView.h"
NS_ASSUME_NONNULL_BEGIN

@interface mainViewController : NSViewController

-(bool)setCurFileUrl:(NSURL *)url;

-(NSData *)readFileFromFilePath:(NSURL *)filePath;

-(IBAction) OnImportFileClicked:(id) sender;

@property IBOutlet TrackView *origin_view;

@end

NS_ASSUME_NONNULL_END
