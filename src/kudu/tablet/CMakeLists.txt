# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set(TABLET_SRCS
  tablet.cc
  tablet_bootstrap.cc
  tablet_metrics.cc
  tablet_mm_ops.cc
  tablet_replica_mm_ops.cc
  tablet_replica.cc
  txn_participant.cc
  ops/op.cc
  ops/alter_schema_op.cc
  ops/op_driver.cc
  ops/op_tracker.cc
  ops/participant_op.cc
  ops/write_op.cc
  op_order_verifier.cc
  cfile_set.cc
  compaction.cc
  compaction_policy.cc
  delta_key.cc
  diskrowset.cc
  lock_manager.cc
  memrowset.cc
  multi_column_writer.cc
  mutation.cc
  mvcc.cc
  row_op.cc
  rowset.cc
  rowset_info.cc
  rowset_tree.cc
  svg_dump.cc
  tablet_metadata.cc
  rowset_metadata.cc
  deltafile.cc
  deltamemstore.cc
  delta_applier.cc
  delta_compaction.cc
  delta_iterator_merger.cc
  delta_stats.cc
  delta_store.cc
  delta_tracker.cc
)

PROTOBUF_GENERATE_CPP(
  TABLET_PROTO_SRCS TABLET_PROTO_HDRS TABLET_PROTO_TGTS
  SOURCE_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/../..
  BINARY_ROOT ${CMAKE_CURRENT_BINARY_DIR}/../..
  PROTO_FILES
    tablet.proto
    metadata.proto)
set(TABLET_PROTO_LIBS
  protobuf
  fs_proto
  consensus_metadata_proto
  kudu_common)
ADD_EXPORTABLE_LIBRARY(tablet_proto
  SRCS ${TABLET_PROTO_SRCS}
  DEPS ${TABLET_PROTO_LIBS}
  NONLINK_DEPS ${TABLET_PROTO_TGTS})

add_library(tablet ${TABLET_SRCS})
target_link_libraries(tablet
  clock
  tablet_proto
  codegen
  kudu_common
  cfile
  gutil
  kudu_fs
  kudu_util
  consensus)

add_library(tablet_test_util
  tablet-test-util.cc
  tablet_replica-test-base.cc)
target_link_libraries(tablet_test_util
  kudu_common
  kudu_test_util
  log_proto
  tablet)

SET_KUDU_TEST_LINK_LIBS(tablet tablet_test_util)
ADD_KUDU_TEST(all_types-scan-correctness-test NUM_SHARDS 8 PROCESSORS 2)
ADD_KUDU_TEST(cfile_set-test)
ADD_KUDU_TEST(compaction-test)
ADD_KUDU_TEST(compaction_policy-test DATA_FILES ycsb-test-rowsets.tsv)
ADD_KUDU_TEST(composite-pushdown-test)
ADD_KUDU_TEST(delta_compaction-test)
ADD_KUDU_TEST(deltafile-test)
ADD_KUDU_TEST(deltamemstore-test)
ADD_KUDU_TEST(diff_scan-test)
ADD_KUDU_TEST(diskrowset-test)
ADD_KUDU_TEST(lock_manager-test)
ADD_KUDU_TEST(major_delta_compaction-test)
ADD_KUDU_TEST(memrowset-test)
ADD_KUDU_TEST(metadata-test)
ADD_KUDU_TEST(mt-diskrowset-test RUN_SERIAL true)
ADD_KUDU_TEST(mt-rowset_delta_compaction-test PROCESSORS 2)
ADD_KUDU_TEST(mt-tablet-test RUN_SERIAL true NUM_SHARDS 4)
ADD_KUDU_TEST(mvcc-test)
ADD_KUDU_TEST(ops/op_tracker-test)
ADD_KUDU_TEST(rowset_tree-test NUM_SHARDS 6)
ADD_KUDU_TEST(tablet-decoder-eval-test)
ADD_KUDU_TEST(tablet-pushdown-test)
ADD_KUDU_TEST(tablet-schema-test)
ADD_KUDU_TEST(tablet-test)
ADD_KUDU_TEST(tablet_auto_incrementing-test)
ADD_KUDU_TEST(tablet_bootstrap-test)
ADD_KUDU_TEST(tablet_history_gc-test)
ADD_KUDU_TEST(tablet_metadata-test)
ADD_KUDU_TEST(tablet_mm_ops-test)
ADD_KUDU_TEST(tablet_random_access-test)
ADD_KUDU_TEST(tablet_replica-test)
ADD_KUDU_TEST(tablet_throttle-test)
ADD_KUDU_TEST(txn_participant-test)

# Some tests don't have dependencies on other tablet stuff
SET_KUDU_TEST_LINK_LIBS(kudu_util gutil)
ADD_KUDU_TEST(cbtree-test RUN_SERIAL true)
