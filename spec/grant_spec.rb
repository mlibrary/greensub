# frozen_string_literal: true

require 'date'
require_relative '../lib/grant'
require_relative '../lib/subscriber'
require_relative '../lib/product'
require_relative '../lib/host'

RSpec.describe Grant do
  ENV['GREENSUB_TEST'] = '1'
  ENV['GREENSUB_NOMAIL'] = '1'

  heb = Product.new('heb')
  entity_id = 'https://foo.edu/idp'

  random = rand(100_000..199_999)
  inst_id = "test_inst_#{random}"
  inst_name = "Test Institution #{inst_id}"
  inst = Institution.new(inst_id, inst_name, entity_id)
  inst_grant = described_class.new(heb, inst)

  random = rand(100_000..199_999)
  inst_id = "test_inst_#{random}"
  inst_name = "Test Institution #{inst_id}"
  inst2 = Institution.new(inst_id, inst_name, entity_id)
  inst2_grant = described_class.new(heb, inst2, :read)

  before do
    # Don't print status messages during specs
    #allow($stdout).to receive(:puts)
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    inst_grant.product.host.delete_subscriber(inst_grant.subscriber)
    inst2_grant.product.host.delete_subscriber(inst2_grant.subscriber)
  end

  describe "for Institution" do
    it "is active and defaults to a full license" do
      expect(inst_grant.create!).to be true
      expect(heb.host.get_product_subscriber_license(heb,inst)).to eq(:full)
    end
    it "makes sure the Institution exists on host" do
      expect(inst_grant.product.host.knows_institution?(inst_grant.subscriber)).to be(true)
    end
    it "is active and has a :read license" do
      expect(inst2_grant.create!).to be true
      expect(heb.host.get_product_subscriber_license(heb,inst2)).to eq(:read)
    end
  end

  describe "A new individual subscription" do
    prod = Product.new('heb')
    data = YAML.load_file('config/tests.yaml')
    ENV['GREENSUB_NOMAIL'] = '0'
    indiv_id = data['subscribers']['individual']['email']
    indiv = Individual.new(indiv_id)
    indiv_grant = described_class.new(prod, indiv)
    it "recognizes when a subscriber is new" do
      indiv_grant.expire!
      prod.host.delete_subscriber(indiv)
      expect(prod.host.knows_subscriber?(indiv)).to be(false)
      indiv_grant.create!
      expect(indiv_grant.is_new_subscriber).to be(true)
    end
  end
end
