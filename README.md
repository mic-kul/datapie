# Datapie

Based on [mic-kul](https://github.com/mic-kul)'s article [Garage made, self hosted NewRelic alternative with Ruby, Sinatra, Grafana and InfluxDB](https://mic-kul.com/2015/10/24/garage-made-self-hosted-newrelic-collector-using-ruby-sinatra-grafana-and-influxdb/).

Datapie is a docker container that allows you to build custom performance dashboard's in Grafana with the [newrelic/rpm](https://github.com/newrelic/rpm) gem.

# Install

Start by builduing and running the Datapie container.

```
$ docker build -t datapie Docker/ -
$ docker run -dit -p 8086:8086 -p 3000:3000 -p 4567:4567 datapie
```

**Depending on your docker setup you should be able to access Grafana either from localhost or the containers ip.**

The container is now listening for data in port 4567.
Add the following settings to your rails `newrelic.yml` config file for the environment you want to analise:

```
development:
  monitor_mode: true
  host: [DOCKER IP or LOCALHOST]
  port: 4567
  api_host: [DOCKER IP or LOCALHOST]
  api_port: 4567
  ssl: false
  error_collector:
    enabled: true
  agent_enabled: true
  developer_mode: true
```

Open grafana in your browser (http://[DOCKER IP or LOCALHOST]:3000) and login with admin user (default user/pass = admin/admin).

To get started you can use our prebuilt dashboard by importing [ruby-overview-dashboard.json](https://github.com/v4n/datapie/blob/master/ruby-overview-dashboard.json) to Grafana.
Read here on how to import in Grafana: http://docs.grafana.org/reference/export_import/#import-from-a-file

# Todo

- Verify [newrelic/node-newrelic](https://github.com/newrelic/node-newrelic) is supported.

# Tips

#### Container IP & Ports

*OSX:* If you are using OSX (boot2docker) you will most likely access the container through 127.0.0.1.
You can use [VirtualBox port forwarding](https://github.com/boot2docker/boot2docker/blob/master/doc/WORKAROUNDS.md#port-forwarding) to access the container on a port forward any conflicting port.

*Linux:* You can access the container by it's IP: `$ docker ps -a datapie | grep IP`.
