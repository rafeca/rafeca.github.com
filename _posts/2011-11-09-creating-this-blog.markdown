---
layout: post
title: Creating this blog
categories: [ruby, git, markdown, blog]
---

Ok... creating a blog and start talking about how you have created it looks a little bit useless...
but at least this is much more useful than a Hello World post, so in this first post I'm going to
explain a little bit how I set up everything.

# Choosing Jekyll as a blog system

Instead of using a more classic blog system like Wordpress or Drupal, I decided to try 
[Jekyll](http://jekyllrb.com/), which is a static site generator written in Ruby. It does not
require any DB and it doesn't have any dynamic generated page: it just parses a set of plain text
files that contain the posts and templates and generates static HTML files that can be 
served with any Web Server.

There is a lot of info on the net about Jekyll, you can find out more about it in 
[its official wiki](https://github.com/mojombo/jekyll/wiki/Usage).


Jekyll has a lot of advantages (and some disadvantages, also), those are the ones that made
me choose it:

## Posts are Markdown files

As I said above, Jekyll gets the blog contents from regular text files. Those text files can
have HTML code, [Textile](http://textile.sitemonks.com/) or [Markdown](http://daringfireball.net/projects/markdown/).

I've been using Markdown lately, and I find it very simple, super-easy to learn and very readable,
so in my opinion it's the best format for writing blog posts.

## It's customizable

As Jekyll creates the static HTML pages by just inserting the posts inside some defined templates,
so I can create line-by-line the HTML of the pages very easily.

This is cool, I don't have to modify some thousand-lines-html-templates with complex structures and tons
of config parameters (the same applies to those insane CSS files) anymore.

## GitHub hosting

Well, it turns out that 
[GitHub pages support Jekyll](http://pages.github.com/#using_jekyll_for_complex_layouts), so
just by creating a GIT repository with a Jekyll blog, GitHub automatically creates all the blog
static pages and each time I push new code, the blog is regenerated... an awesome hosting for free!

## GIT workflow for blogging

It's awesome to have all my posts on regular text files inside a GIT repository, so every time
I push my last commits I am publishing my pending posts.

I can even create branches for writing drafts, notes, or just vague ideas about possible future posts,
and once I finish writing the post I merge to master and voilà: the post is published.

## No web interface

I write my posts using TextMate or VIM, and publish them using the command line via GIT, this is my
regular workflow when I develop so I'm very comfortable with it.

I can do everything while offline and I can automate some tasks thanks to ZSH scripts or GIT commands.

&nbsp;

Ok, now let's talk about real stuff... Those are the basic steps I followed to create this blog,

# Creating the templates

This was actually the easiest part, I just created the main layout in `_layouts/default.html` 
and a layout for the posts  in `_layout/post.html`, which inherits from the main layout. Jekyll
uses the [Liquid template engine](http://liquidmarkup.org/), which has the following beautiful format:

{% highlight html %}
<!DOCTYPE html>
<html>
  <head>
    <title>{{ "{{ page.title"}} }}</title>
  </head>
  <body>
    {{ "{{ content"}} }}
    <ul class="posts_list">
      {{ "{% for post in site.posts " }}%}
        {{ "{% include post.html " }}%}
      {{ "{% endfor " }}%}
    </ul>
  </body>
</html>
{% endhighlight %}

You can check both templates in my GitHub repository: [`_layouts/`](https://github.com/rafeca/rafeca.github.com/blob/master/_layouts/)

# Code highlighting

Liquid automatically parses source code and highlights it when it finds the `highlight` tag:

{% highlight javascript %}
{{ "{% highlight javascript"}} %}
  setTimeout(function(){
    console.log('world');
  }, 100);
  console.log('hello');
{{ "{% endhighlight "}}%}
{% endhighlight %}

But when I was creating the blog, the last version of Liquid was the 2.3.0, which had a bug on
[code highlighting](https://github.com/imathis/octopress/issues/243) that made it crash, so I had two options:

* Downgrade Liquid version to 2.2.2
* Use [RedCarpet](https://github.com/tanoku/redcarpet), a Markdown parser created by 
[Vicent Marti](http://twitter.com/tanoku), a Catalan GitHub employee.

Obviously, I chose the second option ;) To change the markdown parser in Jekyll, I had to add
a new config parameter in the Jekyll `_config.yml` file:

{% highlight yaml %}
markdown: redcarpet
{% endhighlight %}

# Adding comments

As Jekylls creates static pages for the blog, it doesn't provide comments on the posts. So I found
3 different options to solve the issue:

* Don't provide comments justifying that nobody is going to comment on blog like this one.
* Use GitHub issues to host the comments, as it is explained
  [here](http://ivanzuzak.info/2011/02/18/github-hosted-comments-for-github-hosted-blogs.html).
  This is a really cool hack, but I didn't want to force readers to have a GitHub account and
  I wanted to allow writing the comments within the blog.
* Use DISQUS, which is a third party commenting system that provides a Javascript widget to embed
  comments to any page. 

At the end I opted for DISQUS, because it provides all the functionality that I need. Even though
I don't really like its UI and I had to tweak some of its CSS classes to make it fit properly
in the design... So maybe in the future I switch to another commenting system 

# Other fun stuff

I wanted to have a way to list all the posts with a certain tag, and to accomplish it I needed to create a
static page for every tag, which would look like this:

{% highlight html %}
---
layout: default
title: Thoughts by rafeca
---
<h1>Thoughts by rafeca</h1>
<h2>Posts in category "git"</h2>
<ul class="posts_list">
  {{"{% for post in site.categories.git "}}%}
    {{"{% include post.html "}}%}
  {{"{% endfor "}}%}
</ul>
{% endhighlight %}

To create all those pages I used a [Rake](http://rake.rubyforge.org/) task (Rake is a build library for Ruby).
I opted to use Rake because Jekyll is written in Ruby, so this way I could access natively to the Jekylls API
to get the list of tags.

This is the Rake task that I'm using (it's a slightly modified version of this [Gist](https://gist.github.com/790778)):

{% highlight ruby %}
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
<h1>Thoughts by rafeca</h1>
<h2>Posts in category "#{category}"</h2>

<ul class="posts_list">
  {{"{% for post in site.categories."}}#{category} %}
    {{"{% include post.html "}}%}
  {{"{% endfor "}}%}
</ul>
    HTML
    File.open("tag/#{category}.html", 'w+') do |file|
      file.puts html
    end
    puts 'tag/#{category}.html generated!'
  end
  puts 'Done!'
end
{% endhighlight %}

As you can see I'm iterating over all the Jekyll categories and creating the HTML file for each category.
Pretty simple, huh?

So, this way the only thing I have to do before committing a new post is to execute the Rake task:

{% highlight bash %}
$ rake tags
Generating tag pages...
Configuration from _config.yml
tag/blog.html generated!
tag/git.html generated!
tag/markdown.html generated!
tag/ruby.html generated!
Done!
{% endhighlight %}

# Conclusions

Now I can write my posts using VIM, and publish them via the command line with GIT, this way I feel much more
comfortable while writing, and I hope this will help me write more and keep the blog updated :)