MiniCoffeeCup = require '../js/mini-coffeecup'
assert = require('chai').assert

describe 'MiniCoffeeCup', ->
  it 'works in a way that is compatible with [mini-]handlebars', ->
    coffeecup = new MiniCoffeeCup format: false
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

    console.log JSON.stringify out

    assert.equal out, "<!doctype html><html><head><title>Christmas List</title></head><body><p>Hello, {{name}}!</p><p>Here are your Christmas lists ({{santa_laugh}}):</p><table><thead><tr>{{each children, name}}<th>{{name}}</th>{{/each}}</tr></thead><tbody><tr>{{each children, name}}<td>{{each list}}<ul><li>{{this}}</li></ul>{{/each}}</td>{{/each}}</tr></tbody></table></body></html>"
    assert.ok typeof doctype is 'undefined' # ensure no global leaks
