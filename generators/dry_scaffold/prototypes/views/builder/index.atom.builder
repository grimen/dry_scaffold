atom_feed(:language => I18n.locale) do |feed|
  feed.title 'Resources'
  feed.subtitle 'Index of all resources.'
  # Optional: feed.link :href => resources_url(:atom), :rel => 'self'
  feed.updated (@resources.first.created_at rescue Time.now.utc).strftime('%Y-%m-%dT%H:%M:%SZ'))
  
  @resources.each do |resource|
    feed.entry(resource) do |entry|
      entry.title 'title'
      entry.summary 'summary'
      # Optional: entry.content 'content', :type => 'html'
      # Optional: entry.updated resource.try(:updated_at).strftime('%Y-%m-%dT%H:%M:%SZ')
      # Optional: entry.link :href => resource_url(resource, :atom)
      
      resource.author do |author|
        author.name 'author_name'
      end
    end
  end
end