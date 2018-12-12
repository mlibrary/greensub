require 'slop'
require_relative '../lib/product'
require_relative '../lib/leasefeed'

begin
  opts = Slop.parse strict: true do |opt|
    opt.string '-p', '--product', 'product id', required: true
    opt.bool   '-n', '--nomail', 'suppress sending emails to subscribers'
    opt.bool   '-t', '--testing'
    opt.bool   '-h', '--help' do
      puts opts
    end
  end
rescue Slop::Error => e
  puts e
  puts 'Try -h or --help'
  exit
end

ENV['GREENSUB_TEST'] = opts[:testing] ? '1' : '0'
ENV['GREENSUB_NOMAIL'] = opts[:nomail] ? '1' : '0'


product = Product.new( opts[:product] )

if ENV['GREENSUB_TEST']=='1'
  feed = TestLeaseFeed.new(product)
  puts "TESTING"
else
  feed = HEBLeaseFeed.new(product)
end

feed.fetch
feed.parse
