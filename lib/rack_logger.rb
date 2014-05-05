require "rack_logger/version"
require "uuidtools"
require 'cgi'
# Completed 404 Not Found in 105ms (Views: 4.6ms | ActiveRecord: 2.3ms | Sphinx: 0.0ms | Gateway: 86.3ms)
class RackLogger
  attr_reader :logger, :log_subscribers
  # log_subscribers:
  #   [
  #     {
  #     :label => "label",
  #     :class => ActiveRecord::LogSubscriber
  #     }
  #   ]
  def initialize(app, logger, *log_subscribers)
    @app = app
    @logger = logger
    @log_subscribers = log_subscribers
  end

  def call(env)
    dup._call(env)
  end

  def _call(env)
    begin
      request = Rack::Request.new(env)
      time_start = Time.now
      logger.info "Started #{request.request_method} \"#{request.url}\" for #{request.ip} at #{Time.now} #{request.user_agent}"
      Thread.current[:request_id] ||= UUIDTools::UUID.random_create.to_s
      status, header, body = @app.call(env)
      # million seconds
      time_cost = (Time.now - time_start) * 1000
      header["x-runtime"] = "%.2fms" % time_cost
      header["x-request-id"] = Thread.current[:request_id]

      [status, header, body]
    ensure
      benchmarks = []
      payload = {}

      time_cost ||= (Time.now - time_start) * 1000

      log_subscribers.each do |subscriber|
        label = subscriber[:label]
        subscriber_class = subscriber[:class]

        if t = subscriber_class.send(:runtime)
          benchmarks << "#{label}: %.2fms" % t
          payload["#{label.downcase}_runtime"] = t
          subscriber_class.send(:reset_runtime)
        end
      end

      msg = "Completed #{request.request_method} #{ CGI.unescape(request.url)} #{status}"
      msg << " in %.2fms" % time_cost
      msg << " ("
      msg << benchmarks.join(' | ')
      msg << ") "

      payload[:method] = request.request_method
      payload[:url] = CGI.unescape(request.url)
      uri = URI(request.url)
      payload[:host] = uri.host
      payload[:path] = uri.path
      payload[:query] = uri.query

      payload[:status_code] = status
      payload[:duration] = time_cost
      payload[:header] = header
      payload[:request_id] = Thread.current[:request_id]
      if status >= 400
        payload[:body] = body
        body_str = ""
        if body.respond_to? :each
          body.each do |b|
            body_str << b.to_s
          end
        else
          body_str = body.inspect
        end
        msg << "body: #{body_str}"
        msg << "\n\n"
        logger.error msg
      else
        msg << "\n\n"
        logger.info msg
      end
      if defined? ActiveSupport
        ActiveSupport::Notifications.instrument "process.rack_logger", payload
      end
    end
  end
end
