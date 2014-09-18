require 'sinatra'
require 'bundler'
require 'warden'
require './model'
require 'json'
require 'newrelic_rpm'
require 'digest/sha1'
  
class SinatraWardenExample < Sinatra::Application

#use Rack::Session::Pool, :expire_after => 2592000
 use Rack::Session::Cookie, :expire_after => 14400
 
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
   #redirect '/main/index.html'
   #redirect to('/auth/login')
   erb :"main/index", :layout => :'main/layout1'
end
 
get '/edge' do
   # If user comes in directly here, if not authenticated, throw them to /auth/login
   redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.    
       @userme = @userprofile.firstname
       @emailme = @userprofile.email
       @usermatchjoblist = @userprofile.matched_jobs
       #erb :edge
       erb :"dash/index", :layout => :'dash/layout1'
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


# get '/profile' do
#       redirect '/auth/login' unless env['warden'].authenticated?
#       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
#       @userme = @userprofile.firstname
#       #@emailme = @userprofile.email
#       #@userskills= @userprofile.skilltags.all(:order => [:skillscore.desc])
#       #@skillname = Skill.all
#       @userskills1 = @userprofile.skill_summaries.all(:skillcategory => 1)
#       @userskills2 = @userprofile.skill_summaries.all(:skillcategory => 2)
#       @userskills3 = @userprofile.skill_summaries.all(:skillcategory => 3)
#       @userskills4 = @userprofile.skill_summaries.all(:skillcategory => 4)
#       @userskills5 = @userprofile.skill_summaries.all(:skillcategory => 5)
#     
#       @jobhistory = @userprofile.jobs.all(:order => [:startdate.desc])
#       erb :profile
# end

get '/mycv' do
       redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = @userprofile.firstname
       #@emailme = @userprofile.email
       #@userskills= @userprofile.skilltags.all(:order => [:skillscore.desc])
       #@skillname = Skill.all
       @userskills1 = @userprofile.skill_summaries.all(:skillcatid => 1)
       @userskills2 = @userprofile.skill_summaries.all(:skillcatid => 2)
       @userskills3 = @userprofile.skill_summaries.all(:skillcatid => 3)
       @userskills4 = @userprofile.skill_summaries.all(:skillcatid => 4)
       @userskills5 = @userprofile.skill_summaries.all(:skillcatid => 5)     
       @jobhistory = @userprofile.jobs.all(:order => [:startdate.desc])
       erb :mycv
end

# get '/account' do
get '/profile' do
       redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user   
       
       sc = @userprofile.tme_skr_socialmedia.all
       sc.each do |x|
          if x.skr_socialmediacat == 1
            @facebook = x.skr_socialmediaurl
          end
          if x.skr_socialmediacat == 2
            @github = x.skr_socialmediaurl
          end
          if x.skr_socialmediacat == 3
            @linkedin = x.skr_socialmediaurl
          end
          if x.skr_socialmediacat == 4
            @twitter = x.skr_socialmediaurl
          end
          if x.skr_socialmediacat == 5
            @google = x.skr_socialmediaurl
          end
       end
       #@github = @userprofile.tme_skr_socialmedia.all(:skr_socialmediacat => 2).at(0).skr_socialmediaurl
       #@linkedin = @userprofile.tme_skr_socialmedia.all(:skr_socialmediacat => 3).at(0).skr_socialmediaurl
       #@twitter = @userprofile.tme_skr_socialmedia.all(:skr_socialmediacat => 4).at(0).skr_socialmediaurl
       #@google = @userprofile.tme_skr_socialmedia.all(:skr_socialmediacat => 5).at(0).skr_socialmediaurl
       
       
       @userme = @userprofile.firstname
       @cmaster = CountryMaster.all
       ctemp = []
           @cmaster.each do |x|
           ctemp << {value: x.id, text: "#{x.countryname}"}
           @countries = ctemp.to_json
        end
        
       #erb :account
       erb :"dash/profile", :layout => :'dash/layout1'
end


get '/admin' do

