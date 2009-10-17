Templates
=========

ERB (`erb`, `rhtml`)
--------------------

[Docs](http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html) |
[Syntax](http://vision-media.ca/resources/ruby/ruby-rdoc-documentation-syntax)

### Example

    Hello <%= world %>!

### Usage

The `Tilt::ERBTemplate` class is registered for all files ending in `.erb` or
`.rhtml` by default. ERB templates support custom evaluation scopes and locals:

    >> require 'erb'
    >> template = Tilt.new('hello.html.erb', :trim => '<>')
    => #<Tilt::ERBTemplate @file='hello.html.erb'>
    >> template.render(self, :world => 'World!')
    => "Hello World!"

Or, use the `Tilt::ERBTemplate` class directly to process strings:

    require 'erb'
    template = Tilt::ERBTemplate.new(nil, :trim => '<>') { "Hello <%= world %>!" }
    template.render(self, :world => 'World!')

### Options

`:trim => '-'`

The ERB trim mode flags. This is a string consisting
of any combination of the following characters:

  * `'>'`  omits newlines for lines ending in `>`
  * `'<>'` omits newlines for lines starting with `<%` and ending in `%>`
  * `'-'`  omits newlines for lines ending in `-%>`.
  * `'%'`  enables processing of lines beginning with `%`

`:safe => nil`

The `$SAFE` level; when set, ERB code will be run in a
separate thread with `$SAFE` set to the provided level.

It's suggested that your program require 'erb' at load time when using this
template engine.
