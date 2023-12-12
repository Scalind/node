#!/bin/sh

get_rollup_from_s3() {
  DATE=$(date -R)
  S3_PATH="/$SCALIND_S3_BUCKET/$SCALIND_S3_ROLLUP_FILE_PATH"
  SIG_STRING="GET\n\napplication/json\n${DATE}\n${S3_PATH}"
  SIGNATURE=$(echo $SIG_STRING | openssl sha1 -hmac $SCALIND_S3_SECRET_KEY -binary | base64)
  wget -o /configs/rollup.json \
    -H "Host: $SCALIND_S3_URL" \
    -H "Date: ${DATE}" \
    -H "Content-Type: application/json" \
    -H "Authorization: AWS $SCALIND_S3_ACCESS_KEY:${SIGNATURE}" \
    http://$SCALIND_S3_URL/${S3_PATH}
  echo "Rollup file downloaded from S3"
}

ARGS="--sequencer.enabled --sequencer.l1-confs=5 --verifier.l1-confs=4 --rpc.addr=0.0.0.0 --rpc.port=8547 --p2p.disable --rpc.enable-admin"

mkdir /configs

if [[ -n $SCALIND_S3_URL && -n $SCALIND_S3_ACCESS_KEY && -n $SCALIND_S3_SECRET_KEY && -n $SCALIND_S3_BUCKET && -n $SCALIND_S3_ROLLUP_FILE_PATH  ]]; then
  get_rollup_from_s3
fi

if [[ -f /configs/rollup.json ]]; then
  ARGS="--rollup.config=/configs/rollup.json $ARGS"
else
  echo "ERROR: Rollup.json should be mounted or S3 connection options should be provided"
  exit 1
fi

if [[ -n $SCALIND_L2_URL ]]; then
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

if [[ -n $SCALIND_SEQUENCER_PRIVATE_KEY ]]; then
  ARGS="--p2p.sequencer.key=$SCALIND_SEQUENCER_PRIVATE_KEY $ARGS"
else
  echo "ERROR: Variable \"SCALIND_SEQUENCER_PRIVATE_KEY\" should be present"
  exit 1
fi

if [[ (-n $SCALIND_L1_URL) -a (-n $SCALIND_L1_KIND) ]]; then
  ARGS="--l1=$SCALIND_L1_URL --l1.rpckind=$SCALIND_L1_KIND $ARGS"
else
  echo "ERROR: Variables \"SCALIND_L1_URL\" and \"SCALIND_L1_KIND\" should be present"
  exit 1
fi

sh -c "op-node $ARGS"
