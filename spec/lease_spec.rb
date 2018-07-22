require 'date'
require_relative '../lib/lease'
require_relative '../lib/subscriber'
require_relative '../lib/product'

RSpec.describe Lease do
  ENV['GREENSUB_TEST'] = '1'
  describe "Lease"
  lease = Lease.new(Product.new('heb'), Institution.new('1'))
  it "starts an open-ended lease when authorized" do
    lease.authorize
    expect(Date.parse(lease.starts)).to be <= Time.now.to_date
    expect(lease.expires).to be_nil
  end
  it "makes lease end today when expired" do
    lease.expire
    expect(Date.parse(lease.expires)).to eq(Time.now.to_date)
  end
  it "makes sure start date is not after expiration date" do
    lease.expire
    expect(Date.parse(lease.starts)).not_to be > Date.parse(lease.expires)
  end
end
