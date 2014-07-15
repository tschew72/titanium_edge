require 'dashing'




class SinatraWardenExample < Sinatra::Application


configure do
  #enable :sessions
  use Rack::Session::Pool, :expire_after => 2592000
  #@@firstname = ""
  #@@email = ""
end
 
helpers do

  def current_user
     !session[:uid].nil?
  end
end
 

 before do
   #pass if request.path_info =~ /^\/auth\//
   #Not sure why if I put this redirect statement, everything won't work.
   #redirect to('/auth/twitter') unless current_user 

 end

get '/' do
  "This is the main page with the Login button"
   redirect to('/auth/login')

end
 
get '/edge' do
    erb :edge, :locals => {:loginemail => params[:email], :name => params[:firstname] }

end
  get '/auth/login' do
    erb :login, :layout => :'auth_layout'
  end

  post '/auth/login' do
     email=params['user']['email']
     firstname=params['user']['firstname']
     #erb :edge, :locals => {:loginemail => email, :name => firstname}
     #erb :edge, :locals => {:loginemail => "tschew@gmail.com", :name => "Vince Chew Teck"}
      #####
      #This is how to pass parameters to the URL
      newurl = "/edge?firstname=" + firstname + "&email=" + email
      redirect to(newurl)
      #####
     #redirect '/edge'
  end
 
get '/logout' do
  !session[:uid]=nil
  redirect to('/')
end



get '/auth/failure' do
  "Problem!"
end

end

map SinatraWardenExample.assets_prefix do
  run SinatraWardenExample.sprockets
end
    
    
run SinatraWardenExample