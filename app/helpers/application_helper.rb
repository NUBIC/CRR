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
    version = "1.2.rc10"

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
    elsif state = "data_released"
      current_user.admin? ? "Data Released (#{Search.released.count})" : "Data Released (#{Search.with_user(current_user.ar_user).released.count})"
    end
  end
end
