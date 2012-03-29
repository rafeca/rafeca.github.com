

# Use green color to format text
def green(text)
  "\e[32m#{text}\e[0m"
end

desc 'Generate tag pages'
task :tags do
  puts green("Generating tag pages...")
  
  require 'jekyll'
  
  options = Jekyll.configuration({})
  site = Jekyll::Site.new(options)
  site.read_posts('')
  site.categories.sort.each do |category, _|
    html = <<HTML
---
layout: default
title: Thoughts by rafeca
---
<header>
  <h1><a class="fadedlink" href="/" title="Home">&laquo;</a> {{ site.title }}</h1>
  <h2>Posts in category "#{category}"</h2>
</header>

<ul>
  {% for post in site.categories.#{category} %}
    {% include post.html %}
  {% endfor %}
</ul>
HTML

    file = green("tag/#{category}.html")
    puts "Creating file #{file}"
    File.open("tag/#{category}.html", 'w+') do |file|
      file.write html
    end
  end
  puts 'Done!'
end

