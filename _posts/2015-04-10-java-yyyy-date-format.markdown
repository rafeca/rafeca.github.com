---
layout: post
title: "Don't use YYYY in your date format template"
categories: [java]
---

**yyyy** is the pattern string to identify the year in the [SimpleDateFormat](http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html) class.

Java 7 introduced **YYYY** as a new date pattern to identify the *[date week year](http://en.wikipedia.org/wiki/ISO_week_date)*.

An average year is exactly 52.1775 weeks long, which means that eventually a year might have
either 52 or 53 weeks considering indivisible weeks.

Using **YYYY** *unintendedly* while formatting a date can cause severe issues in your Java application.

As an example:

{% highlight java %}
    import java.util.Date;
    import java.text.SimpleDateFormat;

    public class DataExample {
        public static void main(String args[]) {
            try {
                String date_s = "2015-12-31";
                SimpleDateFormat dt = new SimpleDateFormat("yyyy-MM-dd");
                Date d = dt.parse(date_s);
                SimpleDateFormat dt1 = new SimpleDateFormat("YYYY");
                System.out.println("And the year is..." + dt1.format(d));
            } catch (Exception e) {
            }
        }
    }
{% endhighlight %}

The snippet above prints "*And the year is... 2015*", because [2015 week year started on 29/12/2014](http://www.epochconverter.com/date-and-time/weeknumbers-by-year.php?year=2014).

This issue seemed to be the root cause of the [massive outage that Twitter suffered last year](http://tech.firstpost.com/news-analysis/twitter-suffers-massive-outage-on-all-online-platforms-back-now-247196.html).

So double check if you really need to use *YYYY* while formatting your date, and in case of doubt... **Better call Saul**!!

<iframe width="560" height="315"
    src="https://www.youtube.com/embed/7404XMzHr-M"
    frameborder="0"
    allowfullscreen>
</iframe>
