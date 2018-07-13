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
    version = "5.0.0.1"

    "Version #{version}"
  end

  def display_participant_header(state, count)
    state.blank? ? "All Participants (#{count})" : "Participants #{state.titleize} (#{count})"
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

  def search_condition_group_operator_options
    options = []
    SearchConditionGroup.group_operators.each do |operator|
      operator_text = SearchConditionGroup.operator_text(operator[:symbol], Enum::Operator::GROUP_OPERATOR_TYPE)
      operator_display = operator_text == 'AND' ? 'All' : operator_text == 'OR' ? 'Any' : operator_text
      options << [operator_display, operator[:symbol]]
    end
    options
  end

  def question_operator_options(question)
    operator_type = SearchCondition.operator_type_for_question(question)
    SearchCondition.operators_by_type(operator_type).map{|o|[ SearchCondition.operator_text(o[:symbol], operator_type),o[:symbol], class: "#{o[:cardinality] ? 'operator-cardinality-' + o[:cardinality].to_s : ''}"]}
  end

  def search_condition_group_operator_class(search_condition_group)
    "nu-operator #{'text-info' if search_condition_group.is_or?} #{'text-success' if search_condition_group.is_and?}"
  end

  def recruiting_adults?
    Consent.adult_consent && Survey.adult_survey
  end

  def recruiting_children?
    Consent.child_consent && Survey.child_survey
  end

  def study_involvement_status_help
    html = '<small>'
    StudyInvolvementStatus.valid_statuses.each do |s|
      html << "<b>#{s[:name].titleize}</b>: #{s[:description]}<br/>"
    end
    html << '</small>'
    html.html_safe
  end

  def study_involvement_status_options
    StudyInvolvementStatus.valid_statuses.group_by{|h| h[:group]}.map{|k,v| [k, v.map{|s| [s[:name].titleize, s[:name]]}]}
  end

  def participant_contact_email_options(participant)
    contact_emails = Hash.new
    email                     = participant.email
    primary_guardian_email    = participant.primary_guardian_email
    secondary_guardian_email  = participant.secondary_guardian_email
    account_email             = participant.account.email if participant.account

    contact_emails["Self - #{email}"] = email if email.present?
    if primary_guardian_email.present?
      contact_emails["Primary Guardian - #{primary_guardian_email}"] = primary_guardian_email
    end
    if secondary_guardian_email.present?
      contact_emails["Secondary Guardian - #{secondary_guardian_email}"] = secondary_guardian_email
    end
    contact_emails["Account Email - #{account_email}"] = account_email if account_email.present?
    contact_emails
  end
end
