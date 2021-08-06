---
layout: post
title:  "Site Maintenance"
date:   2021-07-30 21:13:21 +0200
categories: jekyll update
---
This is for the site maintainers - it is only useful if you want to rebuild the site.

Jekyll is very useful because it is easy to prototype GitHub pages locally. GitHub change
the *site.baseurl* to be the project id. Liquid provides a method to convert a
partial to a valid invocation: *relative_url*, see the documentation 
[here](https://jekyllrb.com/docs/liquid/filters/).

It is used like this:

{% raw %}
 href="{{ "/assets/images/e2c/ncas1-001.jpeg" &#124; relative_url }}"
{% endraw %}

Don't escape the internal quotation mark.

This particular installation has a custom *header.html* file in includes. It is
a verbatim copy of the theme's with an extra sort on *navigation_weight* added
for the navigation bar.

There is a useful page for viewing all the images (Images.md) - and Images.html

You’ll find this post in your `_posts` directory. Go ahead and edit it and re-build the site to see your changes. You can rebuild the site in many different ways, but the most common way is to run `jekyll serve`, which launches a web server and auto-regenerates your site when a file is updated.

Jekyll requires blog post files to be named according to the following format:

`YEAR-MONTH-DAY-title.MARKUP`

Where `YEAR` is a four-digit number, `MONTH` and `DAY` are both two-digit numbers, and `MARKUP` is the file extension representing the format used in the file. After that, include the necessary front matter. Take a look at the source for this post to get an idea about how it works.

Jekyll also offers powerful support for code snippets:

{% highlight ruby %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}

Check out the [Jekyll docs][jekyll-docs] for more info on how to get the most out of Jekyll. File all bugs/feature requests at [Jekyll’s GitHub repo][jekyll-gh]. If you have questions, you can ask them on [Jekyll Talk][jekyll-talk].

[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/