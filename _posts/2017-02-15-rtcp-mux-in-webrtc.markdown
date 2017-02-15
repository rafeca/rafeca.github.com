---
layout: post
title: "WebRTC. Chrome 57 to set multiplexing policy to require by default"
categories: [webrtc, html5]
---

Real-time Transport Protocol ([RTP](https://tools.ietf.org/html/rfc3550))
includes two separate components:

- the data transfer protocol itself (**RTP**).
- a control protocol associated to the data (**RTCP**, where `C` stands for *Control*).

The RTP protocol [specification](https://tools.ietf.org/html/rfc3550) states that
the "*underlying protocol MUST provide multiplexing of the data and control packets,
for example using separate port numbers with UDP*".

Due to the complexity that using two different ports derives
(mainly due to NAT traversal), [RFC-5761](https://tools.ietf.org/html/rfc5761)
provides "an alternative to demultiplexing RTP and RTCP using separate UDP ports,
instead using only a single UDP port and demultiplexing within the application."

*That's cool, how is this related to WebRTC?*

*WebRTC media negotiation* is based on Session Description Protocol
 ([SDP](https://tools.ietf.org/html/rfc4566)),
following the offer/answer model. To indicate the desire to multiplex RTP and RTCP packets,
the `a=rtcp-mux` attribute is used. This is (a partial) example of a SDP offer obtained in
[TU Go](https://go.tu.com):

{% highlight bash %}
[...]
a=rtcp:9 IN IP4 0.0.0.0
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=sendrecv
a=rtcp-mux
a=rtpmap:111 opus/48000/2
a=rtcp-fb:111 transport-cc
a=fmtp:111 minptime=10;useinbandfec=1
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=candidate:3455144793 1 udp 1685987071 95.23.241.104 62622 typ srflx raddr 192.168.1.131 rport 62622 generation 0 ufrag 9Che network-id 1 network-cost 10
[...]
{% endhighlight %}

In the example above, the offerer supports RTCP multiplexing.

In the same way, the SDP answer should include as well the `a=rtcp-mux` attribute to accept
RTCP multiplexing:

{% highlight bash %}
[...]
c=IN IP4 91.220.9.62
t=0 0
m=audio 25384 UDP/TLS/RTP/SAVPF 111 110 106
a=rtpmap:111 opus/48000/2
a=fmtp:111 useinbandfec=1; minptime=10
a=rtpmap:110 telephone-event/8000
a=rtpmap:106 CN/8000
a=ptime:20
a=rtcp-mux
a=rtcp:25384 IN IP4 91.220.9.62
a=candidate:9711301045 1 udp 659136 91.220.9.62 25384 typ host generation 0
{% endhighlight %}

*That's cool, how is this related to WebRTC?*

*WebRTC NAT traversal* is based on Interactive Connectivity Establishment methodology
([ICE](https://tools.ietf.org/html/rfc5245)). While gathering candidates:

- if RTP and RTCP are sent on separate ports, connectivity checks are required for
both components.
- if RTP and RTCP are multiplexed on the same port, only one connectivity check is required.

Negotiation for using RTP/RTCP multiplexing is done using `a=rtcp-mux`, `a=rtcp:...` and
`a:candidate ...` lines in both offer and answer.

Bottom line, **multiplexing RTP and RTCP reduces ICE overhead**, as it requires gathering less
candidates and it reduces the overhead in other parts of the VoIP architecture, e.g. less UDP
ports used in the TURN servers and less bandwidth wasted in connectivity checks.

**Cool, so what's next?**

[PeerConnection](XYZ) constructor allows the application to specify global parameters for
the media session. Among them, **the application can specify [its preferred policy
regarding use of RTP/RTCP multiplexing using one of the following policies](https://tools.ietf.org/html/draft-ietf-rtcweb-jsep-17#section-4.1.1)**:

- *negotiate*: includes the `a=rtcp-mux` attribute in the SDP, while gathering candidates
for both RTP and RTCP.
- *require*: includes the `a=rtcp-mux` attribute in the SDP, and gather only RTP candidates.
This cuts by half the number of candidates that the offerer needs to gather.

As defined in [Javascript Session Establishment Protocol](https://tools.ietf.org/html/draft-ietf-rtcweb-jsep-17),
"*the default multiplexing policy MUST be set to require*".

In reality, the default multiplexing policy has always been *<negotiate>* in both Chrome and Firefox. But that's changing in the near future.

Starting in [Chrome M57](https://groups.google.com/forum/#!topic/discuss-webrtc/eM57DEy89MY),
the [`rtcpMuxPolicy` setting has gone from *negotiate* to *require*](https://bugs.chromium.org/p/webrtc/issues/detail?id=6030).
It should not create an issue if you're doing peer to peer communications,
as browsers should be able to negotiate the RTP/RTCP multiplexing capability.
But it can indeed create issues if you're using a WebRTC Gateway or expecting
RTCP candidates in your code for any reason. [Nimble Ape describes an issue with Asterisk
interoperatibility](https://medium.com/@nimbleape/webrtc-asterisk-and-chrome-57-a706fde33780#.iqiz2tmgx),
as Asterisk does not support RTCP multiplexing.

May you need to keep the old behaviour, you can explicitly set the policy to *negotiate* while
creating the PeerConnection object.

But please be aware that [there's an intent to deprecate the *negotiate*
option](https://groups.google.com/a/chromium.org/forum/#!msg/blink-dev/OP2SGSWF5lo/v7GOaWt_CQAJ).
Chrome 58 will print a deprecation message if the rtcpMuxPolicy *negotiate* is used. JSEP
says "Implementations MAY choose to reject attempts by the application to set the multiplexing
policy to "negotiate", so be warned :smiley_cat:.

What about Firefox? Firefox is still using the *negotiate* rtcpMuxPolicy default value,
and there's no way to specify the *require* option while creating the PeerConnection object.
I've opened a ticket in [bugzilla](https://bugzilla.mozilla.org/show_bug.cgi?id=1339203)
for tracking it.

Happy media negotiation! :tiger:
