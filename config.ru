require 'sinatra'
require 'bundler'
require 'warden'
require './model'
require 'json'
require 'newrelic_rpm'
require 'digest/sha1'
  
class SinatraWardenExample < Sinatra::Application

#use Rack::Session::Pool, :expire_after => 2592000
 #use Rack::Session::Cookie, :expire_after => 14400
 use Rack::Session::Cookie, :key => 'rack.session', :expire_after => 365*24*60*60
 


use Warden::Manager do |config|

    # Tell Warden how to save our User info into a session.
    # Sessions can only take strings, not Ruby code, we'll store
    # the User's `id`
    config.serialize_into_session{|user| user.id }
    # Now tell Warden how to take what we've stored in the session
    # and get a User from that information..
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
       @userprofile = env['warden'].user    
       @userme = @userprofile.firstname
       @emailme = @userprofile.email
       @usermatchjoblist = @userprofile.matched_jobs
       @careerscore = @userprofile.skrscore.skrscore_total
       erb :"dash/index", :layout => :'dash/layout1'
end

 
get '/hrm' do
   redirect '/auth/login' unless env['warden'].authenticated?
   @userprofile = env['warden'].user 
   @user = User
   @userme = @userprofile.firstname
   #@emailme = @userprofile.email
   #@usermatchjoblist = @userprofile.matched_jobs
   #@careerscore = @userprofile.skrscore.skrscore_total
   userid = @userprofile.id.to_s
   #cmd = "SELECT * FROM jobmatch("+ userid+")"
   #@top5matches=repository(:default).adapter.select(cmd)
   mycoy = TmeCompanyMain.get(1)  #replace this with the CompanyID
   @joblist = mycoy.tme_job_main


   erb :hrm, :layout => :'dash/layout1'  #change the layout for Recruiters
end


post '/top5matchestable' do
   @user = User
   jobid = params["pk"]
   #jobid = "1"
   cmd = "SELECT * FROM jobmatch("+ jobid+")"
   @top5matches=repository(:default).adapter.select(cmd)
   erb :top5matchestable, :layout => false

end



get '/mycv' do
       redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = @userprofile.firstname
       @country = TmeListCountry
       @uni = TmeListUniversity
       @degree = TmeListDegree
       @allskills =   @userprofile.skill_summaries.all(:order => [ :skillrank.desc ], :limit => 10, :status.gt =>0)
       @alledu =   @userprofile.tme_skr_edu.all
       @alljobs = @userprofile.tme_skr_emp.all
       @ssmaster = SkillSource  #master skill source for cross referencing
       @mynations=@userprofile.tme_skr_nation.first(:user_id=>@userprofile.id).skr_nation
       @mynationtypes=@userprofile.tme_skr_nation.first(:user_id=>@userprofile.id).skr_nation_type
       erb :mycv, :layout => :'main/layout2'
end


get '/profile' do
       redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user   
       @userme = @userprofile.firstname 

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
       @mynations=@userprofile.tme_skr_nation.first(:user_id=>@userprofile.id).skr_nation
       @mynationtypes=@userprofile.tme_skr_nation.first(:user_id=>@userprofile.id).skr_nation_type

       @cmaster = TmeListCountry.all
       ctemp = []
           @cmaster.each do |x|
           ctemp << {value: x.country_id, text: "#{x.country}"}
        end
        @countries = ctemp.to_json
       erb :"dash/profile", :layout => :'dash/layout1'
end


get '/admin' do
        #make sure only admin can access
        #Create a section where we can dump the json of categories and skills.
        #To create new users
       redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user   
       @userme = @userprofile.firstname


        erb :"dash/admin", :layout => :'dash/layout1'

end


