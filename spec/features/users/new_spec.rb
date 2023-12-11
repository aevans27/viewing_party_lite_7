require 'rails_helper'

RSpec.describe 'User Registration', type: :feature do
  before(:each) do
    load_test_data
  end

  it 'displays a registration form when visiting the "/register" path' do
    visit '/register'
    expect(page).to have_field('Name')
    expect(page).to have_field('Email')
    expect(page).to have_field('Password')
    expect(page).to have_button('Register')
  end

  it 'redirects to the user dashboard page after successful registration' do
    visit '/register'
    fill_in 'Name', with: 'John Doe'
    fill_in 'Email', with: 'john@example.com'
    fill_in 'Password', with: 'Sooners!2022'
    fill_in 'Check', with: 'Sooners!2022'
    click_button 'Register'
    user = User.find_by(email: 'john@example.com')
    expect(current_path).to eq("/users/#{user.id}")
  end

  it 'redirects user to create user page if bad data is entered' do
    visit '/register'
    fill_in 'Email', with: 'john@example.com'
    fill_in 'Password', with: 'Sooners!2022'
    fill_in 'Check', with: 'Sooners'
    click_button 'Register'
    expect(current_path).to eq("/users")
  end

  it 'redirects user to create user page if non matching password is entered' do
    visit '/register'
    fill_in 'Name', with: 'John Doe'
    fill_in 'Email', with: 'john@example.com'
    fill_in 'Password', with: 'Sooners!2022'
    fill_in 'Check', with: 'Sooners'
    click_button 'Register'
    expect(current_path).to eq("/users")
  end
end