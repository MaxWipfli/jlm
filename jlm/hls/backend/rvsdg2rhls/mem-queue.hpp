/*
 * Copyright 2021 David Metz <david.c.metz@ntnu.no>
 * See COPYING for terms of redistribution.
 */

#ifndef JLM_BACKEND_HLS_RVSDG2RHLS_MEM_QUEUE_HPP
#define JLM_BACKEND_HLS_RVSDG2RHLS_MEM_QUEUE_HPP

#include <jlm/hls/ir/config.hpp>
#include <jlm/rvsdg/Transformation.hpp>

#include <utility>

namespace jlm::hls
{

class AddressQueueInsertion final : public rvsdg::Transformation
{
public:
  ~AddressQueueInsertion() noexcept override;

  explicit AddressQueueInsertion(AddressQueueConfig addressQueueConfiguration);

  AddressQueueInsertion(const AddressQueueInsertion &) = delete;

  AddressQueueInsertion &
  operator=(const AddressQueueInsertion &) = delete;

  void
  Run(rvsdg::RvsdgModule & rvsdgModule, util::StatisticsCollector & statisticsCollector) override;

  static void
  CreateAndRun(
      rvsdg::RvsdgModule & rvsdgModule,
      util::StatisticsCollector & statisticsCollector,
      AddressQueueConfig addressQueueConfiguration = AddressQueueConfig::default_())
  {
    AddressQueueInsertion addressQueueInsertion(std::move(addressQueueConfiguration));
    addressQueueInsertion.Run(rvsdgModule, statisticsCollector);
  }

private:
  AddressQueueConfig AddressQueueConfiguration_;
};

}

#endif // JLM_BACKEND_HLS_RVSDG2RHLS_MEM_QUEUE_HPP