get '/settings' do

       redirect '/auth/login' unless env['warden'].authenticated?
       @userprofile = env['warden'].user  #This is the most important query of all. it will identify the user of this session.
       @userme = @userprofile.firstname
       @careerscore = @userprofile.skrscore.skrscore_total
       @allskills =   @userprofile.skill_summaries.all
       @alllanguages = @userprofile.tme_skr_language.all

       
       @ssmaster = SkillSource  #master skill source for cross referencing
       #stemp = []
       #    @ssmaster.each do |x|
       #    stemp << {value: x.id, text: "#{x.skill_name}"}
       #    
       #end
       # @skill_list= stemp.to_json


       #Preferred Level
       plevel = @userprofile.tme_skr_preftitle.all
       @pref_level=""
       plevel.each do |i|
        @pref_level = @pref_level + plevel.get(i).skr_preftitle.to_s + ","
      end

      #Preferred Job Functions
       pfunc = @userprofile.tme_skr_preffunc.all
       @pref_func=""
       pfunc.each do |i|
        @pref_func = @pref_func + pfunc.get(i).skr_preffunc.to_s + ","
      end

       #Preferred Industries
       pind = @userprofile.tme_skr_prefind.all
       @pref_ind=""
       pind.each do |i|
          @pref_ind  = @pref_ind + pind.get(i).skr_prefind.to_s + ","
       end

       #Preferred Locations
       pc= @userprofile.tme_skr_prefloc.all
       @pref_loc=""
       pc.each do |i|
          @pref_loc = @pref_loc + pc.get(i).skr_prefloc.to_s + ","
       end

       @indmaster = TmeListIndustry.all   #Industry Master       #Hardcode to HTML. Remove from Database.
       indtemp = []
           @indmaster.each do |x|
           indtemp << {id: x.industry_id, text: "#{x.industry}"}
        end
        @industries = indtemp.to_json

       @locmaster = TmeListCountry.all
       loctemp = []
       @locmaster.each do |x|
           loctemp << {id: x.country_id, text: "#{x.country}"} 
        end
        @locations = loctemp.to_json

       @levelmaster = TmeListTitle.all
       leveltemp = []
       @levelmaster.each do |x|
           leveltemp << {id: x.title_id, text: "#{x.title}"}
        end
        @levels = leveltemp.to_json

       @functionmaster = TmeListFunction.all
       functemp = []
       @functionmaster.each do |x|
           functemp << {id: x.function_id, text: "#{x.function}"}
        end
        @functions = functemp.to_json

       @scmaster = SkillCategory.all   #Skill Category Master   
       cattemp = []
           @scmaster.each do |x|
           cattemp << {value: x.id, text: "#{x.categoryname}"}
       end
       @skillcat= cattemp.to_json

       @lmaster = TmeListLanguage.all
       ltemp = []
           @lmaster.each do |x|
           ltemp << {value: x.language_id, text: "#{x.language}"}
       end
      @langlist= ltemp.to_json

       @sr = SkillRank.all  #Hardcode to HTML. Remove from Database.

       @mynations=@userprofile.tme_skr_nation.first(:user_id=>@userprofile.id).skr_nation
       @mynationtypes=@userprofile.tme_skr_nation.first(:user_id=>@userprofile.id).skr_nation_type

       erb :"dash/settings", :layout => :'dash/layout1'
end

