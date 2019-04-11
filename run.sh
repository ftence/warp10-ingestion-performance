#!/bin/sh

# URL=https://sandbox.senx.io/api/v0/update
URL=http://127.0.0.1:8888/api/v0/update
WRITE_TOKEN=WRITE

echo "Initializing Warp 10™ with dataset-0"
curl -w @curl.format -X POST  -H 'Content-Type: application/gzip' -H 'Transfer-Encoding: chunked' -H "X-Warp10-Token: ${WRITE_TOKEN}" -T dataset-0.gts.gz ${URL}

for dataset in 1 2 3 4 5 6 7
do
  echo "Ingesting dataset-${dataset}"
  curl -w @curl.format -X POST  -H 'Content-Type: application/gzip' -H 'Transfer-Encoding: chunked' -H "X-Warp10-Token: ${WRITE_TOKEN}" -T dataset-${dataset}.gts.gz ${URL}
done

