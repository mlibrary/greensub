# frozen_string_literal: true

class Subscriber
  attr_accessor :id, :external_id

  def initialize(id)
    @id = id
    @external_id = @id #unless we have a record that says otherwise....
  end
end

class Institution < Subscriber
  attr_accessor :name
end
