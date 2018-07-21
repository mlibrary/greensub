# frozen_string_literal: true

class Subscriber
  attr_accessor :id, :external_id
end

class Institution < Subscriber
  attr_accessor :name

  def initialize(id)
    @id=id
    @external_id = @id #unless we have a record that says otherwise....
    get_keycard
  end

  def get_keycard
    #stub
  end

end
