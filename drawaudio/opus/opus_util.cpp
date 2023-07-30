//
//  opus_util.c
//  drawaudio
//
//  Created by Yonghui Rao on 2023/7/30.
//

#include "opus_util.h"
#define FRAME_SIZE 480
#define MAX_FRAME_SIZE (6*FRAME_SIZE)

#define MAX_CHANNELS 1
#define MAX_PACKET_SIZE (3*1276)

bool Wav2Opus(std::vector<int16_t> samples, std::vector<char> &opus_data) {

    uint32_t bitsPerSample = 16;
    uint32_t sampleRate = 24000;
    uint16_t channels = 1;
    int err = 0;
    OpusEncoder *encoder = opus_encoder_create(sampleRate, channels, OPUS_APPLICATION_AUDIO, &err);
    if (!encoder || err < 0) {
        fprintf(stderr, "failed to create an encoder: %s\n", opus_strerror(err));
        if (!encoder) {
            opus_encoder_destroy(encoder);
        }
        return false;
    }
    const uint16_t *data = (uint16_t *) &samples[0];
    size_t size = samples.size();
    opus_int16 pcm_bytes[FRAME_SIZE * MAX_CHANNELS];
    size_t index = 0;
    size_t step = static_cast<size_t>(FRAME_SIZE * channels);
    unsigned char cbits[MAX_PACKET_SIZE];
    opus_data.reserve(1024 * 1024 * 5);
    size_t frameCount = 0;
    size_t readCount = 0;
    while (index < size) {
        memset(&pcm_bytes, 0, sizeof(pcm_bytes));
        if (index + step <= size) {
            memcpy(pcm_bytes, data + index, step * sizeof(uint16_t));
            index += step;
        } else {
            readCount = size - index;
            memcpy(pcm_bytes, data + index, (readCount) * sizeof(uint16_t));
            index += readCount;
        }
        int nbBytes = opus_encode(encoder, pcm_bytes, channels * FRAME_SIZE, cbits, MAX_PACKET_SIZE);
        if (nbBytes < 0) {
            fprintf(stderr, "encode failed: %s\n", opus_strerror(nbBytes));
            break;
        }
        ++frameCount;
        size_t cur_size = opus_data.size();
        size_t new_size = cur_size + nbBytes;
        opus_data.resize(new_size);
        memcpy(&opus_data[cur_size], (char *) cbits, nbBytes);
    }
    printf("opus compress finished, from size:%d to size:%d", samples.size() * 2, opus_data.size());
    opus_encoder_destroy(encoder);
    return true;
}

