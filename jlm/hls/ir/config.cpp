/*
 * Copyright 2026 Max Wipfli <mwipfli@ethz.ch>
 * See COPYING for terms of redistribution.
 */

#include <jlm/hls/ir/config.hpp>

#include <sstream>
#include <stdexcept>
#include <vector>

namespace jlm::hls
{

static std::vector<std::string>
split_string(const std::string & string, char delimiter)
{
  std::vector<std::string> parts;
  std::stringstream stringStream(string);
  std::string part;
  while (std::getline(stringStream, part, delimiter))
  {
    parts.push_back(part);
  }
  if (!string.empty() && string.back() == delimiter)
  {
    parts.emplace_back();
  }
  return parts;
}

static int
parse_integer(const std::string & string)
{
  std::size_t parsedLength;
  const auto integer = std::stoi(string, &parsedLength);
  if (parsedLength != string.size())
  {
    throw std::invalid_argument("Invalid integer");
  }
  return integer;
}

AddressQueueConfig
AddressQueueConfig::parse(const std::string & string)
{
  const auto parts = split_string(string, ':');

  if (parts.empty())
      throw std::invalid_argument("Invalid address queue configuration: empty string");

  auto parseError = [&]() {
    throw std::invalid_argument(
        "Invalid address queue configuration: expected 'none' or 'exact:<capacity>'");
  };

  AddressQueueConfig config;

  if (parts[0] == "none") {
      if (parts.size() != 1) parseError();
      config.type = Type::None;
  } else if (parts[0] == "exact") {
      if (parts.size() != 2) parseError();
      config.type = Type::Exact;
      config.capacity = parse_integer(parts[1]);
  } else {
      parseError();
  }

  // Validation
  if (config.type == Type::None) {
      // Nothing to validate
  } else if (config.type == Type::Exact) {
    if (config.capacity <= 0)
        throw std::invalid_argument("Invalid address queue configuration: Capacity must be greater than 0 for queue type 'exact'");
  }

  return config;
}

}
