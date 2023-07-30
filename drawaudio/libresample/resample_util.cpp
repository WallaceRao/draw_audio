// Copyright 2020 Bytedance Inc. All Rights Reserved.
// Author: tts


#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <string>
#include <vector>
#include "resample_util.h"



#define MIN_factor_ 0.1
#define MAX_factor_ 10.0
#define MIN(a, b) ((a) < (b)) ? (a) : (b)

const int max_mp3_size = 1024 * 1024;
const int max_pcm_size = 10 * 1024 * 1024;

// convert samples to float format
void WavShort2WavFloat(std::vector<int16_t>& in_vec,
                       std::vector<float>& out_vec) {
    out_vec.clear();
    for (int i = 0; i < in_vec.size(); i++) {
        out_vec.push_back(static_cast<float>(std::max<float>(
                                                             -1.0f,
                                                             std::min<float>(1.0f, static_cast<float>(in_vec.at(i) / 32767.0)))));
    }
}

// convert the data into pcm data
void WavFloat2WavShort(std::vector<float>& in_vec,
                       std::vector<int16_t>& out_vec) {
    out_vec.clear();
    for (int i = 0; i < in_vec.size(); i++) {
        out_vec.push_back(static_cast<int16_t>(std::max<int>(
                                                             -32768, std::min<int>(32767, static_cast<int>(in_vec.at(i) * 32767)))));
    }
}

void ResampleUtil::Reset() {
  if (resample_handle_) {
    resample_close(resample_handle_);
    resample_handle_ = nullptr;
  }
  resample_handle_ = resample_open(1, factor_, factor_);
  if (!resample_handle_) {
      printf("reset failed");
  }
}

bool ResampleUtil::Init(int src_sample_rate, int dst_sample_rate) {
  float factor_ = dst_sample_rate * 1.0 / src_sample_rate;
  if (factor_ < MIN_factor_ || factor_ > MAX_factor_) {
    return false;
  }
  this->src_sample_rate_ = src_sample_rate;
  this->dst_sample_rate_ = dst_sample_rate;
  this->factor_ = factor_;
  resample_handle_ = nullptr;
  resample_handle_ = resample_open(1, factor_, factor_);
  if (!resample_handle_) {
    return false;
  }
  return true;
}

// 重载支持float格式
bool ResampleUtil::Resample(vector<float>& src_pcm, vector<float>& dst_pcm,
                            bool is_last) {
  vector<int16_t> input, output;
  WavFloat2WavShort(src_pcm, input);
  bool result = Resample(input, output, is_last);
  WavShort2WavFloat(output, dst_pcm);
  return result;
}

bool ResampleUtil::Resample(vector<int16_t>& src_pcm, vector<int16_t>& dst_pcm,
                            bool is_last) {
  if (src_pcm.empty()) {
    return false;
  }
  if (!resample_handle_) {
    return false;
  }

  if (factor_ == 1.0) {
    return true;
  }
  std::vector<float> src_vec(src_pcm.begin(), src_pcm.end());
  int src_len = src_vec.size();
  int expected_len = (int)(src_len * factor_);

  int src_blocksize = 64;
  // add 10 extra samples, copied from github demo
  int dst_blocksize = int(src_blocksize * factor_ + 10);
  int dst_pos = 0, src_pos = 0, src_used = 0, handled_size = 0;

  int blocks = src_pcm.size() / src_blocksize + 1;

  int dst_len = blocks * dst_blocksize;
  float* src = &src_vec[0];
  float* dst = new float[dst_len];

  for (;;) {
    int src_block = MIN(src_len - src_pos, src_blocksize);
    int lastflag = ((src_block + src_pos == src_len) && is_last);
    handled_size = resample_process(
        resample_handle_, factor_, &src[src_pos], src_block, lastflag,
        &src_used, &dst[dst_pos], MIN(dst_len - dst_pos, dst_blocksize));
    src_pos += src_used;
    if (handled_size >= 0) dst_pos += handled_size;
    if (handled_size < 0 || (handled_size == 0 && src_pos == src_len)) break;
  }
  if (handled_size < 0) {
    delete[] dst;
    return false;
  }

  dst_pcm.clear();
  for (int i = 0; i < dst_pos; i++) {
    int16_t elem = static_cast<int16_t>(
        std::max<int>(-32768, std::min<int>(32767, static_cast<int>(dst[i]))));
    dst_pcm.push_back(elem);
  }

  delete[] dst;
  if (is_last) Reset();
  return true;
}

ResampleUtil::~ResampleUtil() {
  if (resample_handle_) resample_close(resample_handle_);
  resample_handle_ = nullptr;
}

