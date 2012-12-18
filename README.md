# Why MiniCoffeeCup? *&Uacute;&sup3; &upsilon;&sup3;*

 * [~82% faster](http://jsperf.com/handlebars-vs-mini-coffeecup/4) than the official library compiling from markup to html on chrome/v8
 * 93.72% smaller file with just [59 lines](https://github.com/mikesmullin/mini-coffeecup/blob/production/js/mini-coffeecup.js) or [1.1KB minified (639 bytes gzipped)](https://raw.github.com/mikesmullin/mini-coffeecup/production/js/mini-coffeecup.min.js)
 * a TON more flexible; blocks are just javascript functions that take any number of arguments, and like express/sinatra we make no assumptions about which ones you want.
 * NO [dependencies](https://github.com/mikesmullin/mini-coffeecup/blob/production/package.json)

Inspired by [coffeecup](https://github.com/gradus/coffeecup),
 and [mini-handlebars](https://github.com/mikesmullin/mini-handlebars) libraries.


## Quick Example

```coffeescript
# this line is only required within node
MiniCoffeeCup = require 'mini-coffeecup'

# initialize new engine
coffeecup = new MiniCoffeeCup format: true

# provide template expression
template = (data) ->
  doctype 5
  html ->
    head ->
      title @title
    body ->
      p 'Hello, {{name}}!'
      p 'Here are your Christmas lists ({{santa_laugh}}):'
      table ->
        thead ->
          tr ->
            block 'each children, name', ->
              th '{{name}}'
        tbody ->
          tr ->
            block 'each children, name', ->
              td ->
                block 'each list', ->
                  ul ->
                    li '{{this}}'

# for example
locals =
  title: 'Christmas List'

# render coffeecup template to html
console.log coffeecup.render template, locals
```

As usual, for the latest examples, review the easy-to-follow [./test/test.coffee](https://github.com/mikesmullin/mini-coffeecup/blob/production/test/test.coffee).

Or try it immediately in your browser with [codepen](http://codepen.io/mikesmullin/pen/nIytw).


TODO
----

 * add support for attributes
 * add support for class names as first argument
 * name all html tags (atomic vs block)
 * provide all coffeescript helpers
 * support auto-escaping? i just do this automatically before i give it to coffeecup. i don't really need it.
