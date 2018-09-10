---
layout: post
title: "Docker and how to get access to insecure registries"
categories: [docker]
---

I just realized 2016 passed by and this blog didn't get any update. I hope you were not worried about me! I've been fine! Just a bit busy :construction_worker:.

Last two weeks I've been playing a bit with [Docker](https://www.docker.com/). In general before getting your feet wet with a new technology, it's convenient (required?) to either go through the [usually great documentation about the project](https://docs.docker.com/) or follow [a tutorial](https://harishnarayanan.org/writing/kubernetes-django/) about it. I did the later, and as a result of it I pushed my first two docker images to [Docker Hub](https://hub.docker.com/r/juandebravo/). Nothing really impressive, but it helps you to go through the basics.

Last week I started a side project and, for it to be more interesting, I decided to go with Docker and Kubernetes :neckbeard:. It turns out that the project cannot be public, so I needed to use an internal Docker hub we're using in my current project for keeping it private.

Unfortunately, that private Docker hub is configured to accept only HTTP requests, instead of HTTPS. I know... bear with me please :pray:.

After tagging the image, I was trying to push to the docker hub repository and getting this response:

{% highlight bash %}
fish> docker push <insecure-docker-hub-hostname>/<image-name>:<image-tag>
The push refers to a repository [<insecure-docker-hub-hostname>/<image-name>]
Get https://<insecure-docker-hub-hostname>/v1/_ping: dial tcp <IP-address>:443: getsockopt: connection refused
{% endhighlight %}

Console information shows that docker is trying to connect via HTTPS to docker hub.

For overcoming this and get access via HTTP, you need to do the following:

**If you're using Mac OSX Docker client**:

* Go to Docker -> Daemon -> Basic -> Insecure registries
* Add <insecure-docker-hub-hostname> to the list
* Restart Docker

**If you're using a Linux distribution**:

* Open file `/etc/sysconfig/docker`
* Add `INSECURE_REGISTRY="--insecure-registry=<insecure-docker-hub-hostname> "`
* Restart Docker

Now you're ready to work with your insecure Docker hub!

{% highlight bash %}
fish> docker push <insecure-docker-hub-hostname>/<image-name>:<image-tag>
The push refers to a repository [<insecure-docker-hub-hostname>/<image-name>]
...
{% endhighlight %}
