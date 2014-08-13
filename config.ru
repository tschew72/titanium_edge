require 'dashing'
require 'bundler'

require 'warden'
require './model'

require 'httparty'
require 'json'
#require 'roo'
#require 'compass'


class SinatraWardenExample < Sinatra::Application

#use Rack::Session::Pool, :expire_after => 2592000
 use Rack::Session::Cookie, :expire_after => 14400, # In seconds
 
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
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.      
       @userme = @userprofile.firstname
       @emailme = @userprofile.email
       @usermatchjoblist = @userprofile.matched_jobs
       erb :edge
end


get '/summary' do
   redirect '/auth/login' unless env['warden'].authenticated?
       user1 = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = user1.firstname
       erb :summary
end

get '/industrystatistics' do
       redirect '/auth/login' unless env['warden'].authenticated?
       user1 = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = user1.firstname
       @chart1_name="IT Professionals hired"
       @chart1_source="IDA"
       @chart1_data = [140.8, 141.3, 142.9, 144.3, 146.7]
       erb :industrystatistics
end


get '/profile' do
       redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = @userprofile.firstname
       #@emailme = @userprofile.email
       #@userskills= @userprofile.skilltags.all(:order => [:skillscore.desc])
       #@skillname = Skill.all
       @userskills1 = @userprofile.skill_summaries.all(:skillcategory => 1)
       @userskills2 = @userprofile.skill_summaries.all(:skillcategory => 2)
       @userskills3 = @userprofile.skill_summaries.all(:skillcategory => 3)
       @userskills4 = @userprofile.skill_summaries.all(:skillcategory => 4)
       @userskills5 = @userprofile.skill_summaries.all(:skillcategory => 5)
       
       @jobhistory = @userprofile.jobs.all(:order => [:startdate.desc])
       erb :profile
end

get '/mycv' do
       redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = @userprofile.firstname
       #@emailme = @userprofile.email
       #@userskills= @userprofile.skilltags.all(:order => [:skillscore.desc])
       #@skillname = Skill.all
       @userskills1 = @userprofile.skill_summaries.all(:skillcategory => 1)
       @userskills2 = @userprofile.skill_summaries.all(:skillcategory => 2)
       @userskills3 = @userprofile.skill_summaries.all(:skillcategory => 3)
       @userskills4 = @userprofile.skill_summaries.all(:skillcategory => 4)
       @userskills5 = @userprofile.skill_summaries.all(:skillcategory => 5)       
       @jobhistory = @userprofile.jobs.all(:order => [:startdate.desc])
       erb :mycv
end

get '/settings' do

       redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = @userprofile.firstname
       @allskills =   @userprofile.skill_summaries.all
       @ssmaster = SkillSource  #master skill source for cross referencing
 

    
