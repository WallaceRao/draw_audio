//
//  opus_util.h
//  drawaudio
//
//  Created by Yonghui Rao on 2023/7/30.
//

#ifndef opus_util_h
#define opus_util_h
#include <stdio.h>
#include "include/opus.h"
#include <vector>


#define FRAME_SIZE 480
#define MAX_FRAME_SIZE (6*FRAME_SIZE)

#define MAX_CHANNELS 1
#define MAX_PACKET_SIZE (3*1276)

bool Wav2Opus(std::vector<int16_t> samples, std::vector<char> &opus_data);
#endif /* opus_util_h */
