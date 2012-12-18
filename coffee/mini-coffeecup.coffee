not ((context, definition) ->
  if 'function' is typeof require and
     typeof exports is typeof module
    return module.exports = definition
  return context.MiniCoffeeCup = definition
)(this, (->
  # constructor
  c = (@o={}, @templates={})-> # options, and templates

  # main render function
  c.prototype.render = (f, locals) ->
    t = ''; l = 0
    _format = @o.format || false
    _indentation = (@o.format or '') and (@o.indentation or '  ')
    _linebreak = (@o.format or '') and (@o.linebreak or "\n")
    _indent = -> (new Array(l)).join _indentation
    tag = (p,s)-> (h)=>
      l++
      if typeof h is 'function'
        t+=(->
          t = ''
          h.call locals
          t = _linebreak+t+_indent() if t isnt ''
          t = _indent()+p+t+s+_linebreak
        )()
      else
        t += _indent()+p+(if typeof h is 'undefined' then '' else h)+s+_linebreak
      l--
    text = (t) -> tag '', t
    doctype = (v) -> tag((if v is 5 then '<!doctype html>' else ''), '')()
    block = (t,h) -> tag('{{'+t+'}}', '{{/'+(t.split(`/ +/`)[0])+'}}')(h)
    eval "#{_ref[_i]} = tag('<'+_ref[_i]+'>', '</'+_ref[_i]+'>')" for _i of _ref = ['html','head','body','p','ul','li','a','table', 'thead','tr','th','tbody','td','title']
    eval "#{_ref[_i]} = tag('<'+_ref[_i]+'/>')" for _i of _ref = ['link','br','hr']
    eval "(#{f}).call(locals)"
    return t

  return c
)())
