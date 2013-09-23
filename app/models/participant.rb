class Participant < ActiveRecord::Base
  # condensed form of name
  def name
    "#{self.first_name} #{self.last_name}"
  end

  # condensed form of address
  def address
    "#{self.address_line1} #{self.address_line2} #{self.city},#{self.state} #{self.zip}"
  end

end
