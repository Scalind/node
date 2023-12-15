#!/bin/sh

ARGS="--poll-interval=1s --sub-safety-margin=6 --num-confirmations=1 --safe-abort-nonce-too-low-count=3 --resubmission-timeout=30s --rpc.addr=0.0.0.0 --rpc.port=8548 --rpc.enable-admin --max-channel-duration=1"

if [[ ${SCALIND_L2_ETH_RPC:+x} ]]; then
  ARGS="--l2-eth-rpc=$SCALIND_L2_ETH_RPC $ARGS"
else
  echo "ERROR: Variable \"SCALIND_L2_ETH_RPC\" should be present"
  exit 1
fi

if [[ ${SCALIND_L2_ROLLUP_RPC:+x} ]]; then
  ARGS="--rollup-rpc=$SCALIND_L2_ROLLUP_RPC $ARGS"
else
  echo "ERROR: Variable \"SCALIND_L2_ROLLUP_RPC\" should be present"
  exit 1
fi

if [[ ${SCALIND_L1_ETH_RPC:+x} ]]; then
  ARGS="--l1-eth-rpc=$SCALIND_L1_ETH_RPC $ARGS"
else
  echo "ERROR: Variable \"SCALIND_L1_ETH_RPC\" should be present"
  exit 1
fi

if [[ ${SCALIND_BATCHER_PRIVATE_KEY:+x} ]]; then
  ARGS="--private-key=$SCALIND_BATCHER_PRIVATE_KEY $ARGS"
else
  echo "ERROR: Variable \"SCALIND_BATCHER_PRIVATE_KEY\" should be present"
  exit 1
fi

sh -c "op-batcher $ARGS"
