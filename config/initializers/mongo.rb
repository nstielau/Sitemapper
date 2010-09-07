require 'mongo_mapper'

APPLICATION_NAME="site_graph"

if Rails.env == "development"
  MongoMapper.connection = Mongo::Connection.new("127.0.0.1", 27017, :slave_ok => true)
  MongoMapper.database = "#{APPLICATION_NAME}_development"
elsif Rails.env == "test"
  MongoMapper.connection = Mongo::Connection.new("127.0.0.1", 27017, :slave_ok => true)
  MongoMapper.database = "#{APPLICATION_NAME}_test"
elsif Rails.env == "production"
  MongoMapper.connection = Mongo::Connection.new("flame.mongohq.com", ENV['MONGOHQ_PORT'], :slave_ok => true)
  MongoMapper.database = APPLICATION_NAME
  MongoMapper.database.authenticate(ENV['MONGOHQ_USERNAME'], ENV['MONGOHQ_PASSWORD'])
end