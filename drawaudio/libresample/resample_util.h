// Copyright 2020 Bytedance Inc. All Rights Reserved.
// Author: tts

#ifndef TTS_BACKEND_UTIL_RESAMPLE_UTIL_H_
#define TTS_BACKEND_UTIL_RESAMPLE_UTIL_H_

#include <cctype>
#include <map>
#include <sstream>
#include <string>
#include <vector>

#include "libresample.h"

using std::vector;


class ResampleUtil {
 public:
  ResampleUtil(){};
  virtual ~ResampleUtil();

  bool Init(int src_sample_rate, int dst_sample_rate);
  bool Resample(vector<int16_t>& src_pcm, vector<int16_t>& dst_pcm,
                bool is_last);
  bool Resample(vector<float>& src_pcm, vector<float>& dst_pcm, bool is_last);

 private:
  void* resample_handle_;
  float factor_;
  int src_sample_rate_;
  int dst_sample_rate_;

  void Reset();

};  // ResampleUtil


#endif  // TTS_BACKEND_UTIL_RESAMPLE_UTIL_H_
