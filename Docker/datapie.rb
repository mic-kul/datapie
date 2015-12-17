# Author: https://github.com/mic-kul

require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/json'

require 'base64'
require 'json'
require 'zlib'
require 'stringio'

require 'influxdb'

use Rack::Deflater

set :bind, '0.0.0.0'

namespace '/agent_listener/:api_version' do |api_version|
  namespace '/:license_key' do |license_key|
    get_redirect_host = { return_value: 'localhost' }
    get '/get_redirect_host' do
      json get_redirect_host
    end

    post '/get_redirect_host' do
      json get_redirect_host
    end

    connect =
      { return_value: { browser_key: 'xx', application_id: 1, js_agent_loader: '' } }
    post '/connect' do
      json connect
    end


    metric_data = {}
    post '/metric_data' do
      request.body.rewind
      body = request.body.read
      body = Zlib::Inflate.inflate(body) if request.env["HTTP_CONTENT_ENCODING"] == "deflate"
      metrics = JSON.parse body
      data = []
      metrics[3].each do |meta, values|
        data = {
          tags: { metric_name: meta['name'] },
          values: {
            cnt: values[0],
            val: values[1], own: values[2], min: values[3], max: values[4], sqr: values[5]
          }
        }
        single_to_influx('metric_data', data)
      end
      json metric_data
    end

    analytic_event_data = {}
    post '/analytic_event_data' do
      request.body.rewind
      p request.env
      body = request.body.read
      body = Zlib::Inflate.inflate(body) if request.env["HTTP_CONTENT_ENCODING"] == "deflate"
      json_analytics = JSON.parse body
      data = []
      json_analytics[1].each do |meta, _wtf|
        data << {
          series: 'analytics_data',
          tags: { metric_name: meta['name'], mtype: meta['type'] },
          values: { mduration: meta['duration'] },
        }
      end
      to_influx(data)
      json analytic_event_data
    end

    error_data = { return_value: 'ok' }
    post '/error_data' do
      request.body.rewind
      # p request.body.read
      raw_body = request.body.read
      raw_body = Zlib::Inflate.inflate(raw_body) if request.env["HTTP_CONTENT_ENCODING"] == "deflate"
      json_error = JSON.parse raw_body
      data = []

      json_error[1].each do |err|
        data = {
          tags: { error_method: err[1], request_uri: err[4]['request_uri'] },
          values: { message: err[2] },
          # timestamp: err[0],
        }
        single_to_influx('errors_data', data)
      end
      json error_data
    end

    get_agent_commands = { return_value: [] }
    post '/get_agent_commands' do
      json get_agent_commands
    end
  end
end

def unblob(blob)
  return unless blob
  JSON.load(Zlib::Inflate.inflate(Base64.decode64(blob)))
end

def inflate(string)

end

def to_influx(data)
  begin
    influxdb.write_points(data)
  rescue StandardError => e
    p "----------"
    p data
    p "----------"
    raise e
  end
end

def single_to_influx(name, data)
  begin
    influxdb.write_point(name, data)
  rescue StandardError => e
    p "----------"
    p data
    p "----------"
    raise e
  end
end

def influxdb
  @influxdb ||= InfluxDB::Client.new 'datapie', host: 'localhost'
end