#make sure only admin can access
#Create a section where we can dump the json of categories and skills.
#To create new users
 redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = @userprofile.firstname
       @allskills =   @userprofile.skill_summaries.all
     
       @languages = @userprofile.languages.all
       @lmaster = LanguageSource.all
       @ssmaster = SkillSource  #master skill source for cross referencing
    
       #Preferred Industries
       pind = @userprofile.job_industries.all
       @pref_ind=""
       pind.each do |i|
          @pref_ind  = @pref_ind + pind.get(i).industryid.to_s + ","
       end


#all the following should just be JSON. Don't need to pick up from database!!!

       #Preferred Locations
       pc= @userprofile.preferred_locations.all
       @pref_loc=""
       pc.each do |i|
          @pref_loc = @pref_loc + pc.get(i).countryid.to_s + ","
       end

       @indmaster = IndustryMaster.all   #Industry Master
       indtemp = []
           @indmaster.each do |x|
           indtemp << {id: x.id, text: "#{x.industryname}"}
           @industries = indtemp.to_json
        end

       @cmaster = CountryMaster.all   #Country Master
       ctemp = []
           @cmaster.each do |x|
           ctemp << {value: x.id, text: "#{x.countryname}"}
           @countries = ctemp.to_json
        end
  
       @scmaster = SkillCategory.all   #Skill Category Master
       cattemp = []
           @scmaster.each do |x|
           cattemp << {value: x.id, text: "#{x.categoryname}"}
           @skillcat= cattemp.to_json
       end

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
       @ss31 = @ssmaster.all(:skillcategory_id =>31)
       @ss32 = @ssmaster.all(:skillcategory_id =>32)
       @ss33 = @ssmaster.all(:skillcategory_id =>33)
       @ss34 = @ssmaster.all(:skillcategory_id =>34)
       @ss35 = @ssmaster.all(:skillcategory_id =>35)
       @ss36 = @ssmaster.all(:skillcategory_id =>36)
       @ss37 = @ssmaster.all(:skillcategory_id =>37)
       @ss38 = @ssmaster.all(:skillcategory_id =>38)
       @ss39 = @ssmaster.all(:skillcategory_id =>39)
       @ss40 = @ssmaster.all(:skillcategory_id =>40)
       @ss41 = @ssmaster.all(:skillcategory_id =>41)
       @ss42 = @ssmaster.all(:skillcategory_id =>42)
       @ss43 = @ssmaster.all(:skillcategory_id =>43)
       @ss44 = @ssmaster.all(:skillcategory_id =>44)
       @ss45 = @ssmaster.all(:skillcategory_id =>45)

       temp21 = []  #Skillsource translated sst
           @ss21.each do |x|
           temp21 << {value: x.id, text: "#{x.skill_name}"}
           @sst21 = temp21.to_json
        end
        temp22 = []  #Skillsource translated sst
           @ss22.each do |x|
           temp22 << {value: x.id, text: "#{x.skill_name}"}
           @sst22 = temp22.to_json
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

        erb :"dash/admin", :layout => :'dash/layout1'

end


get '/settings' do

       redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = @userprofile.firstname
       @allskills =   @userprofile.skill_summaries.all
     
       @languages = @userprofile.languages.all
       @lmaster = LanguageSource.all
       @ssmaster = SkillSource  #master skill source for cross referencing
    
       #Preferred Industries
       pind = @userprofile.job_industries.all
       @pref_ind=""
       pind.each do |i|
          @pref_ind  = @pref_ind + pind.get(i).industryid.to_s + ","
       end


       #Preferred Locations
       pc= @userprofile.preferred_locations.all
       @pref_loc=""
       pc.each do |i|
          @pref_loc = @pref_loc + pc.get(i).countryid.to_s + ","
       end

       @indmaster = IndustryMaster.all   #Industry Master       #Hardcode to HTML. Remove from Database.
       indtemp = []
           @indmaster.each do |x|
           indtemp << {id: x.id, text: "#{x.industryname}"}
           @industries = indtemp.to_json
        end

       @cmaster = CountryMaster.all   #Country Master  #Hardcode to HTML. Remove from Database.
       ctemp = []
           @cmaster.each do |x|
           ctemp << {value: x.id, text: "#{x.countryname}"}
           @countries = ctemp.to_json
        end
  
       @scmaster = SkillCategory.all   #Skill Category Master     #Hardcode to HTML. Remove from Database. Push this to the /admin for churning json.
       cattemp = []
           @scmaster.each do |x|
           cattemp << {value: x.id, text: "#{x.categoryname}"}
           @skillcat= cattemp.to_json
       end

       @sr = SkillRank.all  #Hardcode to HTML. Remove from Database.
       #erb :settings
       erb :"dash/settings", :layout => :'dash/layout1'
