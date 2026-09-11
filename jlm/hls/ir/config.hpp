/*
 * Copyright 2026 Max Wipfli <mwipfli@ethz.ch>
 * See COPYING for terms of redistribution.
 */

#ifndef JLM_HLS_IR_CONFIG_HPP
#define JLM_HLS_IR_CONFIG_HPP

#include <string>

namespace jlm::hls
{

struct AddressQueueConfig final
{
  enum class Type
  {
    None,
    Exact
  };

  Type type{ Type::None };
  int capacity{ 0 };

  static AddressQueueConfig
  default_()
  {
    return { Type::Exact, 10 };
  }

  static AddressQueueConfig
  parse(const std::string & string);
};

}

#endif // JLM_HLS_IR_CONFIG_HPP
