desc 'Generate tag pages'
task :tags do
  puts "Generating tag pages..."
  require 'jekyll'
  
  options = Jekyll.configuration({})
  site = Jekyll::Site.new(options)
  site.read_posts('')
  site.categories.sort.each do |category, posts|
    html = ''
    html << <<-HTML
---
layout: default
title: Thoughts by rafeca
---
<h1><a href="/" title="Home">&laquo;</a> Thoughts by rafeca</h1>
<h2>Posts in category "#{category}"</h2>

<ul class="posts list">
  {% for post in site.categories.#{category} %}
    {% include post.html %}
  {% endfor %}
</ul>
    HTML
    File.open("tag/#{category}.html", 'w+') do |file|
      file.puts html
    end
    puts "tag/#{category}.html generated!"
  end
  puts 'Done!'
end