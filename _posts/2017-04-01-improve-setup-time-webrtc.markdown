---
layout: post
title: "WebRTC. Improve the setup time with Chrome 59"
categories: [webrtc, html5, ice]
---
[WebRTC architecture](https://webrtc.org/architecture/) relies on
[ICE protocol](https://tools.ietf.org/html/rfc5245) for checking
connectivity between peers and choosing the best interface for them to communicate.
The basic idea behind ICE is that each peer in the communication has a variety of
candidate transport addresses (combination of IP address and port for
a particular transport protocol) it could use to communicate with the other peer.
ICE helps on gathering the candidate transport addresses, check connectivities
and choose the best path for the communication. **Gathering candidates require
a time that can be critical to reduce as much as possible to provide a good
user experience**.

Last week my colleague [Gustavo](https://twitter.com/anarchyco) reviewed
some slides I was preparing for [a lecture about WebRTC
in Telefonica R&D](http://www.juandebravo.com/webrtc-demo-tid/).

In one slide, I mentioned that *setLocalDescription* API indirectly controls
the candidate gathering process. Gustavo raised that the ICE candidates
gathering can start before calling *setLocalDescription*, as it's defined
in the [JSEP protocol](https://tools.ietf.org/html/draft-ietf-rtcweb-jsep-19#section-3.5.4):

> JSEP applications typically inform the JSEP implementation to begin
   ICE gathering via the information supplied to setLocalDescription, as
   this is where the app specifies the number of media streams, and
   thereby ICE components, for which to gather candidates.  However, to
   accelerate cases where the application knows the number of ICE
   components to use ahead of time, it may ask the implementation to
   gather a pool of potential ICE candidates to help ensure rapid media
   setup.

While Gustavo was right and the specification indeed mentioned that possibility,
in my tests I never was able to have such behaviour, as the candidates gathering
happened only after calling the *setLocalDescription*.

But there are good news for the near future :relaxed: : [Chrome 59](https://bugs.chromium.org/p/chromium/issues/detail?id=673395)
implements the [iceCandidatePoolSize member of
RTCConfiguration](https://www.w3.org/TR/webrtc/#dom-rtcconfiguration-icecandidatepoolsize),
that instructs the RTCPeerConnection instance to gather, as a performance
optimization, ICE candidates before calling *setLocalDescription*. No news
about when [Firefox will implement this functionality](https://bugzilla.mozilla.org/show_bug.cgi?id=1291894).

In a simple demo that you can find [here](https://jsfiddle.net/rn22efjd/4/), the
time required for getting the user media, creating the peer connection and completing
the candidates gathering is reduced from 221ms to 180ms, around 19% reduction.

Reducing as much as possible the call setup time is a key factor
for providing a good user experience, and being able to start the connectivity checks
before creating the offer will indeed help on that.
