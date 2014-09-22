require 'rubygems'
require 'data_mapper'
#require 'dm-mysql-adapter'
require 'dm-postgres-adapter'
require 'bcrypt'

# DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")
#DataMapper.setup(:default, "mysql://root:itjobstreet@localhost/seekerdashdb")
DataMapper.setup(:default, "postgres://pmfpekijznvzjw:Hq_zObLrI-YKpLoHpKKy0QLgsH@ec2-54-225-101-164.compute-1.amazonaws.com:5432/d3ev2r7degfpm9")

class User
  include DataMapper::Resource
  include BCrypt
  storage_names[repository = :default] = 'tme_skr_main'
  property :id, Serial, key: true, :index => true, :field => 'skr_id'
  property :activeseeker, Boolean, :default =>true, :field => 'skr_active'
  property :lastname, String,  :default=>"", length:50, :field => 'skr_surname'
  property :firstname, String, :default=>"", length: 50, :index => true, :field => 'skr_firstname'
  property :middlename, String, :default=>"", length: 50, :index => true, :field => 'skr_middlename'
  property :reveal, Boolean, :field => 'skr_reveal'
  property :email, String, :default=>"your@email.com", length:80, format: :email_address, :index => true, :field => 'skr_email' 
  property :dob, Date, :field => 'skr_birthdate' 
  property :gender, Integer, :default => 1, :field => 'skr_gender'
  property :married, Boolean, :default=>false,  :field => 'skr_married'  
  property :datejoined, Date, :field => 'skr_datejoined'
  property :availability, Integer, :field => 'skr_availability' # notice period
  property :updated_at, DateTime, :field => 'skr_updated'

  property :pictureurl, String, length: 400, :field => 'skr_photo'  #setup a default picture if not picture is found
  property :cvurl, String, length: 400, :field => 'skr_cv' 
  property :videourl, String, length: 400, :field => 'skr_video'   
  property :username, String, length: 50, :index => true, :field => 'skr_username'  
  property :prefind_all, Boolean, :default =>true,:field => 'skr_prefind_all' # no preference. If field is NIL, set this to true.
  property :prefjobfunc_all, Boolean, :default =>true,:field => 'skr_prefjobfunc_all' # no preference
  property :prefjobtitle_all, Boolean, :default =>true,:field => 'skr_prefjobtitle_all' # no preference
  property :prefloc_all, Boolean, :default =>true,:field => 'skr_prefloc_all' # no preference
  property :currentsalary, Integer, :default => 0, :field => 'skr_currsalary'
  property :expectedsalary, Integer, :default => 0, :field => 'skr_prefsalary'
  property :salarycurrency, Integer, :default => 1, :field => 'skr_salarycurrency'
  property :parttime, Boolean, :default=>false, :field => 'skr_parttime'
  property :fulltime, Boolean, :default=>false, :field => 'skr_fulltime'
  property :shiftwork, Boolean, :default=>false, :field => 'skr_shiftwork'
  property :outofhours, Boolean, :default=>false, :field => 'skr_emergency'
  property :travelfreq, Integer, :default=>0, :field => 'skr_preftravel'
  property :password, BCryptHash, :field => 'skr_password'
  property :age, Integer, :field => 'skr_age'
  property :aboutme, String, length: 255, :field => 'skr_aboutme'     #not used 
  property :insingaporenow, Boolean, :default =>true, :field => 'skr_insingaporenow'    
  property :insg_start, Date, :field => 'skr_insgstart', :default => lambda{ |p,s| Date.today}  
  property :insg_end, Date, :field => 'skr_insgend', :default => lambda{ |a,b| Date.today>>1} 
  property :lastlogin, Date, :field => 'skr_lastlogin'
  property :nationality, Integer, :field => 'skr_nationality'
  property :singaporepr, Boolean, :default  => false, :field => 'skr_singaporepr'
  property :address, String, :field => 'skr_address'
  property :contactnumber, String, length: 20, :field => 'skr_contactnumber' #created a new column in table

  has n, :matched_jobs
  has n, :jobs
  has 1, :career_score
  has n, :skill_summaries
  has n, :job_industries
  has n, :preferred_locations

  has n, :tme_skr_socialmedia, :model => 'TmeSkrSocialmedia'
  has n, :tme_skr_prefloc, :model => 'TmeSkrPrefloc'
  has n, :tme_skr_preftitle, :model => 'TmeSkrPreftitle'
  has n, :tme_skr_preffunc, :model => 'TmeSkrPreffunc'
  has n, :tme_skr_prefind, :model => 'TmeSkrPrefind'
  has n, :tme_skr_skill, :model => 'SkillSummary'
  has n, :tme_skr_language, :model =>'TmeSkrLanguage'
  

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

end

class TmeSkrSocialmedia
    include DataMapper::Resource
    storage_names[repository = :default] ='tme_skr_socialmedia'
    property :skr_socialmedia_id, Serial, key: true   
    property :user_id, Integer, :field => 'skr_id'
    property :skr_socialmediacat, Integer
    property :skr_socialmediaurl, String

    belongs_to :user 
end

class TmeSkrPrefloc
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_skr_prefloc'
    property :skr_prefloc_id, Serial, key: true   
    property :user_id, Integer, :field => 'skr_id'
    property :skr_prefloc, Integer

    belongs_to :user 
end

class TmeSkrPreftitle #job level
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_skr_preftitle'
    property :skr_preftitle_id, Serial, key: true   
    property :user_id, Integer, :field => 'skr_id'
    property :skr_preftitle, Integer

    belongs_to :user 
end


class TmeSkrPreffunc #job Function
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_skr_preffunc'
    property :skr_preffunc_id, Serial, key: true   
    property :user_id, Integer, :field => 'skr_id'
    property :skr_preffunc, Integer

    belongs_to :user 
end

class TmeSkrPrefind #Preferred industry
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_skr_prefind'
    property :skr_prefind_id, Serial, key: true   
    property :user_id, Integer, :field => 'skr_id'
    property :skr_prefind, Integer

    belongs_to :user 
end


class TmeListCountry
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_list_country'
    property :country_id, Serial, key: true   
    property :country, String
end

class TmeListTitle  # Job Level
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_list_title'
    property :title_id, Serial, key: true   
    property :title, String
end

class TmeListFunction  # Job Function
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_list_function'
    property :function_id, Serial, key: true   
    property :function, String
end

class TmeListIndustry  # Job Function
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_list_industry'
    property :industry_id, Serial, key: true   
    property :industry, String
end

class Job
  include DataMapper::Resource

  property :id, Serial, key: true
  property :startdate, Date
  property :enddate, Date
  property :position, String, length:120  # Graduate in what...
  property :company, String, length:120   # School
  property :responsibilities, String, length:100000 #Grades
  property :achievements, String, length: 100000    #Projects
  property :user_id, Integer
  property :type, String, length:1 #to define if it is a job or education. J or E
  property :employerrating, Integer # to rate how good is this company in your opinion

  #next time can include an array of skills that are being used in a job
  belongs_to :user 
end


class MatchedJob
  include DataMapper::Resource

  property :id, Serial, key: true, :index => true  
  property :user_id, Integer, :index => true  
  property :datematched, Date, :index => true  
  property :matchscore, Integer, :index => true  
  property :matchrank, Integer, :index => true  
  property :jobfunction, String, length:80, :index => true  
  property :joblevel, String, length:80, :index => true  
  property :jobsalaryrange, String, length:100, :index => true  

  belongs_to :user 
end


class CareerScore
  include DataMapper::Resource

  property :id, Serial, key: true
  property :careerscore, Integer
  property :last9careerscore, String
  property :user_id, Integer

  belongs_to :user
end





class Language   
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :user_id, Integer, :index => true
  property :languageid, Integer, :index => true
  property :writtenrank, Integer, :index => true                  #1=Basic 2=Intermediate 3=Advance 4=Expert
  property :spokenrank, Integer, :index => true                  #1=Basic 2=Intermediate 3=Advance 4=Expert
  property :status, Integer, :default  => 2,:index => true     #0=delete, 1=edited, 2=active
  property :updated_at, DateTime                #When was it last edited

  belongs_to :user 
end

class LanguageSource                           
  include DataMapper::Resource                 

  property :id, Serial , key: true, :index => true
  property :languagename, String, length:100, :index => true        

end

########### START Generated from HSQL ##################
class SkillSummary    
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_skr_skill'
  property :id, Serial , key: true, :index => true, :field => 'skr_skill_id'
  property :user_id, Integer, :index => true, :field => 'skr_id'
  property :skillid, Integer, :index => true, :field => 'skr_skill'
  property :skillrank, Integer, :index => true, :field => 'skr_skillrank'
  # property :skillcatid, Integer, :index => true #to be removed
  property :status, Integer, :default  => 2,:index => true, :field => 'skr_skillstatus'     #0=delete, 1=edited, 2=active
  property :updated_at, DateTime, :field => 'skr_skillmod'               #When was it last edited

  belongs_to :user 
end

class SkillSource                               #This is for Skill Management Table.
  include DataMapper::Resource                  #Matching skills to category
  storage_names[repository = :default] = 'tme_list_skill'
  property :id, Serial , key: true, :index => true, :field => 'skill_id'
  property :skill_name, String, length:100, :index => true, :field => 'skill'      
  property :skillcategory_id, Integer, :index => true, :field => 'skillcat'
  
end



class SkillRank    
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_skillrank'

  property :id, Serial , key: true, :index => true, :field => 'skillrank_id'
  property :skillrankname, String, length:100, :index => true, :field => 'skillrank'   

end


class SkillCategory    
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_skillcat'
  property :id, Serial , key: true, :index => true, :field => 'skillcat_id'
  property :categoryname, String, length:100, :index => true, :field => 'skillcat'   

end

class TmeListLanguage    
  include DataMapper::Resource              
  storage_names[repository = :default] = 'tme_list_language'
  property :language_id, Serial , key: true
  property :language, String, length:100
  
end

class TmeSkrLanguage    
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_skr_language'
  property :skr_lang_id, Serial , key: true, :index => true 
  property :user_id, Integer, :index => true, :field => 'skr_id'
  property :skr_lang, Integer, :index => true 
  property :skr_lang_speakskill, Integer
  property :skr_lang_writeskill, Integer

  belongs_to :user 
end

class NewSkillReport      #For users to report new skills that are now listed
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :skillname, String, length:100, :index => true 
  property :references, String, length:5000, :index => true 
  property :user_id, Integer, :index => true 

  end

class JobIndustry     #Preferred Industry
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :user_id, Integer
  property :industryid, Integer, :index => true   

belongs_to :user
end

class IndustryMaster  
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :industryname, String, length:100, :index => true   

end

class CountryMaster  
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :countryname, String, length:150, :index => true   

end

class PreferredLocation      
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :user_id, Integer
  property :countryid, Integer, :index => true   

belongs_to :user
end

class SkrscoreCerts
  include DataMapper::Resource

  property :id, Integer , key: true, :index => true
  property :certcount, Integer

end

########### END Generated from HSQL ##################

# Tell DataMapper the models are done being defined
DataMapper.finalize

# Update the database to match the properties of User.
#DataMapper.auto_upgrade!
