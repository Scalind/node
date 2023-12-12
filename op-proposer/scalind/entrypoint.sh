#!/bin/sh

ARGS="--poll-interval=12s --rpc.port=8560"

if [[ (-n $SCALIND_L1_ETH_RPC) ]]; then
  ARGS="--l1-eth-rpc=$SCALIND_L1_ETH_RPC $ARGS"
else
  echo "ERROR: Variable \"SCALIND_L1_ETH_RPC\" should be present"
  exit 1
fi

if [[ -n $SCALIND_PROPOSER_PRIVATE_KEY ]]; then
  ARGS="--private-key=$SCALIND_PROPOSER_PRIVATE_KEY $ARGS"
else
  echo "ERROR: Variable \"SCALIND_PROPOSER_PRIVATE_KEY\" should be present"
  exit 1
fi

if [[ -n $SCALIND_L2_ROLLUP_RPC ]]; then
  ARGS="--rollup-rpc=$SCALIND_L2_ROLLUP_RPC $ARGS"
else
  echo "ERROR: Variable \"SCALIND_L2_ROLLUP_RPC\" should be present"
  exit 1
fi

if [[ -n $SCALIND_L2_OUTPUT_ORACLE_ADDRESS ]]; then
  ARGS="--l2oo-address=$SCALIND_L2_OUTPUT_ORACLE_ADDRESS $ARGS"
else
  echo "ERROR: Variable \"SCALIND_L2_OUTPUT_ORACLE_ADDRESS\" should be present"
  exit 1
fi

sh -c "op-proposer $ARGS"
