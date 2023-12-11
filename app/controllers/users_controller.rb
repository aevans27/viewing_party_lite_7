class UsersController < ApplicationController 
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if params[:user][:password] == params[:user][:check]
      if @user.save
        redirect_to user_path(@user)
      else
        flash[:alert] = "Error: something is wrong with credentials"
        render :new
      end
    else
      flash[:alert] = "Error: passwords need to match"
      render :new
    end
  end

  def show 
    facade = MovieFacade.new
    @user = User.find(params[:id])
    @movies = []
    @user.parties.uniq.each do |party|
      @movies << facade.movie_details(party.movie_id)
      @movies
    end
  end

  def login_form

  end

  def login
    @user = User.find_by(name: params[:name])
    if @user.present? && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      flash[:success] = "Welcome, #{@user.name}!"
      redirect_to root_path
    else
      flash[:error] = "Sorry, your credentials are bad."
      render :login_form
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_check)
  end
end
