# frozen_string_literal: true

class Subscriber
  attr_accessor :id, :external_id, :email

  def initialize(id)
    @id = id
    @external_id = @id #unless we have a record that says otherwise....
  end
end

class Institution < Subscriber
  attr_accessor :name, :entity_id

  def initialize(id, name=nil, entity_id=nil)
    @name = name
    @entity_id = entity_id
    super(id)
  end
end

class Individual < Subscriber
  attr_accessor :lastname, :firstname, :phone

  def initialize(id)
    @email = id
    super(id)
  end
end
