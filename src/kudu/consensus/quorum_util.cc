// Copyright (c) 2014, Cloudera Inc.
// Confidential Cloudera Information: Covered by NDA.

#include "kudu/consensus/quorum_util.h"

#include <boost/foreach.hpp>

#include "kudu/gutil/strings/substitute.h"
#include "kudu/server/metadata.pb.h"
#include "kudu/util/status.h"

namespace kudu {
namespace consensus {

using std::string;
using metadata::QuorumPB;
using metadata::QuorumPeerPB;
using strings::Substitute;

bool IsVotingRole(const metadata::QuorumPeerPB::Role role) {
  switch (role) {
    case QuorumPeerPB::LEADER:
    case QuorumPeerPB::CANDIDATE:
    case QuorumPeerPB::FOLLOWER:
      // Above 3 cases should all fall through.
      return true;
    default:
      return false;
  }
}

Status GivePeerRoleInQuorum(const string& peer_uuid,
                            metadata::QuorumPeerPB::Role new_role,
                            const QuorumPB& old_quorum,
                            QuorumPB* new_quorum) {
  new_quorum->CopyFrom(old_quorum);
  new_quorum->clear_peers();
  bool found_peer = false;
  BOOST_FOREACH(const QuorumPeerPB& old_peer, old_quorum.peers()) {
    QuorumPeerPB* new_peer = new_quorum->add_peers();
    new_peer->CopyFrom(old_peer);

    // Assume new role for local peer.
    if (new_peer->permanent_uuid() == peer_uuid) {
      if (PREDICT_FALSE(found_peer)) {
        return Status::IllegalState(
            Substitute("Peer $0 found in quorum multiple times: $1",
                       peer_uuid, old_quorum.ShortDebugString()));
      }
      found_peer = true;
      new_peer->set_role(new_role);
      continue;
    }

    // Demote any other leaders/candidates to followers.
    if (new_peer->role() == QuorumPeerPB::LEADER ||
        new_peer->role() == QuorumPeerPB::CANDIDATE) {
      new_peer->set_role(QuorumPeerPB::FOLLOWER);
    }
  }
  if (!found_peer) {
    return Status::IllegalState(Substitute("Cannot find peer $0 in quorum: $1",
                                           peer_uuid, old_quorum.ShortDebugString()));
  }
  return Status::OK();
}

void SetAllQuorumVotersToFollower(const metadata::QuorumPB& old_quorum,
                                  metadata::QuorumPB* new_quorum) {
  new_quorum->CopyFrom(old_quorum);
  new_quorum->clear_peers();
  BOOST_FOREACH(const QuorumPeerPB& old_peer, old_quorum.peers()) {
    QuorumPeerPB* new_peer = new_quorum->add_peers();
    new_peer->CopyFrom(old_peer);
    if (IsVotingRole(new_peer->role())) {
      new_peer->set_role(QuorumPeerPB::FOLLOWER);
    }
  }
}

metadata::QuorumPeerPB::Role GetRoleInQuorum(const std::string& permanent_uuid,
                                             const metadata::QuorumPB& quorum) {
  BOOST_FOREACH(const metadata::QuorumPeerPB& peer, quorum.peers()) {
    if (peer.permanent_uuid() == permanent_uuid) {
      return peer.role();
    }
  }
  return metadata::QuorumPeerPB::NON_PARTICIPANT;
}

} // namespace consensus
}  // namespace kudu
