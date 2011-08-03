require 'sinatra'
require 'haml'
require 'aviary_fx'

get '/' do
  haml :load_photo, :locals => {:font_color => '', :instruction => "Enter a URL"}
end

get '/error' do
  haml :load_photo, :locals => {:font_color => "color:red", :instruction => "You must enter a valid URL"}
end

get /\/flip\/?/ do
  redirect '/'
end

#currently only accepts valid URLs
post /\/flip\/?/ do
  @url = params[:url]
  
  # ASSUMES secret.txt is of form
  # key
  # secret_key
  # EOF
  secret = File.new('secret.txt', 'r')
  key = secret.gets.to_s.strip
  secret_key = secret.gets.to_s.strip
  secret.close
  
  afx = AviaryFX::API.new(key, secret_key)
  if @url == nil.to_s
    redirect '/error'
  end
  
  # response = afx.upload(@url)# rescue {:url => nil}
  old_url = @url#response[:url]
  
  render_parameters = '{
     "parameters":  [
       { "id" : "Scale Factor", "value" : "1"},
       { "id" : "Rotation in Degrees", "value" : "0"},
       { "id" : "Crop Left", "value" : "0"},
       { "id" : "Crop Right", "value" : "0"},
       { "id" : "Crop Top", "value" : "0"},
       { "id" : "Crop Bottom", "value" : "0"},
       { "id" : "Background Color", "value" : "0"},
       { "id" : "Flip Horizontal", "value" : "1"},
       { "id" : "Flip Vertical", "value" : "0"},
       { "id" : "Use Proportional Cropping", "value" : "0"},
       { "id" : "Cropping Proportions", "value" : "1"},
       { "id" : "Preserve Original Orientation", "value" : "1"}
     ]
  }'
  rpc = AviaryFX::RenderParameterCollection.new_from_json(render_parameters)
  
  response = afx.render("0xFFFFFFFF", 'png', '0', '1.0', old_url, "29", "0", "0", rpc)
  new_url = response[:url]
  
  haml :show_photo, :locals => {:layout => true, :link => @url, :new_image => new_url, :old_image => old_url}
end