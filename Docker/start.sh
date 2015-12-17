#!/bin/bash
nohup /usr/sbin/grafana-server \
  --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini \
  cfg:default.paths.data=/var/lib/grafana \
  cfg:default.paths.logs=/var/log/grafana \
  > grafana.out 2>&1&
nohup influxd > influxd.out 2>&1&
ruby /usr/src/app/datapie.rb
