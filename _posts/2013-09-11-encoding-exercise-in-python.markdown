---
layout: post
title: "Encoding exercise in python"
categories: [python, encoding]
---

Unicode and encodings is always a fun thing. This script encodes an input string using different encodings and shows the output length:

{% highlight python %}

# -*- coding: utf-8 -*-
import sys
 
if len(sys.argv) > 1:
    code_points = [unicode(c, 'utf-8') for c in sys.argv[1:]]
else:
    # Testing values
    code_points = [u'\U0001F37A\U00000045\U0000039B', u'\U0001F37A']
 
def handle_encoding(encoding, code_point):
    try:                                                                        
        values = ['{:>15}'.format(encoding),                                      
                  ' ---> ',                                                     
                  ':'.join('{0:x}'.format(ord(c)) for c in                      
                  code_point.encode(encoding)),                                   
                  ' (', str(len(code_point.encode(encoding))), ')']               
        print ''.join(values)                                                   
    except Exception as ex:                                                     
        values = ['{:>15}'.format(encoding),                                      
                  ' ---> ',                                                     
                  'Unable to encode the codepoint in {0}'.format(encoding)]       
        print ''.join(values)  
 
for code_point in code_points:
    print '{:>15}'.format('character') + ' ---> ' + code_point
    print '{:>15}'.format('code points') + ' ---> ' + repr(code_point)
    for coding in ('ascii', 'latin-1', 'utf-8', 'utf-16', 'utf-16be', 'utf-16le'):
        handle_encoding(coding, code_point)
{% endhighlight %}

Example:

{% highlight bash %}
python encoding.py "OLA KE ASE"
      character ---> OLA KE ASE
    code points ---> u'OLA KE ASE'
          ascii ---> 4f:4c:41:20:4b:45:20:41:53:45 (10)
        latin-1 ---> 4f:4c:41:20:4b:45:20:41:53:45 (10)
          utf-8 ---> 4f:4c:41:20:4b:45:20:41:53:45 (10)
         utf-16 ---> ff:fe:4f:0:4c:0:41:0:20:0:4b:0:45:0:20:0:41:0:53:0:45:0 (22)
       utf-16be ---> 0:4f:0:4c:0:41:0:20:0:4b:0:45:0:20:0:41:0:53:0:45 (20)
       utf-16le ---> 4f:0:4c:0:41:0:20:0:4b:0:45:0:20:0:41:0:53:0:45:0 (20)
{% endhighlight %}

Happy encoding :monkey: