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

  property :id, Serial, key: true, :index => true  
  property :username, String, length: 50
  property :firstname, String, length: 50
  property :lastname, String, length:50
  property :email, String, length:80, format: :email_address
  property :datejoined, Date
  property :age, Integer
  property :gender, String, length: 1
  property :dob, Date
  property :address, String
  property :nationality, Integer
  property :contactnumber, String, length: 20
  property :facebooklink, String, length: 120
  property :twitterlink, String, length: 120
  property :linkedinlink, String, length: 120
  property :githublink, String, length: 120
  property :photolink, String, length:200
  property :password, BCryptHash
  property :singaporepr, Boolean, :default  => false   #next time get user to choose from a list of countries they have PR status
  property :aboutme, String, length: 255
  property :insingaporenow, Boolean, :default =>true  #if non Singaporean, set this to false
  property :insg_start, Date  #Start date when Seeker is in Singapore (Only if he is non Singaporean/PR)
  property :insg_end, Date    #End date when Seeker is in Singapore (Only if he is non Singaporean/PR)
  property :activeseeker, Boolean, :default =>true #Seeker to keep this updated.
  property :travelfreq, Integer
  property :pictureurl, String
  property :verifiedbadge, Boolean, :default=>false
  property :verifiedstartdate, Date
  property :verifiedenddate, Date
  
  property :updated_at, DateTime

  has n, :matched_jobs
  has n, :jobs
  has 1, :career_score
  has n, :skill_summaries
  has n, :job_industries
  has n, :preferred_locations
  has n, :skills, :through => :skilltags   ###n-n###
  has n, :skilltags                        ###n-n###
  
  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

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
  property :user_id, Integer

  belongs_to :user
end


class Skill    ###n-n###
  include DataMapper::Resource

  property :id, Serial , key: true
  property :skill, String, length:100
  property :category, String, length:100
  
  has n, :skilltags
  has n, :users, :through => :skilltags
end

class Skilltag   ###n-n###
  include DataMapper::Resource

  property :id, Serial , key: true
  property :skill_id, Integer
  property :user_id, Integer
  property :skillscore, Integer

  belongs_to :skill, :key => true
  belongs_to :user, :key => true
end
  


########### START Generated from HSQL ##################
class SkillSummary    
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :user_id, Integer, :index => true
  property :skillid, Integer, :index => true
  property :skillname, String, length:100, :index => true
  property :skillrank, Integer, :index => true                  #1=Basic 2=Intermediate 3=Advance 4=Expert
  property :skillcatid, Integer, :index => true
  property :skillcategory, String, length:100, :index => true
  property :status, Integer, :default  => 2,:index => true     #0=delete, 1=edited, 2=active
  property :updated_at, DateTime                #When was it last edited

  belongs_to :user 
end

class SkillSource                               #This is for Skill Management Table.
  include DataMapper::Resource                  #Matching skills to category

  property :id, Serial , key: true, :index => true
  property :skilltype, Integer, :index => true                   #1=Tech 2=Soft
  property :skill_name, String, length:100, :index => true      
  property :skillcategory_id, Integer, :index => true
  property :skillcategory_name, String, length:100, :index => true
  

end

class SkillRank    
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :skillrankname, String, length:100, :index => true   

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
########### END Generated from HSQL ##################

# Tell DataMapper the models are done being defined
DataMapper.finalize

# Update the database to match the properties of User.
DataMapper.auto_upgrade!

# Create a test User
# if User.count == 0
#   @user = User.create(username: "tschew")
#   @user.password = "tschew"
#   @user.firstname = "Vince"
#   @user.email = "tschew@gmail.com"
#   @user.save
#   @user = User.create(username: "shaun")
#   @user.password = "shaun"
#   @user.firstname = "Shaun"
#   @user.email = "sreemus@yahoo.com"
#   @user.save
# end