//
//  mainViewController.m
//  drawaudio
//
//  Created by Yonghui Rao on 2023/6/14.
//

#import "mainViewController.h"
#import "WAV.h"

@interface mainViewController ()

@end

@implementation mainViewController

static NSURL * cur_file_path;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


-(NSData *)readFileFromFilePath:(NSURL *)filePath{
    NSData *data = [NSData dataWithContentsOfFile:[filePath absoluteString]];
    NSLog(@"read file: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    const char *path = [[filePath absoluteString] UTF8String];
  //  origin_wav.Read(path);
    [[self origin_view] init:filePath];
    return data;
}

-(NSString*)getFileName {
    NSString *cur_file_name = NULL;
    if (cur_file_path) {
        cur_file_name = [cur_file_path lastPathComponent];
    }
    return cur_file_name;
}

-(bool)setCurFileUrl:(NSURL *)url {
    cur_file_path = url;
    NSString *file_name = [self getFileName];
    for (NSWindow *window in [NSApplication sharedApplication].windows) {
        NSView *content_view = [window contentView];
 //       if([content_view isKindOfClass: [MyMainView class]]) {
 //           [window setTitle:file_name];
 //       }
    }
    return TRUE;
}



-(IBAction) OnImportFileClicked:(id) sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories : NO];
    [panel setCanChooseFiles : YES];
    [panel setAllowsMultipleSelection : NO];
    [panel setAllowedFileTypes : @[@"wav"]];
    
    NSData *data = nil;
    NSInteger result = [panel runModal];
    if (result == NSModalResponseOK)
    {
        NSArray *selectFiles = [panel URLs];
        if ([selectFiles count] == 1) {
            NSURL * file = [selectFiles objectAtIndex : 0];
            auto data = [self readFileFromFilePath:file];
            [self setCurFileUrl: [selectFiles objectAtIndex : 0]];
            printf("read from file:%s\n", [[cur_file_path absoluteString] UTF8String]);
        }
    }
}


-(IBAction) OnZoomInlicked:(id) sender {
    [[self origin_view] zoomIn];
    
}
-(IBAction) OnZoomOutlicked:(id) sender {
    [[self origin_view] zoomOut];
}

@end
