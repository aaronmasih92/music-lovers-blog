require "sinatra"
require "sinatra/activerecord"
require "sinatra/flash"
require "./models"
require "pry"

enable :sessions
configure :development do
  set :database, "sqlite3:app.db"
end

configure :production do
  set :database, ENV["DATABASE_URL"]
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


get "/sign-in" do
  erb :sign_in
end

post "/sign-in" do
  @user = User.find_by(username: params[:username])


  if @user && @user.password == params[:password]
    session[:user_id] = @user.id

    flash[:info] = "You have been signed in"

    redirect "/"
  else
    flash[:warning] = "Your username or password is incorrect"


    redirect "/sign-in"
  end
end


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

  session[:user_id] = @user.id

  flash[:info] = "Thank you for signing up"

  redirect "/"
end


get "/sign-out" do
  session[:user_id] = nil

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
    if post.user_id == User.find(session[:user_id]).id
      Post.destroy(post.id)
    end
  end
  User.destroy(session[:user_id])
  session[:user_id] = nil
  flash[:warning] = "Account Deleted."
  redirect "/"
end