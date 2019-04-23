docker run -d --name=influxdb_bench -p 8083:8083 -p 8086:8086 -e INFLUXDB_HTTP_MAX_BODY_SIZE=0 influxdb >> /dev/null

# Wait for InfluxDB to kick in
sleep 3

# Gunzip data
gunzip -f --keep dataset.influx.gz

# Create the DB
curl --silent -X POST -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb" >> /dev/null

echo -n "UPLOAD"
# Upload the data
time curl --silent -i -XPOST 'http://localhost:8086/write?db=mydb&p=us' -H 'Transfer-Encoding: chunked' -T dataset.influx >> /dev/null

echo ""

echo -n "FETCH"
# Fetch the data
time curl --silent -X POST -G "http://localhost:8086/query?db=mydb&chunked=true" --data-urlencode "q=SELECT * FROM bench" > fetch.influx

# Should be 1000000
if [[ $(grep -o -i ,true fetch.influx | wc -l) != "1000000" ]]; then
  echo "Incomplete FETCH"
fi

docker stop influxdb_bench >> /dev/null
docker rm influxdb_bench >> /dev/null

rm fetch.influx