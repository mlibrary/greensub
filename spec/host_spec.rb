#frozen_string_literal: true

require 'Host'

RSpec.describe Host do
  describe "Example Test Host" do
    test = Host.new('example','test')
    it "has a base_uri" do
      expect(test.base_uri).to eq("test.example.com")
    end
    it "has a token" do
      expect(test.token).to eq("test.foo.bar.baz")
    end
  end
end
