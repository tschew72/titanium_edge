require 'rubygems'
require 'data_mapper'
require 'dm-mysql-adapter'
require 'bcrypt'

# DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")
DataMapper.setup(:default, "mysql://root:itjobstreet@localhost/seekerdashdb")


class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, key: true
  property :username, String, length: 50
  property :firstname, String, length: 50
  property :email, String, length:80
  property :password, BCryptHash

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end
end

# Tell DataMapper the models are done being defined
DataMapper.finalize

# Update the database to match the properties of User.
DataMapper.auto_upgrade!

# Create a test User
if User.count == 0
  @user = User.create(username: "tschew")
  @user.password = "tschew"
  @user.firstname = "Vince"
  @user.email = "tschew@gmail.com"
  @user.save
end