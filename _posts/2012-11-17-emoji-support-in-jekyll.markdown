---
layout: post
title: Emoji support in jekyll
categories: [ruby, jekyll]
---

While writing my [last post](/2012/10/28/css-changes/) I seeked for information about how to include plugins in Jekyll. [Jekyll repo wiki](https://github.com/mojombo/jekyll/wiki/Plugins) describes how easy is to write and hook specific logic to your Jekyll site.

Nonetheless, if you are using Github as hosting to deploy your Jekyll site, you cannot use plugins :worried:.

## 1. Include the **gemoji** dependency in your Gemfile

{% highlight ruby %}
gem 'gemoji', :require => 'emoji/railtie'
{% endhighlight %}

## 2. Add a configuration attribute in the **_config.yml** file

This folder will contain the emoji icons.

{% highlight yaml %}
emoji:    gfx/emoji
{% endhighlight %}

## 3. Write a rake task into the Rakefile

This rake task copies the icons included in the gemoji gem into your Jekyll site folder. It also generates a CSS file.

{% highlight ruby %}

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

{% endhighlight %}

## 4. Execute the rake task

{% highlight bash %}
rake emoji
{% endhighlight %}

Now you can check the generated CSS file that defines a specific style per emoji icon and the **png** files (the emoji icons) copied into the configured folder.

## 5. Include the generated CSS file into HTML layouts

{% highlight html %}
<link rel="stylesheet" href="/css/style.css">
{% endhighlight %}

## 6. Write a plugin that converts the emoji tags in HTML tags

Copy this content into the file **_plugins/emoji.rb**

{% highlight ruby %}

require "gemoji"

module Jekyll
  module EmojiFilter

    def emojify(content)
      if @context.registers[:site].config['emoji']
        content.to_str.gsub(/:([a-z0-9\+\-_]+):/) do |match|
          if Emoji.names.include?($1)
            "<span class='emoji emoji_#{$1}'>#{$1} emoji</span>"
          else
            match
          end
        end
      else
        content
      end
    end # emojify

  end # EmojiFilter
end # Jekyll

Liquid::Template.register_filter(Jekyll::EmojiFilter)
{% endhighlight %}

## 7. Emojify your content!

Concat the filter **emojify** in the layouts where you want to include emojies.

{% highlight html %}
<div id="post" role="main">
  {{ content | emojify }}
  
  <p class="back">&laquo; <a href="/">Home</a></p>
</div>
{% endhighlight %}

## 8. Write an emoji in a markdown file and run the server

For instance to include a smile, write **&#58;smile&#58;**

## 9. Run jekyll

{% highlight bash %}
jekyll --server --auto
{% endhighlight %}

## 10. Enjoy

:neckbeard: :squirrel: :bug: :monkey: :scream: :hankey: :smile:
