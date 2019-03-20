# frozen_string_literal: true

require 'date'
require_relative '../lib/lease'
require_relative '../lib/subscriber'
require_relative '../lib/product'
require_relative '../lib/host'

RSpec.describe Lease do
  ENV['GREENSUB_TEST'] = '1'
  ENV['GREENSUB_NOMAIL'] = '1'

  random = rand(100_000..199_999)
  inst_id = "test_inst_#{random}"
  inst_name = "Test Institution #{inst_id}"
  entity_id = 'https://foo.edu/idp'
  inst_lease = described_class.new(Product.new('heb'), Institution.new(inst_id, inst_name, entity_id))

  before do
    # Don't print status messages during specs
    allow($stdout).to receive(:puts)
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    inst_lease.product.host.delete_institution(inst_lease.subscriber)
    inst_lease.product.host.delete_subscriber(inst_lease.subscriber)
  end

  describe "Institutional Lease" do
    it "is active if no start or end date is set" do
      inst_lease.starts = nil
      inst_lease.expires = nil
      expect(inst_lease.active?).to eq(true)
    end
    it "is active if starts in the past and expires in the future " do
      inst_lease.starts = Time.now.to_date.prev_day
      inst_lease.expires = Time.now.to_date.next_day
      expect(inst_lease.active?).to eq(true)
    end
    it "is active if we've reached start date but there's no expiration date " do
      inst_lease.starts = Time.now.to_date
      inst_lease.expires = nil
      expect(inst_lease.active?).to eq(true)
    end
    it "is active if there's no start date and it expires in the futue " do
      inst_lease.starts = nil
      inst_lease.expires = Time.now.to_date.next_day
      expect(inst_lease.active?).to eq(true)
    end
    it "is not active if expiration date is in the past and there's no start date" do
      inst_lease.expires = Time.now.to_date.prev_day
      inst_lease.starts = nil
      expect(inst_lease.active?).to eq(false)
    end
    it "is not active if expiration date and start date are in the past" do
      inst_lease.expires = Time.now.to_date.prev_day
      inst_lease.starts = Time.now.to_date.prev_day
      expect(inst_lease.active?).to eq(false)
    end
    it "is not active if start date is in the future and there's no expiration date" do
      inst_lease.expires = nil
      inst_lease.starts = Time.now.to_date.next_day
      expect(inst_lease.active?).to eq(false)
    end
    it "is not active if start date is in the future and expiration date is in the past" do
      inst_lease.expires = Time.now.to_date.prev_day
      inst_lease.starts = Time.now.to_date.next_day
      expect(inst_lease.active?).to eq(false)
    end
    it "is not active if expiration and start date are in the future" do
      inst_lease.expires = Time.now.to_date.next_day
      inst_lease.starts = Time.now.to_date.next_day
      expect(inst_lease.active?).to eq(false)
    end
    xit "starts an open-ended lease when authorized" do
      inst_lease.authorize
      expect(inst_lease.starts).to be <= Time.now.to_date
      expect(inst_lease.expires).to be_nil
    end
    it "Makes sure the Institution exists on host" do
      expect(inst_lease.product.host.knows_institution?(inst_lease.subscriber)).to be(true)
    end
    it "makes lease end today when expired" do
      inst_lease.expire
      expect(inst_lease.expires).to eq(Time.now.to_date)
    end
    it "makes sure start date is not after expiration date" do
      inst_lease.expire
      expect(inst_lease.starts).not_to be > inst_lease.expires
    end
  end

  describe "A new individual subscription" do
    prod = Product.new('heb')
    data = YAML.load_file('config/tests.yaml')
    ENV['GREENSUB_NOMAIL'] = '0'
    indiv_id = data['subscribers']['individual']['email']
    indiv = Individual.new(indiv_id)
    indiv_lease = described_class.new(prod, indiv)
    xit "recognizes when a subscriber is new" do
      indiv_lease.expire
      prod.host.delete_subscriber(indiv)
      expect(prod.host.knows_subscriber?(indiv)).to be(false)
      indiv_lease.authorize
      expect(indiv_lease.is_new_subscriber).to be(true)
    end
  end
end
