---
layout: default
---

<div id="archives">
{% assign sorted = site.categories | sort %}
{% for category in {{sorted}} %}
  <div class="archive-group">
    {% capture category_name %}{{ category | first }}{% endcapture %}
    <div id="#{{ category_name | slugize }}"></div>
    <p></p>

    <a name="{{ category_name | slugize }}">
      <h3 class="category-head">
        {{ category_name | upcase}}
      </h3>
    </a>
    <ul>
    {% for post in site.categories[category_name] %}
    <li class="post">
    <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a>
    </li>
    {% endfor %}
    </ul>
  </div>
{% endfor %}
</div>