$:.unshift(File.dirname(__FILE__) + "/../lib/")

require "rubygems"
require "bundler/setup"

require "shove"
require "vcr"

if ENV["DEBUG"]
  require "net-http-spy"
  Net::HTTP.http_logger_options = {:trace => true, :verbose => true}
end

ENV["SHOVE_ENV"] = "development"

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  # so we can use `:vcr` rather than `:vcr => true`;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

# Queue for goodies
$queue = []

# Backdoor for sending data into the clients
# processing code... 
$backdoor = nil
def backdoor message
  $backdoor.call(Yajl::Encoder.encode(message))
end

# Mock Mock
module EM
  class WebSocketClient

    def initialize url, origin=nil
    end

    def connect
    end

    def onopen &block
      @onopen = block
    end

    def onmessage &block
      @onmessage = block
      $backdoor = block
      @onopen.call # called
    end

    def send_data data
      $queue << Yajl::Parser.parse(data)
    end

  end
end
