#!/bin/sh

POLL_INTERVAL=${SCALIND_POLL_INTERVAL:-12s}
NUM_CONFIRMATIONS=${SCALIND_NUM_CONFIRMATIONS:-10}

ARGS="--poll-interval=${POLL_INTERVAL} --num-confirmations=${NUM_CONFIRMATIONS} --rpc.port=8560"

if [[ ${SCALIND_L1_ETH_RPC:+x} ]]; then
  ARGS="--l1-eth-rpc=$SCALIND_L1_ETH_RPC $ARGS"
else
  echo "ERROR: Variable \"SCALIND_L1_ETH_RPC\" should be present"
  exit 1
fi

if [[ ${SCALIND_PROPOSER_PRIVATE_KEY:+x} ]]; then
  ARGS="--private-key=$SCALIND_PROPOSER_PRIVATE_KEY $ARGS"
else
  echo "ERROR: Variable \"SCALIND_PROPOSER_PRIVATE_KEY\" should be present"
  exit 1
fi

if [[ ${SCALIND_L2_ROLLUP_RPC:+x} ]]; then
  ARGS="--rollup-rpc=$SCALIND_L2_ROLLUP_RPC $ARGS"
else
  echo "ERROR: Variable \"SCALIND_L2_ROLLUP_RPC\" should be present"
  exit 1
fi

if [[ ${SCALIND_L2_OUTPUT_ORACLE_ADDRESS:+x} ]]; then
  ARGS="--l2oo-address=$SCALIND_L2_OUTPUT_ORACLE_ADDRESS $ARGS"
else
  echo "ERROR: Variable \"SCALIND_L2_OUTPUT_ORACLE_ADDRESS\" should be present"
  exit 1
fi

sh -c "op-proposer $ARGS"
