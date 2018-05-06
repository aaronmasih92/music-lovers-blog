require "sinatra"
require "sinatra/activerecord"
require "sinatra/flash"
require "./models"
require "pry"

enable :sessions

configure :development do
set :database, "postgres:app.db"
end




get "/" do
  if session[:user_id]
      	@posts = User.find(session[:user_id]).posts
      @username = User.find(session[:user_id])
    erb :signed_in_homepage
  else
    erb :signed_out_homepage
  end
end


# displays sign in form
get "/sign-in" do
  erb :sign_in
end

# responds to sign in form
post "/sign-in" do
  @user = User.find_by(username: params[:username])

  # checks to see if the user exists
  #   and also if the user password matches the password in the db
  if @user && @user.password == params[:password]
    # this line signs a user in
    session[:user_id] = @user.id

    # lets the user know that something is wrong
    flash[:info] = "You have been signed in"

    # redirects to the home page
    redirect "/"
  else
    # lets the user know that something is wrong
    flash[:warning] = "Your username or password is incorrect"

    # if user does not exist or password does not match then
    #   redirect the user to the sign in page
    redirect "/sign-in"
  end
end

# displays signup form
#   with fields for relevant user information like:
#   username, password
get "/sign-up" do
  erb :sign_up
end

post "/sign-up" do
  @user = User.create(
    username: params[:username],
    password: params[:password],
          bday: params[:bday],
    firstname: params[:firstname],
    lastname: params[:lastname],
      fav_artist: params[:fav_artist],
      instrument: params[:instrument]
  )

  # this line does the signing in
  session[:user_id] = @user.id

  # lets the user know they have signed up
  flash[:info] = "Thank you for signing up"

  # assuming this page exists
  redirect "/"
end

# when hitting this get path via a link
#   it would reset the session user_id and redirect
#   back to the homepage
get "/sign-out" do
  # this is the line that signs a user out
  session[:user_id] = nil

  # lets the user know they have signed out
  flash[:info] = "You have been signed out"
  
  redirect "/"
end

get "/post/:id" do
 @post = Post.find(params[:id])
    @user = @post.user
    erb :blog_post
end

post '/post' do
    @user = User.find(session[:user_id])
	@post = Post.create(title: params[:title], body: params[:body], user_id: session[:user_id])
	redirect '/'
end


get "/profile" do
    @user = User.find(session[:user_id])
    erb :profile
end

get "/community" do
	@posts = Post.all
    erb :community
end

post "/delete" do

  @posts = Post.all
  for post in @posts
    #delete all posts associated with user
    if post.user_id == User.find(session[:user_id]).id
      Post.destroy(post.id)
    end
  end
  User.destroy(session[:user_id])
  session[:user_id] = nil
  flash[:warning] = "Account Deleted."
  redirect "/"
end