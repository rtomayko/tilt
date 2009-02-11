Tilt
====

Tilt provides a thin interface over a bunch of different template engines to
make their usage as generic possible. This is useful for web frameworks,
static site generators, and other systems that support multiple template
engines but don't want to code for each of them explicitly.

The following features are supported for all template engines (assuming the
feature is relevant to the engine):

 * Custom template evaluation scopes / bindings
 * Ability to pass locals to template evaluation
 * Support for passing a block to template evaluation for "yield"
 * Backtraces with correct filenames and line numbers
 * Template compilation caching and reloading

These template engines are currently supported with (many) more on the way:

 * ERB
 * Interpolated Ruby String
 * Haml (with the `haml` gem/library)
 * Sass (with the `haml` gem/library)
 * Builder (with the `builder` gem/library)
 * Liquid (with the `liquid` gem/library)

Usage
-----

All supported templates have an implementation class under the `Tilt` module.
Each template implementation follows the exact same interface for creation
and rendering:

    template = Tilt::HamlTemplate.new('templates/foo.haml')
    output = template.render

The `render` method takes an optional evaluation scope and locals hash
arguments. In the following example, the template is evaluated within the
context of the person object and can access the locals `x` and `y`:

    template = Tilt::ERBTemplate.new('templates/foo.erb')
    joe = Person.find('joe')
    output = template.render(joe, :x => 35, :y => 42)

The `render` method may be called multiple times without creating a new
template object. Continuing the previous example, we can render in Jane's
scope with a different set of locals:

    jane = Person.find('jane')
    output = template.render(jane, :x => 22, :y => nil)

Blocks can be passed to the render method for templates that support running
arbitrary ruby code and using `yield`. Assuming the following was in a file
named `foo.erb`:

    Hey <%= yield %>!

The block passed to the `render` method is invoked on `yield`:

    template = Tilt::ERBTemplate.new('foo.erb')
    template.render { 'Joe' }
    # => "Hey Joe!"

There's also a lightweight file extension to template engine mapping layer.
You can pass a filename or extension to `Tilt::[]` to retrieve the
corresponding implementation class:

    Tilt['hello.erb']
    # => Tilt::ERBTemplate

The `Tilt.new` works similarly but returns a new instance of the underlying
implementation class:

    template = Tilt.new('templates/foo.erb')
    output = template.render
