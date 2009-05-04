xml.instruct! :xml, :version => '1.0'
xml.rss(:version => '2.0'){
  xml.channel{
    xml.title(@resources.first.blog.title)
    xml.link("http://localhost:3000/blog_posts.rss")
    xml.description(@resources.first.blog.description)
    xml.language(I18n.default_locale)
    
    @resources.each do |resource|
      xml.item do
        xml.title(resource.title)
        xml.description(resource.body)
        xml.pubDate(resource.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.link("http://localhost:3000/blog_posts/" + resource.id.to_s)
        xml.guid("http://localhost:3000/blog_posts/" + resource.id.to_s)
      end
    end
  }
}