//
//  f0View.h
//  drawaudio
//
//  Created by Yonghui Rao on 2023/7/3.
//

#import <Cocoa/Cocoa.h>
#include <vector>

NS_ASSUME_NONNULL_BEGIN

@interface f0View : NSView
@property (nonatomic,unsafe_unretained) std::vector<float> f0_vec;

@property IBOutlet NSView  *track_view;

-(bool)init:(std::vector<float>)f0_vec total_dur:(float) dur ;

-(bool)select_dur:(float) start_ts_sec end:(float) end_ts_sec;
-(bool)getSelectSample:(NSPoint)mouse_point;


@end

NS_ASSUME_NONNULL_END
