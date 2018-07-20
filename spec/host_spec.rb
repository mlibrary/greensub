#frozen_string_literal: true

require 'Host'
require 'uri'


RSpec.describe Host do
  describe "Example Test Host" do
    test = Host.new('example','test')
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
      helio = Host.new('heliotrope','test')
      it "responds to connection" do
        expect(helio.connection).to be_truthy
      end
    end
  end
end
