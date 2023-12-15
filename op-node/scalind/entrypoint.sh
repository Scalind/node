#!/bin/sh

get_file_from_s3() {
  if [[ -z $1 || -z $2 ]]; then
    exit 1
  fi
  export AWS_ENDPOINT_URL=http://${SCALIND_S3_URL}
  export AWS_ACCESS_KEY_ID=${SCALIND_S3_ACCESS_KEY}
  export AWS_SECRET_ACCESS_KEY=${SCALIND_S3_SECRET_KEY}
  aws s3 cp s3://${SCALIND_S3_BUCKET}/$1 $2 || exit 1
}

get_rollup_from_s3() {
    get_file_from_s3 $SCALIND_S3_ROLLUP_FILE_PATH /configs/rollup.json
    echo "Rollup file downloaded from S3"
}

ARGS="--sequencer.enabled --sequencer.l1-confs=5 --verifier.l1-confs=4 --rpc.addr=0.0.0.0 --rpc.port=8547 --rpc.enable-admin"

mkdir -p /configs

if [[ -n ${SCALIND_S3_URL} && -n ${SCALIND_S3_ACCESS_KEY} && -n ${SCALIND_S3_SECRET_KEY} && -n ${SCALIND_S3_BUCKET} && -n ${SCALIND_S3_ROLLUP_FILE_PATH}  ]]; then
  get_rollup_from_s3
fi

if [[ -f /configs/rollup.json ]]; then
  ARGS="--rollup.config=/configs/rollup.json $ARGS"
else
  echo "ERROR: Rollup.json should be mounted or S3 connection options should be provided"
  exit 1
fi

if [[ -n ${SCALIND_L2_URL} ]]; then
  ARGS="--l2=$SCALIND_L2_URL $ARGS"
else
  echo "ERROR: Variable \"SCALIND_L2_URL\" should be present"
  exit 1
fi

if [[ -f /secrets/jwt.txt ]]; then
  ARGS="--l2.jwt-secret=/secrets/jwt.txt $ARGS"
else
  echo "ERROR: File \"/secrets/jwt.txt\" should be present"
  exit 1
fi

if [[ -n ${SCALIND_SEQUENCER_PRIVATE_KEY} ]]; then
  ARGS="--p2p.sequencer.key=$SCALIND_SEQUENCER_PRIVATE_KEY $ARGS"
else
  echo "ERROR: Variable \"SCALIND_SEQUENCER_PRIVATE_KEY\" should be present"
  exit 1
fi

if [[ ${SCALIND_P2P_NODES:+x} ]]; then
  echo "INFO: P2P nodes env detected. Enabling P2P"
  ARGS="--p2p.static=$SCALIND_P2P_NODES --p2p.listen.ip=0.0.0.0 --p2p.listen.tcp=9003 --p2p.listen.udp=9003 $ARGS"
else
  echo "INFO: P2P nodes not found. Disabling P2P"
  ARGS=" --p2p.disable $ARGS"
fi

if [[ -n ${SCALIND_L1_URL} && -n ${SCALIND_L1_KIND} ]]; then
  ARGS="--l1=$SCALIND_L1_URL --l1.rpckind=$SCALIND_L1_KIND $ARGS"
else
  echo "ERROR: Variables \"SCALIND_L1_URL\" and \"SCALIND_L1_KIND\" should be present"
  exit 1
fi

sh -c "op-node $ARGS"
