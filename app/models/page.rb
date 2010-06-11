require 'digest/md5'
require 'uri'
class Page
  include MongoMapper::EmbeddedDocument

  key :url, String
  key :mozrank, Float

  has_many :outbound_links, :class => Link
  has_many :inbound_links, :class => Link
  belongs_to :graph

  def url_id
    Digest::MD5.hexdigest(url.to_s)
  end

  def path
    URI::parse("http://#{url}").path
  end
end