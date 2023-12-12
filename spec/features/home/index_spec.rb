require 'rails_helper'

RSpec.describe 'Home', type: :feature do
  before(:each) do
    load_test_data
  end
  describe 'GET /' do
    it 'displays the title of the application' do
      visit '/'
      expect(page).to have_content('Viewing Party Lite')
    end

    it 'displays a button to create a new user' do
      visit '/'
      expect(page).to have_button('Create New User')
    end

    it 'displays a list of existing users only if signed in' do
      visit '/'
      expect(page).to_not have_link(@user1.name, href: user_path(@user1))
      expect(page).to_not have_link(@user2.name, href: user_path(@user2))
      
      click_on "User Sign In"
      expect(current_path).to eq(login_path)
      fill_in :name, with: @user1.name
      fill_in :password, with: @user1.password
      click_on "Log In"
      
      expect(page).to have_content('Tom@a_website.com')
      expect(page).to have_content('Jerry@a_website.com')
    end

    it 'displays a link to go back to the landing page' do
      visit '/'
      expect(page).to have_link('Go back to Landing Page', href: root_path)
    end
  end
end
