FROM ruby:2.1-onbuild

EXPOSE 8086 3000 4567

# Install InfluxDB
RUN wget http://influxdb.s3.amazonaws.com/influxdb_0.9.5_amd64.deb
RUN dpkg -i influxdb_0.9.5_amd64.deb
RUN rm influxdb_0.9.5_amd64.deb

# Create the default DB
RUN (influxd &) && sleep 5s; influx -execute="CREATE DATABASE datapie"

# Install Grafana
RUN wget https://grafanarel.s3.amazonaws.com/builds/grafana_2.5.0_amd64.deb
RUN apt-get install -y adduser libfontconfig
RUN dpkg -i grafana_2.5.0_amd64.deb
RUN rm grafana_2.5.0_amd64.deb

# Create Grana Data Source
RUN service grafana-server start && curl \
  'http://admin:admin@localhost:3000/api/datasources' -X POST \
  -H 'Content-Type: application/json;charset=UTF-8' \
  --data-binary '{"name":"Datapie", "type":"influxdb", \
    "url":"http://localhost:8086", "access":"proxy", \
    "isDefault":true, "database":"datapie", \
    "user":"admin", "password":"admin"}'

# Done By The Ruby Docker Image
# ONBUILD COPY . /usr/src/app

ENTRYPOINT ["/usr/src/app/start.sh"]
