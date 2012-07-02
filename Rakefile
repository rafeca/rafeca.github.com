

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
    html = <<HTML
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

    file = "tag/#{green category}.html"
    puts "Creating file #{file}"
    File.open "tag/#{category}.html", 'w+' do |file|
      file.write html
    end
  end
  puts green 'Done!'
end

