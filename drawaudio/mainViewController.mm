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


-(IBAction) OnExtractF0:(id) sender {
    float total_dur =  [[self origin_view] getTotalDuration];
    std::vector<float> f0_samples;
    for (int i = 0; i < 510; i ++) {
        f0_samples.push_back(i * 0.1 + 100);
    }
    
    if (total_dur > 0) {
        [[self f0_view] init:f0_samples total_dur:total_dur];
    }
    float start_ts = [[self origin_view] getTsStart];
    float end_ts = [[self origin_view] getTsEnd];
    [[self f0_view] select_dur:start_ts end:end_ts];
}

@end
