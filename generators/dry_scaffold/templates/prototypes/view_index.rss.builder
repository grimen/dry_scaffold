xml.instruct! :xml, :version => '1.0'
xml.rss(:version => '2.0') do
  xml.channel do
    xml.title 'Resources'
    xml.description 'Index of all resources.'
    xml.link resources_url(:rss)
    xml.lastBuildDate (@resources.first.created_at rescue Time.now.utc).to_s(:rfc822)
    xml.language I18n.locale
    
    @resources.each do |resource|
      xml.item do
        xml.title 'title'
        xml.description 'summary'
        xml.pubDate resource.try(:created_at).to_s(:rfc822)
        xml.link resource_url(resource, :rss)
        
        xml.author 'author_name'
      end
    end
  end
end