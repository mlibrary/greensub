require 'date'
require_relative '../lib/lease'
require_relative '../lib/subscriber'
require_relative '../lib/product'

RSpec.describe Lease do
  ENV['GREENSUB_TEST'] = '1'
  ENV['GREENSUB_NOMAIL'] = '1'
  describe "Institutional Lease" do
  lease = Lease.new(Product.new('heb'), Institution.new('1'))
    it "is active if no start or end date is set" do
      lease.starts = nil
      lease.expires = nil
      expect(lease.active?).to eq(true)
    end
    it "is active if starts in the past and expires in the future " do
      lease.starts = Time.now.to_date.prev_day
      lease.expires = Time.now.to_date.next_day
      expect(lease.active?).to eq(true)
    end
    it "is active if we've reached start date but there's no expiration date " do
      lease.starts = Time.now.to_date
      lease.expires = nil
      expect(lease.active?).to eq(true)
    end
    it "is active if there's no start date and it expires in the futue " do
      lease.starts = nil
      lease.expires = Time.now.to_date.next_day
      expect(lease.active?).to eq(true)
    end
    it "is not active if expiration date is in the past and there's no start date" do
      lease.expires = Time.now.to_date.prev_day
      lease.starts = nil
      expect(lease.active?).to eq(false)
    end
    it "is not active if expiration date and start date are in the past" do
      lease.expires = Time.now.to_date.prev_day
      lease.starts = Time.now.to_date.prev_day
      expect(lease.active?).to eq(false)
    end
    it "is not active if start date is in the future and there's no expiration date" do
      lease.expires = nil
      lease.starts = Time.now.to_date.next_day
      expect(lease.active?).to eq(false)
    end
    it "is not active if start date is in the future and expiration date is in the past" do
      lease.expires = Time.now.to_date.prev_day
      lease.starts = Time.now.to_date.next_day
      expect(lease.active?).to eq(false)
    end
    it "is not active if expiration and start date are in the future" do
      lease.expires = Time.now.to_date.next_day
      lease.starts = Time.now.to_date.next_day
      expect(lease.active?).to eq(false)
    end
    it "starts an open-ended lease when authorized" do
      lease.authorize
      expect(lease.starts).to be <= Time.now.to_date
      expect(lease.expires).to be_nil
    end
    it "makes lease end today when expired" do
      lease.expire
      expect(lease.expires).to eq(Time.now.to_date)
    end
    it "makes sure start date is not after expiration date" do
      lease.expire
      expect(lease.starts).not_to be > lease.expires
    end
  end
  describe "A new indidiual subscription" do
    prod = Product.new('heb')
    data = YAML.load_file('config/tests.yaml')
    ENV['GREENSUB_NOMAIL'] = '0'
    indiv_id = data['subscribers']['individual']['email']
    indiv = Individual.new(indiv_id)
    lease = Lease.new(prod, indiv)
    it "recognizes when a subscriber is new" do
      lease.expire
      prod.host.delete_subscriber(indiv)
      expect(prod.host.knows_subscriber?(indiv)).to be(false)
      lease.authorize
      expect(lease.is_new_subscriber).to be(true)
    end
  end
end
