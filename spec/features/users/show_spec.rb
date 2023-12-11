require 'rails_helper'

RSpec.describe 'User show page', type: :feature do

  before(:each) do
    load_test_data
    specific_movie_response = File.read('spec/fixtures/specific_movie.json')
    starwars_response = File.read('spec/fixtures/starwars_collection.json')
    lotr_response = File.read('spec/fixtures/lotr_collection.json')

    stub_request(:get, "https://api.themoviedb.org/3/movie/11?api_key=#{Rails.application.credentials.tmdb[:key]}").
         with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Faraday v2.7.12'
           }).
         to_return(status: 200, body: starwars_response, headers: {})

    stub_request(:get, "https://api.themoviedb.org/3/movie/120?api_key=#{Rails.application.credentials.tmdb[:key]}").
         with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Faraday v2.7.12'
           }).
         to_return(status: 200, body: lotr_response, headers: {})
         
    stub_request(:get, "https://api.themoviedb.org/3/movie/268?api_key=#{Rails.application.credentials.tmdb[:key]}").
         with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Faraday v2.7.12'
           }).
         to_return(status: 200, body: specific_movie_response, headers: {})
    visit "/users/#{@user1.id}"
  end

  it "displays the user's name and 'Dashboard' at the top of the page" do
    expect(page).to have_content("#{@user1.name}'s Dashboard")
  end

  it "displays a 'Discover Movies' button" do
    expect(page).to have_button('Discover Movies')
  end

  it "displays a 'Discover Movies' movie links" do
    expect(page).to have_link('The Lord of the Rings: The Fellowship of the Ring')
    expect(page).to have_link('Star Wars')
  end

  it 'displays a section that lists viewing parties' do
    within('section.attending-parties') do
      expect(page).to have_css('h2', text: 'Attending Parties')
      expect(page).to have_content("Movie Title: The Lord of the Rings: The Fellowship of the Ring")
      expect(page).to have_content("Date and Time: Starts on 2023-09-01 at 11:00:00 UTC")
      expect(page).to have_content("Hosted By: Jerry")
      expect(page).to have_content("Other users attending: Tom Bob")
    end
    within('section.hosting-parties') do
      expect(page).to have_css('h2', text: 'Hosting Parties')
      expect(page).to have_content("Movie Title: Star Wars")
      expect(page).to have_content("Date and Time: Starts on 2023-08-01 at 10:00:00 UTC")
      expect(page).to have_content("Hosted By: Tom")
      expect(page).to have_content("Other users attending: Jerry Bob")
    end
  end

  it "can log in with valid credentials" do
    visit root_path

    click_on "User Sign In"

    expect(current_path).to eq(login_path)
    fill_in :name, with: @user1.name
    fill_in :password, with: @user1.password

    click_on "Log In"

    expect(current_path).to eq(root_path)

    expect(page).to have_content("Welcome, #{@user1.name}")
    expect(page).to_not have_content("Sign Up to Be a User")
  end

  it "cannot log in with bad credentials" do
    visit login_path
    
    fill_in :name, with: "Jojojojo"
    fill_in :password, with: "incorrect password"
  
    click_on "Log In"
  
    expect(current_path).to eq(login_path)
  
    expect(page).to have_content("Sorry, your credentials are bad.")
  end
end
