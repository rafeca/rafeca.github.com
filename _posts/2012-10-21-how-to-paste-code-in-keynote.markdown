---
layout: post
title: How to paste code in keynote
categories: [code keynote]
---

I use **Twitter favourites** feature to mark as **read it later** tweets that contain a link that seems interesting. 
Eventually I tidy up my long list of unread interesting stuff and today I found out about the following item.

There was [this tweet](https://twitter.com/spastorino/status/250708430036295681) from [Santiago Pastorino](https://twitter.com/spastorino/) about how to include highlighted code into a Keynote.app presentation:

{% highlight bash %}
# Copy the text to the pasteboard from your editor

# <language> should be a programming language supported by pygmentize.

pbpaste | pygmentize -l <language> -f rtf | pbcopy

# Paste the pasteboard content into Keynote.app
{% endhighlight %}

As simple as that. Keynote.app recognizes automatically the RTF format and therefore the code is highlighted as defined by pygmentize. Awesome tip!

Two last comments:

* if you try to do this using **Microsoft PowerPoint** for OS X, remember to choose "Special paste". PowerPoint does not recognize automatically the RTF format, which by the way was developed by Microsoft. Great engineering work (the [http://en.wikipedia.org/wiki/Rich_Text_Format](RTF definition) with a really poor user experience ("special paste" sucks).

* if you are creating a code oriented lecture, my recommendation is you give a try to [Terminal Keynote](https://github.com/fxn/tkn). I've used it once with great results.