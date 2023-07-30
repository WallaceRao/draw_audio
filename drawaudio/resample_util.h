// Copyright 2020 Bytedance Inc. All Rights Reserved.
// Author: tts

#ifndef TTS_BACKEND_UTIL_RESAMPLE_UTIL_H_
#define TTS_BACKEND_UTIL_RESAMPLE_UTIL_H_

#include <cctype>
#include <map>
#include <sstream>
#include <string>
#include <vector>

#include "base/backend_define.h"
#include "base/backend_log.h"
#include "base/backend_types.h"
#include "libresample.h"

using std::vector;

TTS_BACKEND_BEGIN_NAMESPACE(util)

class ResampleUtil {
 public:
  ResampleUtil(){};
  virtual ~ResampleUtil();

  bool Init(int src_sample_rate, int dst_sample_rate);
  bool Resample(vector<int16_t> src_pcm, vector<int16_t>& dst_pcm,
                bool is_last);
 private:
  float factor;
  int src_sample_rate;
  int dst_sample_rate;
  void* resample_handle;
  TTS_BACKEND_LOG_DECLARE();
  TTS_BACKEND_DISALLOW_COPY_AND_ASSIGN(ResampleUtil);
};  // ResampleUtil

TTS_BACKEND_END_NAMESPACE(util)

#endif  // TTS_BACKEND_UTIL_RESAMPLE_UTIL_H_
