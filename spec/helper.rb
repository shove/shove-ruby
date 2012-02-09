$:.unshift(File.dirname(__FILE__) + "/../lib/")

require "shove"

if ENV["DEBUG"]
  require "net-http-spy"
  Net::HTTP.http_logger_options = {:trace => true, :verbose => true}
end
