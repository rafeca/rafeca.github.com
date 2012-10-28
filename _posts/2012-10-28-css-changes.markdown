---
layout: post
title: CSS changes
categories: [css]
---

Today I've been changing a bit the CSS that creates the layout of this site. Almost the whole style was defined by my pal [@rafeca](http://www.twitter.com/rafeca) while creating [his blog](http://www.rafeca.com). I have borrowed it :smile:.

Although I am not an expert on CSS, I like hacking a bit of this :sun_with_face:.

I summarize the changes in the following sections.

## Bottom links showing a "-" character

I think this is a common issue in a lot of sites: when you define a link containing an image, it may appear an annoying hyphen character on the right side of the image when the cursor is hover it. It's been happening in this blog on the footer links.

To change this behavior, remove the **img** element and define the image as background, ensuring the text inside the **a** element is indented outside the screen, far away from the visible divs.

{% highlight html %}
    <footer>
      <!-- Before -->
      <a class="fadedlink" href="https://github.com/{{site.author_short}}">
        <img src="/gfx/github-logo.png" alt="@github">
      </a>
      <!-- Now -->
      <a class="fadedlink footer_link github" href="https://github.com/{{site.author_short}}">
        @github
      </a>
    </footer>

{% endhighlight %}

{% highlight css %}

.footer_link {
  width: 25px;
  display: inline-block;
  text-indent: -1000px;
}

.github {
  background: url("/gfx/github-logo.png") no-repeat scroll 0 transparent;
}

{% endhighlight %}

## Increase body font size
This one is the easiest :sweat_smile:.

{% highlight css %}

body {
  margin: 0;
  line-height: 1.4;
  /* Before */
  font-size: 16px;
  /* Now */
  font-size: 18px;
}

{% endhighlight %}

## List style type

In both the [main](/index.html) and the [open source](/open_source.html) pages, while defining **li** elements the default circle character was being used. I've changed the CSS to support an Unicode code point using the **:before** clause.

{% highlight css %}

.container ul.posts {
	/* Do not use list decoration */
    list-style: none;
}

.container ul.posts li:before {
	/* Add a before content */
	content: "\0445";
}

{% endhighlight %}

## Predefined width on the left side while indexing stuff

The [main](/index.html) page shows a the list of posts titles and their posting date. The content was not aligned:

Before:

<li class="post" style="list-style-type:none; padding-left: 30px">
  <span>05 Aug 2012</span>
  <a title="Ensuring Array as object type" href="/2012/08/05/ensuring-array-as-object-type">Ensuring Array as object type</a>
</li>
<li class="post" style="list-style-type:none; padding-left: 30px">
  <span>24 Jul 2012</span>
  <a title="Things I like using python (part II)" href="/2012/07/24/why-python-rocks_and_two">Things I like using python (part II)</a>
</li>

After:
<li class="post" style="list-style-type:none; padding-left: 30px">
  <span class="left_title">05 Aug 2012</span>
  <a title="Ensuring Array as object type" href="/2012/08/05/ensuring-array-as-object-type">Ensuring Array as object type</a>
</li>
<li class="post" style="list-style-type:none; padding-left: 30px">
  <span class="left_title">24 Jul 2012</span>
  <a title="Things I like using python (part II)" href="/2012/07/24/why-python-rocks_and_two">Things I like using python (part II)</a>
</li>

{% highlight css %}

.left_title {
  display: inline-block;
  min-width: 110px;
}

{% endhighlight %}