get '/getskill' do
      smaster = SkillSource.all(:skillcategory_id => params["value"]) 
      sltemp=[]
      smaster.each do |x|
        sltemp << {value: x.id, text: "#{x.skill_name}"}       
      end
     sltemp.to_json
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
    session.clear
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
    
    if params["singaporepr"] =="true"
      ntype=2
    else ntype=1  #temporary put as 1. No significance at this stage
    end
    type=userdata.tme_skr_nation.first(:user_id=>userdata.id) # MVP only has 1 nationality
    type.update(:skr_nation_type => ntype)
    return 200
  end

  post '/updatenationality' do
    userdata = User.get(params["pk"])
    mynations=userdata.tme_skr_nation.first(:user_id=>userdata.id)

    mynations.update(:skr_nation => params["value"])
    return 200
  end


  post '/updateactive' do
    userdata = User.get(params["pk"])

   mynationtypes=userdata.tme_skr_nation.first(:user_id=>userdata.id).skr_nation_type

    userdata.update(:activeseeker => params['activeseeker'])
    { :active => userdata.activeseeker, :insingaporenow => userdata.insingaporenow, :singaporepr => mynationtypes}.to_json
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
 
  post '/updateintern' do
    userdata = User.get(params["pk"])
    userdata.update(:skr_intern => params['skr_intern'])
    {:status => 200, :skr_intern=>userdata.skr_intern}.to_json
  end

  post '/updatecontractor' do
    userdata = User.get(params["pk"])
    userdata.update(:skr_contractor => params['skr_contractor'])
    {:status => 200, :skr_contractor=>userdata.skr_contractor}.to_json
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

  post '/deletelanguage' do
    userprofile = env['warden'].user
    mylanguage = userprofile.tme_skr_language.get(params["pk"])
    mylanguage.update(:skr_status => 0)
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
    if !params[:skillid].present?
      {:responsemsg => "Skill ID is required!" }.to_json
    else
      newskill = SkillSummary.first_or_create({:skillid => params["skillid"],:user_id => userprofile.id}).update(:skillrank => params["skillrank"], :user_id => userprofile.id, :status =>2)  #If similar skillID detected, just update it with new set of data.
      {:responsemsg => "New skill added!" }.to_json
    end    
  end

  post '/newlanguage' do
    userprofile = env['warden'].user
    newlanguage = TmeSkrLanguage.first_or_create({:skr_lang => params["skr_lang"], :user_id => userprofile.id}).update(:skr_lang_speakskill => params["skr_lang_speakskill"], :skr_lang_writeskill => params["skr_lang_writeskill"], :user_id => userprofile.id, :skr_status =>2)  
        {:responsemsg => "New language added!" }.to_json
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
    userprofile = env['warden'].user
    myskill = userprofile.skill_summaries.get(params["pk"])
    #myskill.update(eval(":#{params['name']}") => params["value"])
    #myskill.reload.update(eval(":#{params['name']}") => params["value"])
    myskill.update(:skillrank => params["value"])
    myskill.update(:status =>1)

    return 200
  end

 post '/updatelang_speakskill' do
    userprofile = env['warden'].user
    mylang = userprofile.tme_skr_language.get(params["pk"])
    mylang.update(:skr_lang_speakskill => params["value"])
    mylang.update(:skr_status =>1)

    return 200
  end


 post '/updatelang_writeskill' do
    userprofile = env['warden'].user
    mylang = userprofile.tme_skr_language.get(params["pk"])
    mylang.update(:skr_lang_writeskill => params["value"])
    mylang.update(:skr_status =>1)

    return 200
  end


  get '/showsysadmin' do
    userprofile = env['warden'].user
    sysadminchart= userprofile.sysadmindata.all
  end


    post '/updatelocpref' do
     userprofile = env['warden'].user
     #First delete all preferred locations in table.
     oldloc = userprofile.tme_skr_prefloc.all
     oldloc.each do |x|
      x.destroy
     end
     loc =params["value"]
     if loc != nil  #If user does nto enter any value, then just return back
       #traverse array
       loc.each { |x| userprofile.tme_skr_prefloc.create(:skr_prefloc => x)}
     end
    end

    post '/updateindpref' do
     userprofile = env['warden'].user
     #First delete all preferred industries in table.
     oldind = userprofile.tme_skr_prefind.all
     oldind.each do |x|
      x.destroy
     end
     ind =params["value"]
     if ind != nil  #If user does nto enter any value, then just return back
       #traverse array
       ind.each { |x| userprofile.tme_skr_prefind.create(:skr_prefind => x)}
     end
    end

    post '/updatelevelpref' do
     userprofile = env['warden'].user
     #First delete all preferred levels in table.
     oldlevel = userprofile.tme_skr_preftitle.all
     oldlevel.each do |x|
      x.destroy
     end
     #level = []
     #level = params["value"].split(",").map(&:to_i) #string to array
     level =params["value"]
     if level != nil  #If user does nto enter any value, then just return back
       #traverse array
       level.each { |x| userprofile.tme_skr_preftitle.create(:skr_preftitle => x)}
     end

  end

    post '/updatefuncpref' do
     userprofile = env['warden'].user
     #First delete all preferred levels in table.
     oldfunc = userprofile.tme_skr_preffunc.all
     oldfunc.each do |x|
      x.destroy
     end
     func =params["value"]
     if func != nil
        #traverse array
        func.each { |x| userprofile.tme_skr_preffunc.create(:skr_preffunc => x)}
      end
  end

 post '/table' do
       @userprofile = env['warden'].user  
       @allskills =   @userprofile.skill_summaries.all
       @ssmaster = SkillSource  #master skill source for cross referencing
       @scmaster = SkillCategory.all   #Skill Category Master     #Hardcode to HTML. Remove from Database. Push this to the /admin for churning json.
       @sr = SkillRank.all  
       erb :table, :layout => false

    end

 post '/langtable' do
       @userprofile = env['warden'].user  
       @alllanguages =   @userprofile.tme_skr_language.all
       @lmaster = TmeListLanguage.all 
       @sr = SkillRank.all  #Hardcode to HTML. Remove from Database.
       erb :langtable, :layout => false

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
    TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>1, :user_id=> params["pk"]}).update(:skr_socialmediaurl=> params['value']) 
        {:responsemsg => "Facebook URL updated" }.to_json

  end

   post '/updatelinkedin' do
    userprofile = env['warden'].user
    TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>3, :user_id=> params["pk"]}).update(:skr_socialmediaurl=> params["value"]) 
        {:responsemsg => "LinkedIn URL updated" }.to_json
  end

  post '/updatetwitter' do
    userprofile = env['warden'].user
    TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>4, :user_id=> params["pk"]}).update(:skr_socialmediaurl=> params["value"]) 
        {:responsemsg => "Twitter URL updated" }.to_json
  end


#get '/industrystatistics' do
#       redirect '/auth/login' unless env['warden'].authenticated?
#       user1 = env['warden'].user   
#       @userme = user1.firstname
#       @chart1_name="IT Professionals hired"
#       @chart1_source="IDA"
#       @chart1_data = [140.8, 141.3, 142.9, 144.3, 146.7]
#       erb :industrystatistics
#end



end
  

run SinatraWardenExample