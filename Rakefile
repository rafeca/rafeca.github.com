require 'jekyll'

# Use green color to format text
def green(text)
  "\e[32m#{text}\e[0m"
end

desc 'Generate tag pages'
task :tags do
  puts green 'Generating tag pages...'

  require 'jekyll'

  site = Jekyll::Site.new(Jekyll.configuration({}))
  site.read_posts('')
  site.categories.sort.each do |category, _|
    html = <<-HTML
---
layout: default
---
<header>
  <h2>Posts in category <strong>#{category}</strong></h2>
</header>

<ul>
  {% for post in site.categories.#{category} %}
    {% include post.html %}
  {% endfor %}
</ul>
HTML

    puts "Creating file tag/#{green(category)}.html"
    File.open "tag/#{category}.html", 'w+' do |file|
      file.write html
    end
  end
  puts green 'Done!'
end

desc 'Generate emoji CSS styles'
task :emoji do
  puts green 'Generating emoji CSS...'

  site = Jekyll::Site.new(Jekyll.configuration({}))

  path = site.config['emoji']

  if !path.empty? and !File.exists?("#{path}") and !File.exists?("#{path}/smiley.png")
    Dir::mkdir path

    _css = %[.emoji {
  width: 20px;
  display: inline-block;
  text-indent: -2000px;
}

]

    Dir["#{Emoji.images_path}/emoji/*.png"].each do |src|
      FileUtils.cp src, path
      *_, file = src.split("/")
      *emoji_name, _ = file.split(".")
      _css += %[.emoji_#{emoji_name.join(".")} {
  background:url("/#{path}/#{file}") no-repeat scroll 0 center transparent;
  background-size: 20px auto;
}

]
    end

    File.open "css/emoji.css", 'w+' do |file|
      file.write _css
    end
  end
  puts green 'Done!'
end

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

