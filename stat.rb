require 'net/http'
require 'json'
require 'time'
require 'socket'

class Stat
  attr_accessor :api_prefix, :hostname, :service

  def initialize(use_staging_server: false, api_prefix: nil)
    if api_prefix
      @api_prefix = api_prefix
    elsif use_staging_server
      @api_prefix = "https://stat-staging.createlab.org"
    else
      @api_prefix = "https://stat.createlab.org"
    end
    @hostname = nil
    @service = nil
  end

  def get_datetime
    Time.now.iso8601
  end

  def get_hostname
    @hostname ||= Socket.gethostname.strip
  end

  def set_service(service)
    @service = service
  end

  def log(service:, level:, summary:, details: nil, host: nil, payload: {}, valid_for_secs: nil, shortname: nil)
    service ||= @service
    raise 'log: service must be passed, or set previously with set_service' unless service

    host ||= get_hostname
    shortname ||= host
    post_body = {
      service: service,
      datetime: get_datetime,
      host: host,
      level: level,
      summary: summary,
      details: details,
      payload: payload,
      valid_for_secs: valid_for_secs,
      shortname: shortname
    }

    puts "Stat.log #{level} #{service} #{host} #{summary} #{details}"
    
    uri = URI.parse(@api_prefix + '/api/log')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    request.body = post_body.to_json

    begin
      response = http.request(request)
      if response.code.to_i != 200
        $stderr.puts "POST to #{@api_prefix}/api/log failed with status code #{response.code} and response #{response.body}"
      end
    rescue StandardError => e
      $stderr.puts "POST to #{@api_prefix}/api/log timed out: #{e.message}"
    end
  end

  def info(summary:, details: nil, payload: {}, host: nil, service: nil, shortname: nil)
    log(service: service, level: 'info', summary: summary, details: details, payload: payload, host: host, shortname: shortname)
  end

  def debug(summary:, details: nil, payload: {}, host: nil, service: nil, shortname: nil)
    log(service: service, level: 'debug', summary: summary, details: details, payload: payload, host: host, shortname: shortname)
  end

  def warning(summary:, details: nil, payload: {}, host: nil, service: nil, shortname: nil)
    log(service: service, level: 'warning', summary: summary, details: details, payload: payload, host: host, shortname: shortname)
  end

  def critical(summary:, details: nil, payload: {}, host: nil, service: nil, shortname: nil)
    log(service: service, level: 'critical', summary: summary, details: details, payload: payload, host: host, shortname: shortname)
  end

  def up(summary:, details: nil, payload: {}, valid_for_secs: nil, host: nil, service: nil, shortname: nil)
    log(service: service, level: 'up', summary: summary, details: details, payload: payload, valid_for_secs: valid_for_secs, host: host, shortname: shortname)
  end

  def down(summary:, details: nil, payload: {}, valid_for_secs: nil, host: nil, service: nil, shortname: nil)
    log(service: service, level: 'down', summary: summary, details: details, payload: payload, valid_for_secs: valid_for_secs, host: host, shortname: shortname)
  end
end
