---
layout: post
title: "Registering subclasses in python and ruby"
categories: [python, ruby]
---

Some years ago while I was contributing to the awesome Open Source project [Adhearsion](http://adhearsion.com/), we decided to split the logic contained in 1.0 version into different modules that might be loaded by the developer when needed. [Adhearsion 1.0](https://github.com/adhearsion/adhearsion/tree/v1.2.5) was tightly coupled with gems like activerecord and activesupport, which were not required for the framework basic functionality and did not provide any real value to most of the Adhearsion applications. Decoupling the logic allowed developers to include only the required dependencies in their applications.

As result of this exercise, different gems were developed to provide isolated functionalities, like [adhearsion-activerecord](https://github.com/adhearsion/adhearsion-activerecord) builds the bridge to use [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord) in an Adhearsion application.

Besides the primary goal of decoupling logic, developers should be able as well to create their own modules to extend the base functionality provided by [Adhearsion](http://adhearsion.com/). Those modules were called **plugins**.

While thinking about how to build this plugin functionality, I dug into different libraries trying to find a clean solution, and [Rails](http://rubyonrails.org/) came to the rescue. The developer that is using Rails can define her own plugins to extend the functionality of the framework or modify its initialization. These plugins are called **[Railties](http://api.rubyonrails.org/classes/Rails/Railtie.html)**. Creating a Railtie is really simple:

- inherit from [Railtie](http://api.rubyonrails.org/classes/Rails/Railtie.html) class.
- load your class during the Rails boot process.

But... how does Rails know that it should execute the code defined in the Railtie subclass while boosting itself? The trick is based on a cool feature from the Ruby language, which defines a hook in the [parent class](http://www.ruby-doc.org/core-2.1.0/Class.html#method-i-inherited) that is raised every time the class is inherited. [Here](https://github.com/rails/rails/blob/master/railties/lib/rails/railtie.rb#L129-L133) you can see the snippet of code that builds the Railtie magic.

Eventually, for [Adhearsion plugins](https://github.com/adhearsion/adhearsion/blob/develop/lib/adhearsion/plugin.rb) I followed the same rule.

Find below two snippets of code that registers a list of subclasses in both ruby and python.

{% highlight ruby %}

class Plugin

  class << self

    def inherited(base)
      registry << base
    end

    def registry
      @registry ||= []
    end

    def each(&block)
      registry.each do |member|
        block.call(member)
      end
    end

  end
end

class Foo < Plugin
end

Bar = Class.new Plugin

puts "Plugin subclasses: " + Plugin.each(&:to_s).join(', ')

{% endhighlight %}

{% highlight python %}

class Registry(type):

    def __init__(cls, name, bases, dct):
        if not hasattr(cls, 'registry'):
            # Parent class
            cls.registry = []
        else:
            # Child class
            cls.registry.append(cls)
        super(Registry, cls).__init__(name, bases, dct)


class Plugin(object):
    __metaclass__ = Registry


class Foo(Plugin):
    pass

Bar = type('Bar', (Plugin,), {})

print "Plugin subclasses: " + ", ".join([item.__name__ for item in Plugin.registry])


{% endhighlight %}

The output of both scripts is:

{% highlight bash %}

Plugin subclasses: Foo, Bar

{% endhighlight %}

Happy coding! :kissing_cat:
