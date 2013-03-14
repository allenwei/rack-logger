require "rack_logger/version"

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
      status, header, body = @app.call(env)
      # million seconds
      time_cost = (Time.now - time_start) * 1000
      header["x-runtime"] = "%.2fms" % time_cost

      [status, header, body]
    ensure
      benchmarks = []

      time_cost ||= (Time.now - time_start) * 1000

      log_subscribers.each do |subscriber|
        label = subscriber[:label]
        subscriber_class = subscriber[:class]

        if t = subscriber_class.send(:runtime)
          benchmarks << "#{label}: %.2fms" % t
          subscriber_class.send(:reset_runtime)
        end
      end

      msg = "Completed #{request.request_method} #{ CGI.unescape(request.url)} #{status}"
      msg << " in %.2fms" % time_cost
      msg << " ("
      msg << benchmarks.join(' | ')
      msg << ") "
      if status >= 400
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
    end
  end
end
