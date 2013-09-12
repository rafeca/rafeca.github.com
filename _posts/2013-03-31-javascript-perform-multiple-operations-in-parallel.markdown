---
layout: post
title: JavaScript, perform multiple operations in parallel
categories: [javascript]
---

I've spent bits of my spare time over the last weeks improving my JavaScript skills. I've read [Effective JavaScript: 68 Specific Ways to Harness the Power of JavaScript](http://effectivejs.com/), by [David Herman](https://twitter.com/littlecalculist); I highly recommend this book to any who wants to dig deeper into this language.

Last Thursday my pal [@rafeca](https://twitter.com/rafeca) raised an interesting question: **how could we start two or more asynchronous operations in JavaScript and execute a callback upon all of them are finished, but not before?**

One of the latest chapters of the mentioned book comes up with the answer: store responses in an ordered array and execute the callback when every response has been received (there are no pending operations).

Let's see an specific example: **retrieve a set of user profiles from a third party database and print the result in an HTML table only when all of them have been received**.

In the following five steps we'll figure out how to resolve this:

# 1.- Create the HTML skeleton to print the user profiles

{% highlight html %}

<body>
    <table>
        <thead>
            <tr>
              <th class="name">Name</th>
              <th class="profile">Profile</th>
            </tr>
        </thead>
        <tbody id="profiles"></tbody>
    </table>
    <div id="error">
    </div>
</html>

{% endhighlight %}

# 2.- Create a simple function to retrieve user profiles

For the sake of simplicity, I've mocked the profile database using an in-memory dictionary:

{% highlight javascript %}

var Profile = function(name, profile) {
    this.name = name;
    this.profile = profile;
};

var ProfileDB = (function() {
    var users = {
        john: new Profile("john", "manager"),
        mark: new Profile("mark", "developer"),
        thomas: new Profile("thomas", "QA")
    };

    var _getUserProfile = function(user, callback, error) {
            var profile = users[user];
            if(typeof profile === "undefined") {
                error("profile " + user + " not found");
            }
            else {
                if(callback) {
                    // simulate a random delay between 0 and 1 seconds
                    setTimeout(callback.bind(null, profile), 1000 * Math.random());
                }
                else {
                    return users[user];
                }
            }
        };

    return {
        getUserProfile: _getUserProfile
    };

})();

{% endhighlight %}

# 3.- Create a function to retrieve a set of users profile and execute a callback upon every profile retrieval

In this step we're building the function that will start in parallel the required operations and execute the relevant callback (success or error in case of any failure):

{% highlight javascript %}

function getUserProfiles(users, onsuccess, onerror) {
    // number of pending operations
    var pending = users.length;
    // store results in this array
    var result = [];
    if (pending === 0) {
        // execute callback if users is empty
        setTimeout(onsuccess.bind(null, result), 0);
    }
    users.forEach(function(user, i) {
        ProfileDB.getUserProfile(user, function(profile) {
            if(result) {
                result[i] = profile;
            }
            pending--;
            if(pending === 0) {
                // every profile has been retrieved, execute callback
                onsuccess(result);
            }
        }, function(error) {
            // execute error callback
            onerror(error);
        });
    });
}

{% endhighlight %}

# 4.- Create the client to retrieve a list of user profiles

Step 4 creates the client that will use the function created in step 3. We need to provide callbacks for both success and error scenearios. Upon success, users profile are printed in the HTML skeleton built in step 1. In case of error, the specific message is shown in the div element:

{% highlight javascript %}

var userElement = function(name, profile) {
    var el = document.createElement("tr");
    var _name = document.createElement("td");
    _name.appendChild(document.createTextNode(name));
    var _profile = document.createElement("td");
    _profile.appendChild(document.createTextNode(profile));
    el.appendChild(_name);
    el.appendChild(_profile);
    return el;
};

(function() {
    getUserProfiles(["john", "mark", "thomas"], function(profiles) {
        var fragment = document.createDocumentFragment();
        profiles = profiles.forEach(function(profile) {
            fragment.appendChild(userElement(profile.name, profile.profile));
        });
        document.getElementById("profiles").appendChild(fragment.cloneNode(true));
    }, function(error) {
        var el = document.getElementById("error");
        el.innerHTML= "";
        el.appendChild(document.createTextNode(error));
    });
})();

{% endhighlight %}

# 5.- Run it

In this case we're updating the DOM just once, upon retrieving the three users profile. This doesn't provide a high advantage, but if we're retrieving hundreds of elements, updating the DOM in any response may reduce significantly our application performance :squirrel:.

