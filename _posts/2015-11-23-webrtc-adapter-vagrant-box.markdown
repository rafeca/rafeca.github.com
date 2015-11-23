---
layout: post
title: "A virtual machine for WebRTC development"
categories: [webrtc, vagrant, html5]
---

As described in the [WebRTC project main webpage](http://www.webrtc.org/), WebRTC is a free, open project that provides browsers and mobile applications with Real-Time Communications (RTC) capabilities via simple APIs. Or in case you prefer the [Wikipedia definition](https://en.wikipedia.org/wiki/WebRTC), WebRTC (Web Real-Time Communication) is an API definition drafted by the World Wide Web Consortium (W3C) that supports browser-to-browser applications for voice calling, video chat, and P2P file sharing without the need of either internal or external plugins.

WebRTC implements three basic new APIs:

* **getUserMedia**: it represents synchronized streams of media.
* **RTCPeerConnection**: it handles stable and efficient communication of streaming data between peers.
* **DataChannel**: it enables peer-to-peer exchange of arbitrary data.

[iswebrtcreadyyet](http://iswebrtcreadyyet.com/) lists the different WebRTC functionalities that are supported by the latest version of the most widely used browers.

WebRTC APIs are still in early stages, which means that new browser versions could introdude non backwards compatible changes, and APIs name may be prefixed by a browser prefix (*moz*, *webkit*, ...), which eventually means the JS developer is in charge on building a shim to support multiple browsers in her webRTC application.

[WebRTC team](https://github.com/webrtc) has created a **[shim called adapter](https://github.com/webrtc/adapter)** as an effort for hiding those API changes and prefix differences from developers.

In case you want to get started with **adapter development**, you will need a [Debian box to ensure you can run the multi-browser tests](https://github.com/webrtc/adapter/tree/master/test).

In order to make this process simpler, I have put some effort on creating a Vagrant box called [webrtc-box](https://github.com/juandebravo/webrtc-box), that is in change of automating the development environment setup for working on WebRTC adapter.

**Running adapter tests should be as simple as**:

{% highlight bash %}

# Clone repository
host $ git clone https://github.com/juandebravo/webrtc-box.git
host $ cd webrtc-box
host $ vagrant up

# Connect to guest machine
host $ vagrant ssh

# Execute tests
vagrant@debian $ cd /adapter
vagrant@debian /adapter $ npm test

{% endhighlight %}

And that's it, you're ready to start hacking on top of **adapter**.

Happy webrtc-ing!!! :city_sunrise: :squirrel:

In case you read this post before November 20th 2015, you're on time for making a donation to our [Movember team](http://moteam.co/tu-go)!!! :man:
