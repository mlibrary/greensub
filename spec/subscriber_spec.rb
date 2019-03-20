# frozen_string_literal: true

require_relative '../lib/subscriber'

RSpec.describe Subscriber do
  context 'Institution' do
    ENV['GREENSUB_TEST'] = '1'

    before do
      # Don't print status messages during specs
      allow($stdout).to receive(:puts)
    end

    describe "Example Institution 1" do
      inst = Institution.new('111')
      it "has only an id" do
        expect(inst.id).to eq("111")
        expect(inst.name).to be_nil
        expect(inst.entity_id).to be_nil
      end
    end

    describe "Example Institution 2" do
      inst = Institution.new('2222', 'Test Univ')
      it "has an id and name" do
        expect(inst.id).to eq("2222")
        expect(inst.name).to eq("Test Univ")
        expect(inst.entity_id).to be_nil
      end
    end

    describe "Example Institution 3" do
      inst = Institution.new("33333", 'Test School 3', 'https://foo.edu/idp')
      it "has an id, name, and entity_id" do
        expect(inst.id).to eq('33333')
        expect(inst.name).to eq("Test School 3")
        expect(inst.entity_id).to eq('https://foo.edu/idp')
      end
    end
  end
end
