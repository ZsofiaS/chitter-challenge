require 'sinatra/base'
require './lib/peep'
require './lib/user'
require 'sinatra/flash'
require 'rack_session_access'

class Chitter < Sinatra::Base

  enable :sessions
  use RackSessionAccess::Middleware if environment == :test
  register Sinatra::Flash

  get '/' do
    'Hello World!'
  end

  get '/peeps' do
    p @user = User.find(id: session[:user_id])
    @peeps = Peep.all
    erb :'peeps'
  end

  get '/peeps/new' do
    erb :'new'
  end

  post '/peeps/new' do
    Peep.create(author: session[:username], content: params[:content])
    redirect '/peeps'
  end

  get '/users/new' do
    erb :'users/new'
  end

  post '/users' do
    user = User.create(email: params[:email], password: params[:password], name: params[:name], username: params[:username])
    session[:user_id] = user.id
    session[:username] = user.username
    redirect '/peeps'
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  post '/sessions' do
    session[:username] = params[:username]
    user = User.authenticate(username: params[:username], password: params[:password])
    if user
      session[:user_id] = user.id
      redirect '/peeps'
    else
      flash[:notice] = "Your username or password is incorrect."
      redirect '/sessions/new'
    end
  end

  run! if app_file == $0
end