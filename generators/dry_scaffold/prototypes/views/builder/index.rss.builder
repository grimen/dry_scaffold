xml.instruct! :xml, :version => '1.0'
xml.rss(:version => '2.0') do
  xml.channel do
    xml.title 'Ducks'
    xml.description 'Index of all ducks.'
    xml.link ducks_url(:rss)
    xml.lastBuildDate (@ducks.first.created_at rescue Time.now.utc).to_s(:rfc822)
    xml.language I18n.locale
    
    @ducks.each do |duck|
      xml.item do
        xml.title 'title'
        xml.description 'summary'
        xml.pubDate duck.try(:created_at).to_s(:rfc822)
        xml.link duck_url(duck, :rss)
        
        xml.author 'author_name'
      end
    end
  end
end