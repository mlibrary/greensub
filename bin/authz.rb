# frozen_string_literal: true

require 'bundler/setup'
require 'slop'
require_relative '../lib/product'
require_relative '../lib/subscriber'
require_relative '../lib/license'

begin
  opts = Slop.parse strict: true do |opt|
    opt.string '-p', '--product', 'product id', required: true
    opt.string '-s', '--subscriber', 'subscriber id (institution)'
    opt.string '-f', '--file', 'file with a list of subscriber ids'
    opt.string '-l', '--license', 'Type of license granted [full, read, none]. App will set a default based on product.'
    opt.bool   '-e', '--expire', 'Remove authorization'
    opt.bool   '-n', '--nomail', 'Suppress email to subscribers'
    opt.bool   '-i', '--instructions', 'Send instructions even for existing accounts (rare)'
    opt.bool   '-t', '--testing'
    opt.string '--name', 'Name of the institution'
    opt.string '--entityId', "entityId of the institution's Shibboleth entityId"
    opt.bool   '-h', '--help' do
      puts opts
    end
  end
rescue Slop::Error => e
  puts e
  puts 'Try -h or --help'
  exit
end

license = nil
if opts[:license]
  license = opts[:license].to_sym
  LICENSES = %i[full read none].freeze
  unless LICENSES.include?(license)
    puts "Option -l must use a valid license: #{LICENSES}"
    exit!(0)
  end
end

action = opts[:expire] || license == :none ? :expire : :authz
ENV['GREENSUB_TEST'] = opts[:testing] ? '1' : '0'
ENV['GREENSUB_NOMAIL'] = opts[:nomail] ? '1' : '0'

product = Product.new(opts[:product])

unless product.hosted?
  puts "Product #{opts[:product]} does not have a host, quitting...."
  exit!(0)
end

subscrs = []
if opts[:subscriber] && opts[:file]
  puts "Pick one argument, either -s or -f"
  puts opts
elsif opts[:subscriber]
  subscrs.push opts[:subscriber]
elsif opts[:file]
  File.foreach(opts[:file]) { |l| subscrs.push l.chomp }
else
  puts "No subscribers specified"
  exit!(0)
end

subscrs.each do |s|
  subscr = if s.include? '@'
             Individual.new(s)
           else
             Institution.new(s, opts[:name], opts[:entityId])
           end
  license_obj = License.new(product, subscr, type: license)
  case action
  when :expire
    license_obj.delete!
  when :authz
    license_obj.create!(opts[:instructions])
  end
end
