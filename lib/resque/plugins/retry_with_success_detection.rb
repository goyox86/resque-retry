module Resque
  module Plugins
    module RetryWithSuccessDetection
      include Resque::Plugins::Retry

      def on_failure_notify(e, *args)
        puts "I failed! #{self.inspect} on retry_attempt: #{retry_attempt}"
        if respond_to?(:retry_limit_reached?) && retry_limit_reached?
          clear_retry_count(*args)
          raise Resque::RetryLimitReachedWithoutSuccess.new "Job #{self.inspect}:#{self.object_id} has finished it's retry stategy without any success."
        end
      end
    private
      def clear_retry_count(*args)
        Resque.redis.del(redis_retry_key(*args))
      end
    end
  end
end