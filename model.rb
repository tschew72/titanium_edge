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

  property :id, Serial, key: true
  property :username, String, length: 50
  property :firstname, String, length: 50
  property :email, String, length:80
  property :password, BCryptHash

  has n, :matched_jobs
  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

end


class MatchedJob
  include DataMapper::Resource

  property :id, Serial, key: true
  property :score, Integer
  property :rank, Integer
  property :jobfunction, String, length:80
  property :joblevel, String, length:80
  property :datematched, Date
  property :salaryrange, Integer
  property :user_id, Integer
  
  belongs_to :user 
end


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