end


  get '/auth/login' do

   erb :"main/login/index", :layout => :'main/layout1'
  end


  post '/auth/login' do

    env['warden'].authenticate!
    if session[:return_to].nil?

       #redirect '/'
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
 
  post '/updatedob' do
    userdata = User.get(params["pk"])
    str=params["dob"]
    date=Date.parse str
    userdata.update(:dob => date)
    return 200
  end

  post '/update_inSG_Date' do  # To update the start and end date of seeker in Singapore.
    userdata = User.get(params["pk"])
    str1=params["insg_start"]
    date1=Date.parse str1
    str2=params["insg_end"]
    date2=Date.parse str2
    userdata.update(:insg_start=> date1)
    userdata.update(:insg_end => date2)
    return 200
  end


  post '/updatetravelfreq' do
    userdata = User.get(params["pk"])
    userdata.update(:travelfreq => params['travelfreq'])
    return 200
  end

  post '/updatespr' do
    userdata = User.get(params["pk"])
    userdata.update(:singaporepr => params['singaporepr'])
    return 200
  end

  post '/updateactive' do
    userdata = User.get(params["pk"])
    userdata.update(:activeseeker => params['activeseeker'])
    { :active => userdata.activeseeker, :insingaporenow => userdata.insingaporenow, :singaporepr =>userdata.singaporepr}.to_json
  end

  post '/updateinsgnow' do
    userdata = User.get(params["pk"])
    userdata.update(:insingaporenow => params['insingaporenow'])
    { :insingaporenow => userdata.insingaporenow}.to_json
  end

  post '/updateparttime' do
    userdata = User.get(params["pk"])
    userdata.update(:parttime => params['parttime'])
    {:status => 200, :parttime => userdata.parttime}.to_json
  end

  post '/updatefulltime' do
    userdata = User.get(params["pk"])
    userdata.update(:fulltime => params['fulltime'])
    {:status => 200, :fulltime=> userdata.fulltime}.to_json
  end

  post '/updateshiftwork' do
    userdata = User.get(params["pk"])
    userdata.update(:shiftwork => params['shiftwork'])
    {:status => 200, :shiftwork =>userdata.shiftwork}.to_json
  end

  post '/updateoutofhours' do
    userdata = User.get(params["pk"])
    userdata.update(:outofhours => params['outofhours'])
    {:status => 200, :outofhours=>userdata.outofhours}.to_json
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



  post '/deleteskill' do
    userprofile = env['warden'].user
    myskill = userprofile.skill_summaries.get(params["pk"])
    myskill.update(:status => 0)
    return 200
  end

  post '/del_language' do
    userprofile = env['warden'].user
    mylanguage = userprofile.languages.get(params["pk"])
    mylanguage.update(:status => 0)
    return 200
  end

  post '/updateskill' do
    userprofile = env['warden'].user
    myskill = userprofile.skill_summaries.get(params["pk"])
    myskill.update(:skillid => params["value"])
    myskill.update(:status =>1)
    return 200
  end

  post '/newskill' do
    userprofile = env['warden'].user
    newskill = SkillSummary.first_or_create({:skillid => params["skillid"]}).update(:skillcatid => params["skillcatid"],  :skillrank => params["skillrank"], :user_id => userprofile.id, :status =>1)  #If similar skillID detected, just update it with new set of data.
        {:responsemsg => "New skill added!" }.to_json
  end

  post '/newuser' do
    newuser = User.first_or_create({:username => params["username"]}).update(:firstname => params["firstname"],  :lastname => params["lastname"], :email => params["email"], :password => params["password"] ) 
        {:responsemsg => "New user added!" }.to_json
  end

  post '/update_language' do
    redirect '/auth/login' unless env['warden'].authenticated?
    userprofile = env['warden'].user
    mylanguage = userprofile.languages.get(params["pk"])
    mylanguage.update(:languageid => params["value"])
    mylanguage.update(:status =>1)
    return 200
  end

  post '/updateskillcat' do
    userprofile = env['warden'].user
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


    post '/updatelocpref'do
    # If shaun cannot provide a string as data. Then what we will do is we will send back a new table to him with a string containing all the location ID
    # And in /settings, we will have to build this new table.
     #userprofile = env['warden'].user
     #pc= userprofile.preferred_locations.get(params["pk"])
     #pc.update(:countryid=> params["value"])
  end

    post '/updateindpref'do
     #userprofile = env['warden'].user
     #pind = userprofile.job_industries.get(params["pk"])
     #pind.update(eval(":#{params['name']}") => params["value"])
  end


 get '/table' do
       @userprofile = env['warden'].user  
       @allskills =   @userprofile.skill_summaries.all
       @ssmaster = SkillSource  #master skill source for cross referencing
       @scmaster = SkillCategory.all   #Skill Category Master     #Hardcode to HTML. Remove from Database. Push this to the /admin for churning json.
       @sr = SkillRank.all  #Hardcode to HTML. Remove from Database.
       erb :table, :layout => false

    end

 post '/filer' do
      ts = Time.now.getutc.to_time.to_i.to_s
      secret="fbOQxgozjYG2acAMKi3FYL61LOI"
      altogether="callback=http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html&timestamp="+ts+secret
      sig=Digest::SHA1.hexdigest altogether
      ts = Time.now.getutc.to_time.to_i
      {:timestamp => ts, :callback => "http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html", :signature => sig, :api_key =>"219441847515364"}.to_json
 end
 

 get '/filer' do
      userprofile = env['warden'].user
      ts = Time.now.getutc.to_time.to_i.to_s
      secret="fbOQxgozjYG2acAMKi3FYL61LOI"
      altogether="callback=http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html&public_id=#{userprofile.username}&timestamp="+ts+secret
      sig=Digest::SHA1.hexdigest altogether
      ts = Time.now.getutc.to_time.to_i
      {:timestamp => ts, :public_id => "#{userprofile.username}", :callback => "http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html", :signature => sig, :api_key =>"219441847515364"}.to_json
 end

 post '/cvuploaded' do
      userdata = User.get(params["pk"])
      userdata.update(:cvurl => params['cvurl'])
      return 200
 end

 post '/picuploaded' do
      userdata = User.get(params["pk"])
      userdata.update(:pictureurl => params['picurl'])
      return 200
 end


  post '/updatefacebook' do
    userprofile = env['warden'].user
    TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>1, :user_id=> params["pk"]}).update(:skr_socialmediaurl=> params["facebook"]) 
        {:responsemsg => "Facebook URL updated" }.to_json
  end

  post '/updategithub' do
    userprofile = env['warden'].user
    TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>2, :user_id=> params["pk"]}).update(:skr_socialmediaurl=> params["github"]) 
        {:responsemsg => "Facebook URL updated" }.to_json
  end
 
   post '/updatelinkedin' do
    userprofile = env['warden'].user
    TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>3, :user_id=> params["pk"]}).update(:skr_socialmediaurl=> params["linkedin"]) 
        {:responsemsg => "Facebook URL updated" }.to_json
  end

  post '/updatetwitter' do
    userprofile = env['warden'].user
    TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>4, :user_id=> params["pk"]}).update(:skr_socialmediaurl=> params["twitter"]) 
        {:responsemsg => "Facebook URL updated" }.to_json
  end

  post '/updategoogle' do
    userprofile = env['warden'].user
    TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>5, :user_id=> params["pk"]}).update(:skr_socialmediaurl=> params["google"]) 
        {:responsemsg => "Facebook URL updated" }.to_json
  end




end
  

run SinatraWardenExample