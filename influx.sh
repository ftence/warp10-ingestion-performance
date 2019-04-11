docker run -d --name=influxdb_bench -p 8083:8083 -p 8086:8086 -e INFLUXDB_HTTP_MAX_BODY_SIZE=0 influxdb

# Wait for InfluxDB to kick in
sleep 3

# Gunzip data
gunzip -f --keep dataset.influx.gz

# Create the DB
curl -X POST -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"

echo "UPLOAD"
# Upload the data
time curl -i -XPOST 'http://localhost:8086/write?db=mydb&p=us' -H 'Transfer-Encoding: chunked' -T dataset.influx

echo "FETCH"
# Fetch the data
time curl -X POST -G "http://localhost:8086/query?db=mydb&chunked=true" --data-urlencode "q=SELECT * FROM bench" > fetch.influx

# Should be 1000000
grep -o -i ,true fetch.influx | wc -l

docker stop influxdb_bench
docker rm influxdb_bench

rm fetch.influx