require 'mongo_mapper'

APPLICATION_NAME="site_graph"

if Rails.env == "development"
  MongoMapper.connection = Mongo::Connection.new
  MongoMapper.database = "#{APPLICATION_NAME}_development"
elsif Rails.env == "test"
  MongoMapper.connection = Mongo::Connection.new
  MongoMapper.database = "#{APPLICATION_NAME}_test"
else
  MongoMapper.connection = Mongo::Connection.new("flame.mongohq.com", "27066")
  MongoMapper.database = APPLICATION_NAME
  MongoMapper.database.authenticate(ENV['MONGOHQ_USERNAME'], ENV['MONGOHQ_PASSWORD'])
end