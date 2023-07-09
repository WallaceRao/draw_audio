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

-(bool)init:(std::vector<float>)f0_vec;

@end

NS_ASSUME_NONNULL_END
