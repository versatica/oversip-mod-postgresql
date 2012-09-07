require "oversip-mod-postgresql/version.rb"

require "em-synchrony/pg"  # NOTE: Included in em-pg-client/lib/.


module OverSIP
  module Modules

    module Postgresql

      extend ::OverSIP::Logger

      DEFAULT_POOL_SIZE = 10

      @log_id = "Postgresql module"
      @pools = {}

      def self.add_pool options
        raise ::ArgumentError, "`options' must be a Hash"  unless options.is_a? ::Hash

        pool_name = options.delete(:pool_name)
        pool_size = options.delete(:pool_size) || DEFAULT_POOL_SIZE

        raise ::ArgumentError, "`options[:pool_name]' must be a Symbol"  unless pool_name.is_a? ::Symbol
        raise ::ArgumentError, "`options[:pool_size]' must be a positive Fixnum"  unless pool_size.is_a? ::Fixnum and pool_size > 0

        # Forcing DB autoreconnect.
        # TODO: It does not work due to a bug: https://github.com/royaltm/ruby-em-pg-client/issues/9
        # Workaround below and within the block below.
        #db_data[:async_autoreconnect] = true
        # Workaround:
        option_query_timeout = options[:query_timeout]
        option_on_autoreconnect = options[:on_autoreconnect]

        block = Proc.new  if block_given?

        OverSIP::SystemCallbacks.on_started do
          log_info "Adding PostgreSQL connection pool (name: #{pool_name.inspect}, size: #{pool_size})..."
          @pools[pool_name] = ::EM::Synchrony::ConnectionPool.new(size: pool_size) do
            conn = ::PG::EM::Client.new(options)

            # NOTE: Workarounds for https://github.com/royaltm/ruby-em-pg-client/issues/9.
            conn.async_autoreconnect = true
            conn.query_timeout = option_query_timeout  if option_query_timeout
            conn.on_autoreconnect = option_on_autoreconnect  if option_on_autoreconnect

            block.call(conn)  if block
            conn
          end
        end
      end

      def self.pool pool_name
        pool = @pools[pool_name]
        raise ::ArgumentError, "no pool with `name' #{pool_name.inspect}"  unless pool
        pool
      end
      class << self
        alias :get_pool :pool
      end

    end  # module Postgresql

  end
end
