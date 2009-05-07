atom_feed(:language => I18n.locale) do |feed|
  feed.title '<%= class_name.pluralize %>'
  feed.subtitle 'Index of all <%= plural_name %>.'
  # Optional: feed.link <%= feed_link(:atom) %>
  feed.updated <%= feed_date(:atom) %>
  
  <%= collection_instance %>.each do |<%= singular_name %>|
    feed.entry(<%= singular_name %>) do |entry|
      entry.title 'title'
      entry.summary 'summary'
      # Optional: entry.content 'content', :type => 'html'
      # Optional: entry.updated <%= feed_entry_date(:atom) %>
      # Optional: entry.link <%= feed_entry_link(:atom) %>
      
      <%= singular_name %>.author do |author|
        author.name 'author_name'
      end
    end
  end
end