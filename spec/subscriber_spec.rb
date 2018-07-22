# frozen_string_literal: true

require_relative '../lib/subscriber'

RSpec.describe Institution do
  ENV['GREENSUB_TEST'] = '1'
  describe "Example Institution" do
    inst = Institution.new('123')
    it "has an id" do
      expect(inst.id).to eq("123")
    end
  end
end
