# frozen_string_literal: true

require_relative '../lib/host'
require 'uri'

RSpec.describe Host do
  ENV['GREENSUB_TEST'] = '1'

  before do
    # Don't print status messages during specs
    allow($stdout).to receive(:puts)
  end

  describe "Example Test Host" do
    example = described_class.new('example')
    it "has a base_uri" do
      expect(example.base_uri).to eq("https://test.example.com")
    end
    it "has a base_uri that is an https URL" do
      uri = URI(example.base_uri)
      expect(uri.scheme).to eq("https")
    end
    it "has a token" do
      expect(example.token).to eq("test.foo.bar.baz")
    end
    helio = described_class.new('heliotrope')
    describe "Heliotrope" do
      it "responds to connection" do
        expect(helio.connection).to be_truthy
      end
    end
    it "can find NOID by DOI" do
      expect(helio.find_component_external_ids_by_identifier('10.3998/mpub.192640').length).to eq(1)
      expect(helio.find_component_external_ids_by_identifier('10.3998/mpub.192640').any?{|h| h['id'] == 'kw52j9144' }).to eq(true)
    end
    it "can find NOID by DOI URL" do
      expect(helio.find_component_external_ids_by_identifier('https://doi.org/10.3998/mpub.192640').length).to eq(1)
      expect(helio.find_component_external_ids_by_identifier('https://doi.org/10.3998/mpub.192640').any?{|h| h['id'] == 'kw52j9144' }).to eq(true)
    end
    it "can find a NOID by ISBN (with dashes)" do
      expect(helio.find_component_external_ids_by_identifier('978-0-472-05122-9').length).to eq(1)
      expect(helio.find_component_external_ids_by_identifier('978-0-472-05122-9').any?{|h| h['id'] == 'kw52j9144' }).to eq(true)
    end
    it "can find a NOID by ISBN (without dashes)" do
      expect(helio.find_component_external_ids_by_identifier('9780472051229').length).to eq(1)
      expect(helio.find_component_external_ids_by_identifier('9780472051229').any?{|h| h['id'] == 'kw52j9144' }).to eq(true)
    end
    it "can find a NOID by other identifer" do
      expect(helio.find_component_external_ids_by_identifier('ahab90909').length).to eq(1)
      expect(helio.find_component_external_ids_by_identifier('ahab90909').any?{|h| h['id'] == 'kw52j9144' }).to eq(true)
    end
    it "can find a NOID by other identifer" do
      expect(helio.find_component_external_ids_by_identifier('bar_number:S241').length).to eq(1)
      expect(helio.find_component_external_ids_by_identifier('bar_number:S241').any?{|h| h['id'] == 'hd76s0609' }).to eq(true)
    end
    it "returns multiple NOIDS if they match the query" do
      expect(helio.find_component_external_ids_by_identifier('9780520275140').length).to eq(2)
      expect(helio.find_component_external_ids_by_identifier('9780520275140').any?{|h| h['id'] == '8049g518t' }).to eq(true)
      expect(helio.find_component_external_ids_by_identifier('9780520275140').any?{|h| h['id'] == '8g84mm284' }).to eq(true)
     end
  end



  describe "Known bad host" do
    it "fails gracefully if there's no data on the requested host" do
      # How to test this without abort interrupting further tests?
    end
  end
end
