---
layout: post
title: How to paste code in keynote
categories: [code keynote]
---

I use **Twitter favourites** feature to mark as **read it later** tweets that contains a link apparently interesing enough to be read. And eventually today after some weeks I have been tidying up a long list of unread interesting stuff.

There was [that tweet](https://twitter.com/spastorino/status/250708430036295681) from [Santiago Pastorino](https://twitter.com/spastorino/) about how to highlight code into a Keynote.app presentation:

{% highlight bash %}
# Copy the text to the pasteboard

pbpaste | pygmentize -l ruby -f rtf | pbcopy

# Paste the pasteboard content into Keynote.app
{% endhighlight %}

As simple as that. Keynote.app recognizes automatically the RTF format and therefore the code is highlighted as defined by pygmentize. Awesome tip.

Two last comments:

* if you try to do this using **Microsoft PowerPoint** for OS X, remember to choose "Special paste". PowerPoint does not recognize automatically the RTF format, what was developed by Microsoft by the way. Great engineer work (RTF definition) with really poor user experience (select "special paste" sucks).

* if you need to do a code oriented lecture, I recommend you to give a try to [Terminal Keynote](https://github.com/fxn/tkn). I've used once and it's really straightforward.