@ss0 = @ssmaster.all(:skillcategory_id =>0)

       @ss1 = @ssmaster.all(:skillcategory_id =>1)
       @ss2 = @ssmaster.all(:skillcategory_id =>2)
       @ss3 = @ssmaster.all(:skillcategory_id =>3)
       @ss4 = @ssmaster.all(:skillcategory_id =>4)
       @ss5 = @ssmaster.all(:skillcategory_id =>5)
       @ss6 = @ssmaster.all(:skillcategory_id =>6)
       @ss7 = @ssmaster.all(:skillcategory_id =>7)
       @ss8 = @ssmaster.all(:skillcategory_id =>8)
       @ss9 = @ssmaster.all(:skillcategory_id =>9)
       @ss19 = @ssmaster.all(:skillcategory_id =>19)
       @ss20 = @ssmaster.all(:skillcategory_id =>20)
       @ss21 = @ssmaster.all(:skillcategory_id =>21)
       @ss22 = @ssmaster.all(:skillcategory_id =>22)
       @ss23 = @ssmaster.all(:skillcategory_id =>23)
       @ss24 = @ssmaster.all(:skillcategory_id =>24)
       @ss25 = @ssmaster.all(:skillcategory_id =>25)
       @ss26 = @ssmaster.all(:skillcategory_id =>26)
       @ss27 = @ssmaster.all(:skillcategory_id =>27)
       @ss28 = @ssmaster.all(:skillcategory_id =>28)
       @ss29 = @ssmaster.all(:skillcategory_id =>29)
       @ss30 = @ssmaster.all(:skillcategory_id =>30)



       
        temp1 = []  #Skillsource translated sst 
           @ss1.each do |x|
           temp1 << {value: x.id, text: "#{x.skill_name}"}
           @sst1 = temp1.to_json
        end
        temp2 = []  #Skillsource translated sst 
           @ss2.each do |x|
           temp2 << {value: x.id, text: "#{x.skill_name}"}
           @sst2 = temp2.to_json
        end
        temp3 = []  #Skillsource translated sst 
           @ss3.each do |x|
           temp3 << {value: x.id, text: "#{x.skill_name}"}
           @sst3 = temp3.to_json
        end
        temp4 = []  #Skillsource translated sst 
           @ss4.each do |x|
           temp4 << {value: x.id, text: "#{x.skill_name}"}
           @sst4 = temp4.to_json
        end
        temp5 = []  #Skillsource translated sst 
           @ss5.each do |x|
           temp5 << {value: x.id, text: "#{x.skill_name}"}
           @sst5 = temp5.to_json
        end
        temp6 = []  #Skillsource translated sst 
           @ss6.each do |x|
           temp6 << {value: x.id, text: "#{x.skill_name}"}
           @sst6 = temp6.to_json
        end
        temp7 = []  #Skillsource translated sst 
           @ss7.each do |x|
           temp7 << {value: x.id, text: "#{x.skill_name}"}
           @sst7 = temp7.to_json
        end
        temp8 = []  #Skillsource translated sst 
           @ss8.each do |x|
           temp8 << {value: x.id, text: "#{x.skill_name}"}
           @sst8 = temp8.to_json
        end
        temp9 = []  #Skillsource translated sst 
           @ss9.each do |x|
           temp9 << {value: x.id, text: "#{x.skill_name}"}
           @sst9 = temp9.to_json
        end
        temp19 = []  #Skillsource translated sst 
           @ss19.each do |x|
           temp19 << {value: x.id, text: "#{x.skill_name}"}
           @sst19 = temp19.to_json
        end
        temp20 = []  #Skillsource translated sst 
           @ss20.each do |x|
           temp20 << {value: x.id, text: "#{x.skill_name}"}
           @sst20 = temp20.to_json
        end
        temp23 = []  #Skillsource translated sst 
           @ss23.each do |x|
           temp23 << {value: x.id, text: "#{x.skill_name}"}
           @sst23 = temp23.to_json
        end
        temp28 = []  #Skillsource translated sst 
           @ss28.each do |x|
           temp28 << {value: x.id, text: "#{x.skill_name}"}
           @sst28 = temp28.to_json
        end

       #@jobhistory = @userprofile.jobs.all(:order => [:startdate.desc])
       @sr = SkillRank.all



       erb :settings
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

  get '/deleteskill' do
    userprofile = env['warden'].user
    myskill = userprofile.skill_summaries.get(params["id"])
    #myskill.destroy
    myskill.update(:status => 0)
    redirect to ('/settings#skilltable')
  end

  post '/updateskill' do
    userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
    myskill = userprofile.skill_summaries.get(params["pk"])
    #myskill.update(eval(":#{params['name']}") => params["value"])
    myskill.update(:skillid => params["value"])
    myskill.update(:status =>1)
    #myskill.skillid=params["value"]
    #myskill.status=1
    #myskill.save
    return 200
  end

  post '/updateskillcat' do
    userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
    myskill = userprofile.skill_summaries.get(params["pk"])
    #myskill.update(eval(":#{params['name']}") => params["value"])
    #myskill.reload.update(eval(":#{params['name']}") => params["value"])
    myskill.update(:skillcatid => params["value"])
    myskill.update(:status =>1)

    return 200
  end

 post '/updateskillrank' do
    userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
    myskill = userprofile.skill_summaries.get(params["pk"])
    #myskill.update(eval(":#{params['name']}") => params["value"])
    #myskill.reload.update(eval(":#{params['name']}") => params["value"])
    myskill.update(:skillrank => params["value"])
    myskill.update(:status =>1)

    return 200
  end


  get '/showsysadmin' do
    userprofile = env['warden'].user
    sysadminchart= userprofile.sysadmindata.all
  end


end

map SinatraWardenExample.assets_prefix do
  run SinatraWardenExample.sprockets
end
    
    
run SinatraWardenExample