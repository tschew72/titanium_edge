require 'dashing'
require 'omniauth-twitter'



class SinatraWardenExample < Sinatra::Application


configure do
  #enable :sessions
  use Rack::Session::Pool, :expire_after => 2592000


  use OmniAuth::Builder do
     provider :twitter, 'j8KO3MW7efn9wxfVbTXDa07rH', 'R43vCtJoG5ef5yuALRbJItgC6XCG9kNs3rnFoFqFryk6AShHOS'
  end
end
 
helpers do

  def current_user
     !session[:uid].nil?
  end
end
 

 before do
   pass if request.path_info =~ /^\/auth\//
   #Not sure why if I put this redirect statement, everything won't work.
   #redirect to('/auth/twitter') unless current_user 

 end

get '/' do
  "This is the main page with the Login button"

end
 
get '/edge' do
  if current_user
    erb :edge, :locals => {:loginemail => "tschew@gmail.com", :name => "Vince Chew"}
  else
    redirect to('/auth/twitter')
  end
end

 
get '/logout' do
  !session[:uid]=nil
  redirect to('/')
end

get '/auth/twitter/callback' do
  session[:uid] = env['omniauth.auth']['uid']
  session[:username] = env['omniauth.auth']['info']['name']
  # "<h1>Hi #{session[:username]}!</h1>"
  
  #####
  #This is how to pass parameters to the URL
  #newname = "/edge?Name=" + session[:username].to_s
  #redirect to(newname)
  #####
  redirect to('/edge')
  
end

get '/auth/failure' do
  "Problem!"
end

end

map SinatraWardenExample.assets_prefix do
  run SinatraWardenExample.sprockets
end
    
    
run SinatraWardenExample