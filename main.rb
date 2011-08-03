require 'sinatra'
require 'haml'
require 'aviary_fx'

get '/' do
  "Welcome to the home page. This was NOT made with haml."
end

get '/home' do
  haml :index
end

get '/layout' do
  redirect '/home'
end

get '/flip/:url' do |path|
  haml :show_photo, :locals => {:layout => true, :link => path}
end