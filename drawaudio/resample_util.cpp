// Copyright 2020 Bytedance Inc. All Rights Reserved.
// Author: tts

#include "util/resample_util.h"

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <string>
#include <vector>

TTS_BACKEND_BEGIN_NAMESPACE(util)
TTS_BACKEND_LOG_SETUP(util, ResampleUtil);

#define MIN_FACTOR 0.1
#define MAX_FACTOR 10.0
#define MIN(a, b) ((a) < (b)) ? (a) : (b)

bool ResampleUtil::Init(int src_sample_rate, int dst_sample_rate) {
  TTS_BACKEND_LOG(ERROR,
                  "ResampleUtil::Init with src_sample_rate:%d and "
                  "dst_sample_rate:%d",
                  src_sample_rate, dst_sample_rate);
  float factor = dst_sample_rate * 1.0 / src_sample_rate;
  if (factor < MIN_FACTOR || factor > MAX_FACTOR) {
    TTS_BACKEND_LOG(ERROR, "Initialize ResampleUtil with invalid factor:%f",
                    factor);
    return false;
  }
  this->src_sample_rate = src_sample_rate;
  this->dst_sample_rate = dst_sample_rate;
  this->factor = factor;
  TTS_BACKEND_LOG(DEBUG, "Initialize ResampleUtil with factor:%f", factor);
  resample_handle = nullptr;
  resample_handle = resample_open(1, factor, factor);
  if (!resample_handle) {
    TTS_BACKEND_LOG(ERROR, "Initialize ResampleUtil with factor:%f failed",
                    factor);
    return false;
  }
  return true;
}

bool ResampleUtil::Resample(vector<int16_t> src_pcm, vector<int16_t>& dst_pcm,
                            bool is_last) {
  if (src_pcm.empty()) {
    TTS_BACKEND_LOG(ERROR, "ResampleUtil::Resample: no input data");
    return false;
  }
  if (!resample_handle) {
    TTS_BACKEND_LOG(ERROR, "ResampleUtil::Resample: not initialized");
    return false;
  }

  if (factor == 1.0) {
    TTS_BACKEND_LOG(
        DEBUG, "ResampleUtil::Resample: no need to resample since factor is 1");
    return true;
  }
  std::vector<float> src_vec(src_pcm.begin(), src_pcm.end());
  int src_len = src_vec.size();
  int expected_len = (int)(src_len * factor);

  int src_blocksize = 64;
  // add 10 extra samples, copied from github demo
  int dst_blocksize = int(src_blocksize * factor + 10);
  int dst_pos = 0, src_pos = 0, src_used = 0, handled_size = 0;

  int blocks = src_pcm.size() / src_blocksize + 1;

  int dst_len = blocks * dst_blocksize;
  float* src = &src_vec[0];
  float* dst = new float[dst_len];

  for (;;) {
    int src_block = MIN(src_len - src_pos, src_blocksize);
    handled_size = resample_process(resample_handle, factor, &src[src_pos],
                                    src_block, false, &src_used, &dst[dst_pos],
                                    MIN(dst_len - dst_pos, dst_blocksize));
    src_pos += src_used;
    if (handled_size >= 0) dst_pos += handled_size;
    if (handled_size < 0 || (handled_size == 0 && src_pos == src_len)) break;
  }
  if (handled_size < 0) {
    delete[] dst;
    TTS_BACKEND_LOG(ERROR, "resample_process returned an error: %d\n",
                    handled_size);
    return false;
  }
  std::vector<float> dst_vec(dst, dst + dst_pos);
  std::vector<int16_t> result_vec(dst_vec.begin(), dst_vec.end());
  TTS_BACKEND_LOG(
      DEBUG,
      "After resample with factor %f, sample points number changes from:%d "
      "to %d",
      factor, src_pcm.size(), result_vec.size());
  dst_pcm = result_vec;
  delete[] dst;
  return true;
}

ResampleUtil::~ResampleUtil() {
  if (resample_handle) resample_close(resample_handle);
  resample_handle = nullptr;
}

TTS_BACKEND_END_NAMESPACE(util)
