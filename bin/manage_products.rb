require 'bundler/setup'
require 'slop'
require_relative '../lib/product'
require_relative '../lib/subscriber'
require_relative '../lib/lease'

begin
  opts = Slop.parse strict: true do |opt|
    opt.string '-p', '--product', 'Product Identifier', required: true
    opt.string '--pname', 'Name of the Product'
    opt.string '-u', '--url', 'Purchase URL for Product'
    opt.string '-a', '--action', 'Action to perform'
    opt.string '-s', '--subscriber', 'subscriber id (institution)'
    opt.string '-f', '--file', 'file with a list of component ids'
    opt.bool   '-t', '--testing'
    opt.string '-c', '--component', 'Component Identifier'
    opt.string '-n', '--noid', 'NOID of the Component Monograph'
    opt.string '--sales_id', 'sales ID of the Component Monograph'
    opt.string '--cname', 'Name of the Component'
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


product = Product.new(opts[:product]) if opts[:product]
component = Component.new(opts[:component]) if opts[:component]
unless product.hosted?
  puts "Product #{opts[:product]} does not have a host, quitting...."
  exit!(0)
end

rows = []
if opts[:file]
  File.foreach(opts[:file]) { |l| rows.push l.chomp }
end

action = opts[:action]
case action
when 'exists'
  if product
    product.hosted?
  elsif component
    component.hosted?
  end
when 'list_components'
  puts product.list_components
when 'list_institutions'
  puts product.list_institutions
when 'component_info'
  if opts[:file]
    puts "got a file"
    File.foreach(opts[:file]) { |l| rows.push l.chomp }
  elsif opts[:noid]
    rows.push "#{opts[:noid]},#{opts[:sales_id]}"
  else
    abort "No component ID to check"
  end
  rows.each do |r|
    fields = r.split(/[,\s]+/) # handle both tabs and commas
    id = fields[0].tr_s('"', '').tr_s("''", '').strip
    sales_id = fields[1].tr_s('"', '').tr_s("''", '').strip
    component = Component.new(id, sales_id, Product)
    begin
      puts "#{id} (#{sales_id}): " , product.host.knows_component?(component)
    rescue StandardError => e
      STDERR.puts e.message
    end
  end
when 'add'
  if condition

  else

  end
end
