# frozen_string_literal: true

require_relative '../lib/greensub'

RSpec.describe Greensub do
  before do
    # Don't print status messages during specs
    allow($stdout).to receive(:puts)
  end

  it "is alive" do
    expect(described_class).not_to be_nil
  end
end
