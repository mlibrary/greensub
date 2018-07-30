# frozen_string_literal: true

class Subscriber
  attr_accessor :id, :external_id, :email

  def initialize(id)
    @id = id
    @external_id = @id #unless we have a record that says otherwise....
  end
end

class Institution < Subscriber
  attr_accessor :name
end

class Individual < Subscriber
  attr_accessor :lastname, :firstname, :phone

  def initialize(id)
    @email = id
    super(id)
  end
end
