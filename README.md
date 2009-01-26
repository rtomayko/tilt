Tilt
====

Tilt wraps multiple template engines and makes them available through a simple
generic interface.

 * Custom scope, locals, and yield support
 * Backtraces with correct filenames and line numbers
 * Template compilation/caching
 * Template reloading

Usage
-----

All supported templates have an implementation class under the `Tilt` module.
Each template implementation follows the exact same interface:

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


Supported Template Engines
--------------------------

The following template engines are supported:

 * ERB
 * Interpolated Ruby String
 * Haml (with the `haml` gem/library)
 * Sass (with the `haml` gem/library)
 * Builder (with the `builder` gem/library)
 * Liquid (with the `liquid` gem/library)
 * Markdown (with the `rdiscount` gem)
 * Maruku (with the `maruku` gem)
 * Textile (with the `redcloth` gem)
