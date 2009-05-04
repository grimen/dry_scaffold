atom_feed(:language => I18n.default_locale) do |feed|
  feed.title('Resources')
  feed.updated((@resources.first ? @resources.first.updated_at : Time.now.utc).strftime('%Y-%m-%dT%H:%M:%SZ'))
  
  @resources.each do |resource|
    feed.entry(resource) do |entry|
      entry.title(resource.title)
      entry.content(resource.content)
      
      resource.owner do |owner|
        owner.name(resource.owner)
      end
    end
  end
end