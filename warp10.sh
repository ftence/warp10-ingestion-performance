docker run -d --name=warp10_bench -p 8080:8080 -p 8081:8081 warp10io/warp10:latest >> /dev/null

# Wait for Warp 10 to kick in
sleep 6

EXTRACONF="
# null=true
# leveldb.directory.syncrate = 0.0
"

docker exec -u warp10 warp10_bench bash -c "echo \"$EXTRACONF\" >> /opt/warp10/etc/conf-standalone.conf"

docker exec -u warp10 warp10_bench warp10-standalone.sh restart >> /dev/null

docker exec warp10_bench less /opt/warp10/etc/initial.tokens > initial_bench.tokens
WRITE_TOKEN=`docker run --rm -i stedolan/jq < initial_bench.tokens '.write.token'| tr -d '"'`
READ_TOKEN=`docker run --rm -i stedolan/jq < initial_bench.tokens '.read.token'| tr -d '"'`

# Gunzip data
gunzip -f --keep dataset-2.gts.gz

echo -n "UPLOAD"
# Upload the data
time curl --silent -H "X-Warp10-Token:$WRITE_TOKEN" -H 'Transfer-Encoding: chunked' -T dataset-2.gts http://127.0.0.1:8080/api/v0/update

echo ""

echo -n "FETCH"
# Fetch the data
time curl --silent -g -H "X-Warp10-Token:$READ_TOKEN" "http://127.0.0.1:8080/api/v0/fetch?selector=~.*{}&format=json&now=now&timespan=-10000" > fetch.warp10

# Should be 1000000
if [[ $(grep -o -i ,true fetch.warp10 | wc -l) != "1000000" ]]; then
  echo "Incomplete FETCH"
fi

docker stop warp10_bench >> /dev/null
docker rm warp10_bench >> /dev/null

rm initial_bench.tokens
rm fetch.warp10