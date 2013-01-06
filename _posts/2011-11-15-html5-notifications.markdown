---
layout: post
title: html5 web notifications
categories: [html5]
---

One of the HTML5 features I've played with recently is the [Web notifications API](http://www.w3.org/TR/notifications/),
which adds desktop-class notifications to the browser.

# Compatibility

The web notifications spec is still an early draft so it's subject to change, and the only browser implementing it is
Google Chrome (all the other browsers are not planning to support it in short-term), so Web notifications are only
suitable for use in few very specific scenarios... use them with care!

# Who's already using Web notifications

As the spec and the first implementation of Web notifications were written by Google, they were the first to use
them in a real world product: in fact Gmail
[has been using them](http://gmailblog.blogspot.com/2011/01/desktop-notifications-for-emails-and.html) for several months.

# How to use them

To use the Notifications API, first of all you have to let the user grant permissions to your page to show notifications.

To do so, the first to do is to check if she has already granted the permissions by calling the `checkPermission()`
method. This method returns 0 in case the user has already granted permissions and 1 if not:

{% highlight javascript %}
// function to check if the user has already granted notification permissions
var hasNotificationsPermissions = function() {
  // Check if the browser supports notifications
  if (window.webkitNotifications) {
    return window.webkitNotifications.checkPermission() === 0;
  } else {
    return false;
  }
};
{% endhighlight %}

And then use the previous function to create the method `askForPermissions()`:

{% highlight javascript %}
// function to ask for notification permissions if the user hasn't done it already
var askForPermissions = function askForPermissions() {
  if (window.webkitNotifications && !hasNotificationsPermissions) {
    window.webkitNotifications.requestPermission();
  }
};
{% endhighlight %}

Also, it's very important to point out that the `requestPermission()` method only works when it's been triggered by a
user-generated event, like a `click` or `keypress` event (to prevent unsolicited requests). So we have to create a
button in our app to ask for notification permissions:

{% highlight html %}
<button id="notification-permissions">Ask for notification permissions</button>

<script type="text/javascript">
document.querySelector('#notification-permissions').addEventListener('click', askForPermissions);
</script>
{% endhighlight %}

Once the user clicks on the button, she will get a popup which asks her to grant the website permissions:

![Grant permissions popup](/gfx/posts/html5-notifications/request-permissions-popup.png)

Once she clicks on "Allow", we'll be able to start sending notifications. As the notifications are
displayed indefinitely (once created they never disappear), I use a simple wrapper function to send
notifications with a timeout:

{% highlight javascript %}
// Sends a notification that expires after a timeout. If timeout = 0 it does not expire
var sendNotification = function sendNotification(image, title, message, timeout, showOnFocus) {
  // Default values for optional params
  timeout = (typeof timeout !== 'undefined') ? timeout : 0;
  showOnFocus = (typeof showOnFocus !== 'undefined') ? showOnFocus : true;

  // Check if the browser window is focused
  var isWindowFocused = document.querySelector(":focus") === null ? false : true;

  // Check if we should send the notification based on the showOnFocus parameter
  var shouldNotify = !isWindowFocused || isWindowFocused && showOnFocus;

  if (window.webkitNotifications && shouldNotify) {
    // Create the notification object
    var notification = window.webkitNotifications.createNotification(image, title, message);

    // Display the notification
    notification.show();

    if (timeout > 0) {
      // Hide the notification after the timeout
      setTimeout(function(){
        notification.cancel()
      }, timeout);
    }
  }
};
{% endhighlight %}

As you can see, this wrapper function has also a last argument called `showOnFocus`, which allows restricting
notifications only when the browser window is not the active window in the desktop. When no `timeout` or `showOnFocus`
parameters are specified, it behaves just identically as the original browser method.

Finally, this is how web notifications look on OSX (using Google Chrome, of course):

![Example of a web notification](/gfx/posts/html5-notifications/notification.png)

# Scope of usage

As I said before, Web notifications are only available on Google Chrome, so the usage scope is really reduced; I would
only recommend using it if:

* You are Google.
* You are doing some proof of concept of HTML5 features.
* You provide a good fallback mechanism for notifications on the other browsers (for basically the 80% of
[your visitors](http://en.wikipedia.org/wiki/Usage_share_of_web_browsers)).
* You are developing an application for the [Chrome Web Store](https://chrome.google.com/webstore).

In fact, I've been testing the Web Notifications in this last scenario, which is a perfect scenario for Web Notifications
as all the visitors will use Google Chrome for sure. Also, having desktop-class notifications in an application
is really useful, no matter if the app is being executed on a browser.

# Improvements needed in the Notifications API

Although all of this sounds good, there are some flaws in the current specification of Web Notifications:

* There is no way to only send notifications if the browser window is focused, this is a must as most times you only
want to send notifications when the user has the browser window on the background and can't see the messages rendered
on the browser window.
* There is no way to show notifications that expire, why the heck do I want to show a notification that stays in the user's
 desktop forever? There should be a timeout param in the Notifications API.

Also, the current implementation on Google Chrome would improve a lot if instead of using its own notification display
system, it were integrated with external notification systems like [Growl](http://growl.info/) or
[libnotify](http://developer.gnome.org/libnotify/).

