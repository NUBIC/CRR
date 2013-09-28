class ContactLog < ActiveRecord::Base
  belongs_to :participant

  MODES=['phone','email','in_persion','mail']
end
