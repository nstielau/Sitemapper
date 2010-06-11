class Graph
  include MongoMapper::Document
  key :title,        String
  key :url,          String

  belongs_to :user
  has_many :pages

  before_save :generate

  def generated?
    pages.size > 0
  end

  def generate(regenerate=false)
    return if generated? && !regenerate
    client = Linkscape::Client.new(:accessID => user.seomoz_access_id, :secret => user.seomoz_secret_key)
    #client = Linkscape::Client.new(:accessID => SEOMOZ_ACCESS_ID, :secret => SEOMOZ_SECRET_KEY)
    result = client.allLinks(url,
                             :page_to_subdomain,
                             :urlcols => [:url, :mozrank],
                             :linkcols => :all,
                             :sort => :page_authority,
                             :filter => :internal,
                             :limit => 1000)
    if result.response.class == Net::HTTPUnauthorized
      errors.add_to_base "Not authorized to make API calls.  Make sure you successfully authorized this application via SEOmoz, and have waited for the permissions to update."
      return
    end

    added_pages = {}
    result.data.each do |link|
      source_url = link['uu']
      target_url = link['luuu']
      if source_url != target_url # ignore self-links
        added_pages[source_url] ||= Page.new(:url => source_url)
        added_pages[source_url].mozrank = link['umrp']
        added_pages[source_url].outbound_links ||= []
        added_pages[source_url].outbound_links << Link.new(:url => target_url)
        added_pages[target_url] ||= Page.new(:url => target_url)
        added_pages[target_url].inbound_links ||= []
        added_pages[target_url].inbound_links << Link.new(:url => source_url)
      end
    end
    added_pages.values.each do |p|
      pages << p
    end
  end

  def page_count
    @page_count ||= pages.size
  end

  def has_page(url)
    @page_index ||= pages.inject({}){|x,y| x[y.url] = true; x}
    @page_index[url] || false
  end
end