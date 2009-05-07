xml.instruct! :xml, :version => '1.0'
xml.rss(:version => '2.0') do
  xml.channel do
    xml.title '<%= class_name.pluralize %>'
    xml.description 'Index of all <%= plural_name %>.'
    xml.link <%= feed_link(:rss) %>
    xml.lastBuildDate <%= feed_date(:rss) %>
    xml.language I18n.locale
    
    <%= collection_instance %>.each do |<%= singular_name %>|
      xml.item do
        xml.title 'title'
        xml.description 'summary'
        xml.pubDate <%= feed_entry_date(:rss) %>
        xml.link <%= feed_entry_link(:rss) %>
        
        xml.author 'author_name'
      end
    end
  end
end