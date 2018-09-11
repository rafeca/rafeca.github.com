require 'jekyll'

# Usage: rake post title="A Title" [date="2012-02-09"] [tags=tag1, tag2]
desc "Begin a new post in 'posts' folder"
task :post do
  site = Jekyll::Site.new(Jekyll.configuration({}))
  path = site.config['posts']
  path = File.join('.', path)
  abort("rake aborted: '#{path}' directory not found.") unless FileTest.directory?(path)
  title = ENV["title"] || "new-post"
  tags = ENV["tags"]
  slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  begin
    date = (ENV['date'] ? Time.parse(ENV['date']) : Time.now).strftime('%Y-%m-%d')
  rescue => e
    puts "Error - date format must be YYYY-MM-DD, please check you typed it correctly!"
    exit -1
  end
  filename = File.join(path, "#{date}-#{slug}.markdown")
  print filename
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end

  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/-/,' ')}\""
    post.puts "categories: [#{tags}]"
    post.puts "---"
  end
end # task :post

