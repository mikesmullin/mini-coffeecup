MiniCoffeeCup = require '../js/mini-coffeecup'
assert = require('chai').assert

describe 'MiniCoffeeCup', ->
  coffeecup = undefined
  beforeEach ->
    coffeecup = new MiniCoffeeCup format: false

  it 'works in a way that is compatible with [mini-]handlebars', ->
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

    locals =
      title: 'Christmas List'

    out = coffeecup.render template, locals
    assert.equal out, "<!doctype html><html><head><title></title></head><body><p></p><p></p><table><thead><tr>{{each children, name}}<th></th>{{/each}}</tr></thead><tbody><tr>{{each children, name}}<td>{{each list}}<ul><li></li></ul>{{/each}}</td>{{/each}}</tr></tbody></table></body></html>"
    assert.ok typeof doctype is 'undefined' # ensure no global leaks

  it 'works for the jsperf test', ->
    template = ->
      doctype 5
      html ->
        head ->
          title @title
        body ->
          p h("welcome to mike's <test> & demo site!")
          div id: 'content', ->
            for post in @posts
              div class: 'post', ->
                p post.name
                div post.comment
          form method: 'post', ->
            ul ->
              li -> input name: 'name'
              li -> textarea name: 'comment'
              li -> input type: 'submit'

    locals =
      title: 'my first website!'
      posts: [{
        name: 'Mike'
        comment: 'Hello'
      },{
        name: 'Bob'
        comment: 'How are you?'
      }]

    out = coffeecup.render template, locals
    assert.equal out, "<!doctype html><html><head><title></title></head><body><p></p><div id=\"content\"><div class=\"post\"><p></p><div></div></div><div class=\"post\"><p></p><div></div></div></div><form method=\"post\"><ul><li><input name=\"name\"/></li><li><textarea name=\"comment\"></textarea></li><li><input type=\"submit\"/></li></ul></form></body></html>"
