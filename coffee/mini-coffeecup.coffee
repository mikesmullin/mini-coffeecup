not ((context, definition) ->
  if 'function' is typeof require and
     typeof exports is typeof module
    return module.exports = definition
  return context.MiniCoffeeCup = definition
)(@, (->
  # constructor
  c = (@o={}, @templates={})-> # options, and templates
    # TODO: may be able to ship with html5-only support and let ppl add the rest for special cases
    @o.doctypes = @o.doctypes or {}
    @o.doctypes[5] = '<!doctype html>'
    @o.doctypes['xml'] = '<?xml version="1.0" encoding="utf-8" ?>'
    @o.doctypes['1.1'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
    @o.doctypes['basic'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
    @o.doctypes['frameset'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
    @o.doctypes['mobile'] = '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
    @o.doctypes['strict'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    @o.doctypes['transitional'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
    @o.html_block_tags = ['a','abbr','acronym','address','applet','article','aside','audio','b','bdo','big','blockquote','body','button','canvas','caption','center','cite','code','colgroup','command','datalist','dd','del','details','dfn','dir','div','dl','dt','em','embed','fieldset','figcaption','figure','font','footer','form','frameset','h1','h2','h3','h4','h5','h6','head','header','hgroup','html','i','iframe','ins','keygen','kbd','label','legend','li','map','mark','menu','meter','nav','noframes','noscript','object','ol','optgroup','option','output','p','pre','progress','q','rp','rt','ruby','s','samp','script','section','select','small','source','span','strike','strong','style','sub','summary','sup','table','tbody','td','textarea','tfoot','th','thead','time','title','tr','tt','u','ul','var','video','wbr','xmp']
    @o.html_atomic_tags = ['area','base','basefont','br','col','frame','hr','img','input','link','meta','param']
    @o.autoescape = @o.autoescape or false
    @o.special_chars = '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    @o.format = @o.format or false
    @o.indent = (@o.format or '') and (@o.indent or '  ')
    @o.newline = (@o.format or '') and (@o.newline or "\n")

  # main render function
  c.prototype.render = (f, locals) ->
    t = ''; l = 0; o = @o; o.indent = ((i)->->(new Array(l)).join i)(o.indent)
    globals =
      h: (s) -> (''+s).replace /[&<>"']/g, (c) -> o.special_chars[c] or c
      tag: (p,a,aa,s)-> -> # prefix, attributes function, after-attributes, suffix
        h = arguments[arguments.length-1]
        h = '' if typeof h isnt 'function'
        l++
        _a = if typeof arguments[0] is 'object' then a(arguments[0]) else ''
        if typeof h is 'function'
          t+=(->
            t = ''
            h.call locals
            t = o.newline+t+o.indent() if t isnt ''
            t = o.indent()+p+_a+aa+t+s+o.newline
          )()
        else
          t += o.indent()+p+_a+aa+(if typeof h is 'undefined' then '' else if o.autoescape then globals.h(h) else h)+s+o.newline
        l--
      coffeescript: (f) -> globals.script (''+f).slice(11)
      comment: (f) -> globals.tag('<!--', '-->')(f)
      doctype: (v) -> t = o.doctypes[v or 5] + t
      ie: (s,f) -> globals.tag('<!--[if '+s+']>', '<![endif]-->')(f)
      text: (s) -> t += s
      block: (s,f) -> globals.tag('{{'+s, null, '}}', '{{/'+(s.split(`/ +/`)[0])+'}}')(f)
    html_attributes = (a) ->
      tt = ''
      for k of a
        tt += if typeof a[k] isnt 'boolean' then ' '+k+'="'+a[k]+'"' else if val is true then ' ' + k else '' 
      return tt
    for tag in o.html_block_tags
      globals[tag] = globals.tag '<'+tag, html_attributes, '>', '</'+tag+'>'
    for tag in o.html_atomic_tags
      globals[tag] = globals.tag '<'+tag, html_attributes, '/>', ''
    (Function 'globals', 'locals', 'with(globals){('+f+').call(locals)}')(globals, locals)
    return t

  #c.prototype.compile = (code) ->
    # TODO: may be able to wrap the c.render() function and return it
    # TODO: for the intermediary compile-to-function,
    #       may also be able to return ''+f
    # TODO: consult my original notes from coffeecup vs handlebars jsperf
    #       for the ideal solution to above

  return c
)())
