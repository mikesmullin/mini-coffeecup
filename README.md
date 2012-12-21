# Why MiniCoffeeCup? *&Uacute;&sup3; &upsilon;&sup3;*

 * [~23% faster](http://jsperf.com/coffeecup-vs-mini-coffeecup/2) than the official library compiling from markup to html on chrome/v8
 * 50+% smaller file with [less lines](https://github.com/mikesmullin/mini-coffeecup/blob/production/js/mini-coffeecup.js) [and even less minified](https://raw.github.com/mikesmullin/mini-coffeecup/production/js/mini-coffeecup.min.js) or gzipped
 * NO [dependencies](https://github.com/mikesmullin/mini-coffeecup/blob/production/package.json)

Inspired by [coffeecup](https://github.com/gradus/coffeecup),
 and [ck](https://github.com/aeosynth/ck),
 and [mini-handlebars](https://github.com/mikesmullin/mini-handlebars) libraries.

NOTICE:
-------

As I was developing mini-coffeecup, I had a better idea which became [coffee-templates](https://github.com/mikesmullin/coffee-templates). I will still keep mini-coffeecup around for posterity, but no new features are likely to be added.


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

 * support inline stylus?
