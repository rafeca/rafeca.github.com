

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

  require 'jekyll'

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

