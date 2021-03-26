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
    test = described_class.new('example')
    it "has a base_uri" do
      expect(test.base_uri).to eq("https://test.example.com")
    end
    it "has a base_uri that is an https URL" do
      uri = URI(test.base_uri)
      expect(uri.scheme).to eq("https")
    end
    it "has a token" do
      expect(test.token).to eq("test.foo.bar.baz")
    end
    describe "Heliotrope" do
      helio = described_class.new('heliotrope')
      it "responds to connection" do
        expect(helio.connection).to be_truthy
      end
    end
    it "can find NOID by DOI" do
      expect(test.get_external_id_by_query('10.3998/mpub.192640')).to eq('kw52j9144')
    end
    it "can find NOID by DOI URL" do
        expect(test.get_external_id_by_query('https://doi.org/10.3998/mpub.192640')).to eq('kw52j9144')
    end
    it "can find a NOID by ISBN (with dashes)" do
      expect(test.get_external_id_by_query('978-0-472-05122-9')).to eq('kw52j9144')
    end
    it "can find a NOID by ISBN (without dashes)" do
      expect(test.get_external_id_by_query('9780472051229')).to eq('kw52j9144')
    end
    it "can find a NOID by other identifer" do
      expect(test.get_external_id_by_query('ahab90909')).to eq('kw52j9144')
    end
    it "knows what to do when multiple NOIDS match the query" do

    end
  end



  describe "Known bad host" do
    it "fails gracefully if there's no data on the requested host" do
      # How to test this without abort interrupting further tests?
    end
  end
end
