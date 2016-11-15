RSpec.shared_context 'user login' do
  before :each do
    account = FactoryGirl.create(:account)

    visit public_root_path
    click_on('Log in')
    within('#login_tab') do
      fill_in('Email', with: account.email)
      fill_in('Password', with: account.password)
      click_on('Login')
    end
  end
end

RSpec.shared_context 'researcher login' do
  before :each do
    user = User.find_by_netid('test_user')
    user = FactoryGirl.create(:user, netid: 'test_user') unless user
    user.researcher   = true
    user.admin        = false
    user.data_manager = false
    user.save!

    visit new_user_session_path
    fill_in('NetID', with: user.netid)
    fill_in('Password', with: 'hello')
    click_on('Log in')
  end
end

RSpec.shared_context 'admin login' do
  before :each do
    user = User.find_by_netid('test_user')
    user = FactoryGirl.create(:user, netid: 'test_user') unless user
    user.researcher   = false
    user.admin        = true
    user.data_manager = false
    user.save!

    visit new_user_session_path
    fill_in('NetID', with: user.netid)
    fill_in('Password', with: 'hello')
    click_on('Log in')
    expect(page).to have_content('Signed in')
  end
end

RSpec.shared_context 'data manager login' do
  before :each do
    user = User.find_by_netid('test_user')
    user = FactoryGirl.create(:user, netid: 'test_user') unless user
    user.researcher   = false
    user.admin        = false
    user.data_manager = true
    user.save!

    visit new_user_session_path
    fill_in('NetID', with: user.netid)
    fill_in('Password', with: 'hello')
    click_on('Log in')
  end
end