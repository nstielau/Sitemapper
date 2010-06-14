require 'digest/md5'
require 'uri'
class Page
  include MongoMapper::EmbeddedDocument

  key :url, String
  key :mozrank, Float
  key :page_authority, Integer

  has_many :outbound_links, :class => Link
  has_many :inbound_links, :class => Link
  belongs_to :graph

  # Create a unique id for this graph
  def url_id
    Digest::MD5.hexdigest(url.to_s)
  end

  # Parse the path from the page URL
  def path
    URI::parse("http://#{url}").path
  end
end