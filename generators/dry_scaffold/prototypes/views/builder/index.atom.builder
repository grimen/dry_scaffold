atom_feed(:language => I18n.locale) do |feed|
  feed.title 'Ducks'
  feed.subtitle 'Index of all ducks.'
  # Optional: feed.link :href => ducks_url(:atom), :rel => 'self'
  feed.updated (@ducks.first.created_at rescue Time.now.utc).strftime('%Y-%m-%dT%H:%M:%SZ'))
  
  @ducks.each do |duck|
    feed.entry(duck) do |entry|
      entry.title 'title'
      entry.summary 'summary'
      # Optional: entry.content 'content', :type => 'html'
      # Optional: entry.updated duck.try(:updated_at).strftime('%Y-%m-%dT%H:%M:%SZ')
      # Optional: entry.link :href => duck_url(duck, :atom)
      
      duck.author do |author|
        author.name 'author_name'
      end
    end
  end
end