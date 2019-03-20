# frozen_string_literal: true

class Subscriber
  private_class_method :new

  attr_accessor :id, :external_id

  private

    def initialize(id)
      @id = id
      @external_id = @id # unless we have a record that says otherwise....
    end
end

class Institution < Subscriber
  public_class_method :new

  attr_accessor :name, :entity_id

  def initialize(id, name = nil, entity_id = nil)
    super(id)
    @name = name
    @entity_id = entity_id
  end
end

class Individual < Subscriber
  public_class_method :new

  attr_accessor :lastname, :firstname, :phone, :email

  def initialize(id)
    super(id)
    @email = id
  end
end
