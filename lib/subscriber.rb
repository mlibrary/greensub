# frozen_string_literal: true

class Subscriber
  attr_accessor :id, :external_id
end

class Institution < Subscriber
  attr_accessor :name

  def initialize(id)
    @id=id
    @external_id = @id #unless we have a record that says otherwise....
    if get_keycard
      #stub
    else
      if $TESTING
          @name = "Fake College, Testing, HI"
      else
          print "Instituion name: "
          @name = gets.chomp
      end
    end

  end

  def get_keycard
    #stub
    return false
  end

end
