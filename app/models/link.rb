require 'digest/md5'
class Link
  include MongoMapper::EmbeddedDocument

  key :url, String
  belongs_to :page

  def url_id
    Digest::MD5.hexdigest(url)
  end
end