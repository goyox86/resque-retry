module Resque
  module Plugins
    module RetryWithSuccessDetection
      include Resque::Plugins::Retry

      def on_failure_notify(e, *args)
        if retry_limit_reached?
          clear_retry_count(*args)
          retry_limit_reached_without_success = Resque::RetryLimitReachedWithoutSuccess.new "Job #{self.inspect}-#{self.object_id} has reached it's maximum retry_limit without any success.
                                                                                            Original Exception: #{e.class.to_s}-#{e.to_s}"
          retry_limit_reached_without_success.set_backtrace(e.backtrace)
          raise retry_limit_reached_without_success
        end
      end
    private
      def clear_retry_count(*args)
        Resque.redis.del(redis_retry_key(*args))
      end
    end
  end
end