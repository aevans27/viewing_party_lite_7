class ViewingPartiesController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @user_parties = @user.user_parties
  end
  def new
    facade = MovieFacade.new
    @user = User.find(params[:user_id])
    @users = User.where("id != #{params[:user_id]}")
    @movie = facade.movie_details(params[:movid_id])
    @party = @user.parties.new
  end

  def create
    if current_user
      facade = MovieFacade.new
      @user = User.find(params[:user_id])
      @users = User.where("id != #{params[:user_id]}")
      @movie = facade.movie_details(params[:movid_id])
      if @movie[:runtime].to_i > params[:duration].to_i
        flash[:alert] = "Error: duration cannot be less that movie runtime"
        redirect_to "/users/#{@user.id}/movies/#{@movie[:id]}/viewing-party/new"
      else
        @party = @user.parties.new(movie_id: @movie[:id], movie_title: @movie[:title], duration: params[:duration], date: params[:date], start_time: params[:start_time])
        if @party.save
          @user.user_parties.create!(user_id: @user.id, party_id: @party.id, is_host: true)
          @users.each do |other_user|
          if params[:"#{other_user.id}"].present?
            other_user.user_parties.create!(party_id: @party.id, accepted: false) 
          end
        end
          redirect_to user_path(@user.id)
        else
          flash[:alert] = "Error: something is wrong with credentials"
          redirect_to "/users/#{@user.id}/movies/#{@movie[:id]}/viewing-party/new"
        end
      end
    else
      flash[:error] = "Sorry, you must be signed in to register event."
      redirect_to root_path
    end
  end

  def accept_invite
    user_party = UserParty.find_by(user_id: params[:user_id], party_id: params[:party_id])
    user_party.update(accepted: true)
    redirect_to user_path(params[:user_id])
  end
end