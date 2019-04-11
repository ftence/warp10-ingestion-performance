mkdir -p /var/tmp/influxdb
docker run --rm influxdb influxd config | sed -e 's/.*max-body-size.*/  max-body-size = 0/' > /var/tmp/influxdb/influxdb.conf
docker run -d --name=influxdb_bench -p 8083:8083 -p 8086:8086 -v /var/tmp/influxdb:/var/lib/influxdb -e INFLUXDB_ADMIN_ENABLED=true -v /var/tmp/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf:ro influxdb -config /etc/influxdb/influxdb.conf

# Wait for InfluxDB to kick in
sleep 3

# Gunzip data
gunzip -f --keep dataset.influx.gz

# Create the DB
curl -X POST -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"

# Upload the data
curl -w @curl.format -i -XPOST 'http://localhost:8086/write?db=mydb&p=us' -H 'Transfer-Encoding: chunked' -T dataset.influx

docker stop influxdb_bench
docker rm influxdb_bench