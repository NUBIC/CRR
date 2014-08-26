module ApplicationHelper
  def us_states
    [
      ['AK', 'AK'],
      ['AL', 'AL'],
      ['AR', 'AR'],
      ['AZ', 'AZ'],
      ['CA', 'CA'],
      ['CO', 'CO'],
      ['CT', 'CT'],
      ['DC', 'DC'],
      ['DE', 'DE'],
      ['FL', 'FL'],
      ['GA', 'GA'],
      ['HI', 'HI'],
      ['IA', 'IA'],
      ['ID', 'ID'],
      ['IL', 'IL'],
      ['IN', 'IN'],
      ['KS', 'KS'],
      ['KY', 'KY'],
      ['LA', 'LA'],
      ['MA', 'MA'],
      ['MD', 'MD'],
      ['ME', 'ME'],
      ['MI', 'MI'],
      ['MN', 'MN'],
      ['MO', 'MO'],
      ['MS', 'MS'],
      ['MT', 'MT'],
      ['NC', 'NC'],
      ['ND', 'ND'],
      ['NE', 'NE'],
      ['NH', 'NH'],
      ['NJ', 'NJ'],
      ['NM', 'NM'],
      ['NV', 'NV'],
      ['NY', 'NY'],
      ['OH', 'OH'],
      ['OK', 'OK'],
      ['OR', 'OR'],
      ['PA', 'PA'],
      ['RI', 'RI'],
      ['SC', 'SC'],
      ['SD', 'SD'],
      ['TN', 'TN'],
      ['TX', 'TX'],
      ['UT', 'UT'],
      ['VA', 'VA'],
      ['VT', 'VT'],
      ['WA', 'WA'],
      ['WI', 'WI'],
      ['WV', 'WV'],
      ['WY', 'WY']
    ]
  end

  def app_version_helper
    version = "1.4.rc1"

    "Version #{version}"
  end

  def display_participant_header(state, count)
    state.blank? ? "All Participants (#{count})" : state == "approved" ? "Approved Participants (#{count})" : "Participants Pending Approval (#{count})"
  end

  def display_search_header(state)
    if state.blank?
      current_user.admin? ? "All Requests for Participants (#{Search.all.count})" : "All Requests for Participants (#{Search.with_user(current_user.ar_user).count})"
    elsif state == "data_requested"
      current_user.admin? ? "Data Requests (#{Search.requested.count})" : "Data Requests (#{Search.with_user(current_user.ar_user).requested.count})"
    elsif state == "data_released"
      current_user.admin? ? "Data Released (#{Search.released.count})" : "Data Released (#{Search.with_user(current_user.ar_user).released.count})"
    end
  end

  def display_address(participant)
    addr = [participant.address_line1, participant.address_line2].reject(&:blank?).join(', ').strip
    addr1 = [participant.city, participant.state, participant.zip].reject(&:blank?).join(' ').strip
    address = addr1.blank? ? addr.blank? ? '' : addr : addr << "<br />" << addr1
    address << "<br />" << participant.primary_phone unless participant.primary_phone.blank?
    address << "<br />" << participant.secondary_phone unless participant.secondary_phone.blank?
    address << "<br />" << participant.email unless participant.email.blank?
    address.html_safe
  end

  def display_primary_guardian(participant)
    primary_guardian_info = [participant.primary_guardian_first_name, participant.primary_guardian_last_name].join(' ')
    primary_guardian_info << "<br />" << participant.primary_guardian_phone unless participant.primary_guardian_phone.blank?
    primary_guardian_info << "<br />" << participant.primary_guardian_email unless participant.primary_guardian_email.blank?
    primary_guardian_info.html_safe
  end

  def display_secondary_guardian(participant)
    seconday_guardian_info = [participant.secondary_guardian_first_name, participant.secondary_guardian_last_name].join(' ')
    seconday_guardian_info << "<br />" << participant.secondary_guardian_phone unless participant.secondary_guardian_phone.blank?
    seconday_guardian_info << "<br />" << participant.secondary_guardian_email unless participant.secondary_guardian_email.blank?
    seconday_guardian_info.html_safe
  end

  def display_notes(participant)
    participant.notes.gsub(/\n/, '<br/>').html_safe unless participant.notes.blank?
  end
end
