require 'rails_helper'

RSpec.describe 'New Viewing Party Page' do 
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
  end

  it 'When I visit the new viewing party page it contains movie title, duration of party, when date, start time, checkboxes next to each user' do
    visit root_path

    click_on "User Sign In"

    expect(current_path).to eq(login_path)
    fill_in :name, with: @user1.name
    fill_in :password, with: @user1.password

    click_on "Log In"
    visit "/users/#{@user1.id}/movies/268/viewing-party/new"
    expect(page).to have_field(:duration, with:126)
    expect(page).to have_field(:date)
    expect(page).to have_field(:start_time)
    expect(page).to have_button('Create Party')
    expect(page).to have_content('Batman')

    expect(@user2.user_parties.count).to eq(3)
    expect(@user3.user_parties.count).to eq(2)

    fill_in :duration, with: 180
    fill_in :start_time, with: '10:00'
    fill_in :date, with: '2023/08/01'
    check "#{@user2.name} (#{@user2.email})"
    check "#{@user3.name} (#{@user3.email})"
    click_button 'Create Party'

    expect(current_path).to eq(user_path(@user1.id))
  end

  it 'sad path for creating a party: Bad data' do
    visit '/'
         
    click_on "User Sign In"
    expect(current_path).to eq(login_path)
    fill_in :name, with: @user1.name
    fill_in :password, with: @user1.password
    click_on "Log In"  

    visit "/users/#{@user1.id}/movies/268/viewing-party/new"
    expect(page).to have_field(:duration, with:126)
    expect(page).to have_field(:date)
    expect(page).to have_field(:start_time)
    expect(page).to have_button('Create Party')
    expect(page).to have_content('Batman')

    expect(@user2.user_parties.count).to eq(3)
    expect(@user3.user_parties.count).to eq(2)

    check "#{@user2.name} (#{@user2.email})"
    check "#{@user3.name} (#{@user3.email})"
    click_button 'Create Party'

    expect(current_path).to eq("/users/#{@user1.id}/movies/268/viewing-party/new")
  end

  it 'sad path for creating a party: Bad duration' do
    visit '/'
         
         click_on "User Sign In"
         expect(current_path).to eq(login_path)
         fill_in :name, with: @user1.name
         fill_in :password, with: @user1.password
         click_on "Log In"  

    visit "/users/#{@user1.id}/movies/268/viewing-party/new"
    expect(page).to have_field(:duration, with:126)
    expect(page).to have_field(:date)
    expect(page).to have_field(:start_time)
    expect(page).to have_button('Create Party')
    expect(page).to have_content('Batman')

    expect(@user2.user_parties.count).to eq(3)
    expect(@user3.user_parties.count).to eq(2)

    fill_in :duration, with: "2"
    fill_in :start_time, with: '10:00'
    fill_in :date, with: '2023/08/01'
    check "#{@user2.name} (#{@user2.email})"
    check "#{@user3.name} (#{@user3.email})"
    click_button 'Create Party'

    expect(current_path).to eq("/users/#{@user1.id}/movies/268/viewing-party/new")
  end

  it 'sad path for creating a party: Not signed in' do     
    visit "/users/#{@user1.id}/movies/268/viewing-party/new"
    expect(page).to have_field(:duration, with:126)
    expect(page).to have_field(:date)
    expect(page).to have_field(:start_time)
    expect(page).to have_button('Create Party')
    expect(page).to have_content('Batman')

    expect(@user2.user_parties.count).to eq(3)
    expect(@user3.user_parties.count).to eq(2)

    fill_in :duration, with: "2"
    fill_in :start_time, with: '10:00'
    fill_in :date, with: '2023/08/01'
    check "#{@user2.name} (#{@user2.email})"
    check "#{@user3.name} (#{@user3.email})"
    click_button 'Create Party'

    expect(current_path).to eq("/")
    expect(page).to have_content("Sorry, you must be signed in to register event.")
  end

  it 'sets accepted to false for invited users when a party is created' do
    visit "/users/#{@user1.id}/movies/268/viewing-party/new"

    fill_in :duration, with: 180
    fill_in :start_time, with: '10:00'
    fill_in :date, with: '2023/08/01'
    check "#{@user2.name} (#{@user2.email})"
    check "#{@user3.name} (#{@user3.email})"
    click_button 'Create Party'

    expect(UserParty.where(party_id: Party.last.id, user_id: @user2.id).first.accepted).to eq(false)
    expect(UserParty.where(party_id: Party.last.id, user_id: @user3.id).first.accepted).to eq(false)
  end

  it 'sets accepted to true for a user who accepts an invite' do
      def accept_invite(user, party)
        page.driver.submit :patch, "/users/#{user.id}/viewing-parties/#{party.id}/accept_invite", {}
      end
    accept_invite(@user2, Party.last)

    expect(UserParty.where(party_id: Party.last.id, user_id: @user2.id).first.accepted).to eq(true)
  end
end