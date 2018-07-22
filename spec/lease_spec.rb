require 'date'
require_relative '../lib/lease'

RSpec.describe Lease do
  describe "Lease"
  lease = Lease.new(1, 'example')
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
