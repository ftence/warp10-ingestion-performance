docker run -d --name=warp10_bench -p 8080:8080 -p 8081:8081 warp10io/warp10:latest

# Wait for Warp 10 to kick in
sleep 6

docker exec warp10_bench less /opt/warp10/etc/initial.tokens > initial_bench.tokens
WRITE_TOKEN=`docker run --rm -i stedolan/jq < initial_bench.tokens '.write.token'| tr -d '"'`

# Gunzip data
gunzip -f --keep dataset-2.gts.gz

# Upload the data
curl -w @curl.format -H "X-Warp10-Token:$WRITE_TOKEN" -H 'Transfer-Encoding: chunked' -T dataset-2.gts http://127.0.0.1:8080/api/v0/update

docker stop warp10_bench
docker rm warp10_bench

rm initial_bench.tokens