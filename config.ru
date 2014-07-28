require 'dashing'
require 'bundler'

require 'warden'
require './model'

require 'httparty'
require 'json'
require 'roo'
require 'compass'


class SinatraWardenExample < Sinatra::Application

use Rack::Session::Pool, :expire_after => 2592000

 
use Warden::Manager do |config|

    # Tell Warden how to save our User info into a session.
    # Sessions can only take strings, not Ruby code, we'll store
    # the User's `id`
    config.serialize_into_session{|user| user.id }
    # Now tell Warden how to take what we've stored in the session
    # and get a User from that information.
    config.serialize_from_session{|id| User.get(id) }

    config.scope_defaults :default,
      # "strategies" is an array of named methods with which to
      # attempt authentication. We have to define this later.
      strategies: [:password],
      # The action is a route to send the user to when
      # warden.authenticate! returns a false answer. We'll show
      # this route below.
      action: 'auth/unauthenticated'
    # When a user tries to log in and cannot, this specifies the
    # app to send the user to.
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

 #Warden::Manager.before_failure do |env,opts|
 #   env['REQUEST_METHOD'] = 'POST'
 # end

  Warden::Strategies.add(:password) do
    def valid?
      params['user'] && params['user']['username'] && params['user']['password']
    end

    def authenticate!
      user = User.first(username: params['user']['username'])

      if user.nil?
        fail!("The username you entered does not exist.")
      elsif user.authenticate(params['user']['password'])
        success!(user)
      else
        fail!("Could not log in")
      end
    end
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
   # If user comes in directly here, if not authenticated, throw them to /auth/login
   redirect '/auth/login' unless env['warden'].authenticated?
       user1 = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = user1.firstname
       @emailme = user1.email
       @usermatchjoblist = user1.matched_jobs
       erb :edge
end


get '/summary' do
   redirect '/auth/login' unless env['warden'].authenticated?
       user1 = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = user1.firstname
       erb :summary
end


get '/profile' do
   redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       #@userme = @userprofile.firstname
       #@emailme = @userprofile.email
       @userskills= @userprofile.skilltags.all(:order => [:skillscore.desc])
       @skillname = Skill.all
       @jobhistory = @userprofile.jobs.all(:order => [:startdate.desc])
       erb :profile, :layout => :'profilelayout'
end


  get '/auth/login' do

   erb :login, :layout => :'auth_layout'
  end


  post '/auth/login' do 

    env['warden'].authenticate!
    if session[:return_to].nil?
      

       #@emailme = user1.email
       redirect '/edge'
       #erb :edge
    else
        #redirect session[:return_to]
    end

  end 
 





get '/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    redirect '/auth/login'
end



  post '/auth/unauthenticated' do
    #session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?
    #puts env['warden.options'][:attempted_path]
    #puts env['warden']
    redirect '/auth/login'

  end

  post '/updateprofile' do
    userdata = User.get(params["pk"])
    userdata.update(eval(":#{params['name']}") => params["value"])
    return 200
  end


  post '/jobsubmit' do 
    userprofile = env['warden'].user 
    newjob = Job.create(
      :user_id => userprofile.id,
      :company => params['companyname'],
      :position => params['position'],
      :startdate => params['startdate'],
      :enddate => params['enddate'],
      :type => params['type'],
      :responsibilities => params['responsibilities'],
      :achievements => params['achievements']

    )
     redirect to('/profile')
  end   

  post '/jobupdate' do
    jobdata = Job.get(params['id'])
    res = params.values[0]
    ach = params.values[1]
    jobdata.update(:responsibilities => res)
    jobdata.update(:achievements => ach)

    redirect to('/profile')
  end


  post '/deletejob' do
    jobdata = Job.get(params['id'])
    jobdata.destroy
    redirect to('/profile')
  end

end

map SinatraWardenExample.assets_prefix do
  run SinatraWardenExample.sprockets
end
    
    
run SinatraWardenExample