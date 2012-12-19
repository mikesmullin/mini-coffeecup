not ((context, definition) ->
  if 'function' is typeof require and
     typeof exports is typeof module
    return module.exports = definition
  return context.MiniCoffeeCup = definition
)(@, (->
  # constructor
  c = (@o={}, @templates={})-> # options, and templates
    @o.doctypes = @o.doctypes or {}
    # html5-only by default; add older crap via configuration for special cases
    @o.doctypes[5] = '<!doctype html>'
    @o.html_block_tags = ['a','abbr','address','article','aside','audio','b','bdi','bdo','blockquote','body','button','canvas','caption','cite','code','colgroup','command','data','datagrid','datalist','dd','del','details','dfn','div','dl','dt','em','embed','eventsource','fieldset','figcaption','figure','footer','form','h1','h2','h3','h4','h5','h6','head','header','hgroup','html','i','iframe','ins','kbd','keygen','label','legend','li','mark','map','menu','meter','nav','noscript','object','ol','optgroup','option','output','p','pre','progress','q','ruby','rp','rt','s','samp','script','section','select','small','source','span','strong','style','sub','summary','sup','table','tbody','td','textarea','tfoot','th','thead','time','title','tr','track','u','ul','var','video','wbr']
    @o.html_atomic_tags = ['area','base','br','col','hr','img','input','link','meta','param']
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
      tag: (p,af,aa,s)->-> # prefix, attributes function, after-attributes, suffix
        l++; a=arguments
        h = ''; _a = ''
        _split = (s) -> # convert string to arguments object
          attrs = {}
          s.replace /([#.][\w\d-_]+)/g, (m) ->
            if m[0] is '.'
              attrs.class = (attrs.class or '') + (if attrs.class then ' ' else '') + m.substr 1
            else if m[0] is '#'
              attrs.id = m.substr 1
          return attrs
        if a.length is 3 and typeof a[0] is 'string' and typeof a[1] is 'object' and typeof a[2] is 'function'
          _a = _split(a[0])
          h = a[2]
        else if a.length is 2
          if typeof a[0] is 'string' and typeof a[1] is 'function'
            _a = _split(a[0])
            h = a[1]
          else if typeof a[0] is 'object' and typeof a[1] is 'function'
            _a = a[0]
            h = a[1]
          else if typeof a[0] is 'object' and typeof a[1] is 'string'
            _a = a[0]
            h = a[1]
          else if typeof a[0] is 'string' and typeof a[1] is 'string'
            _a = _split(a[0])
            h = a[1]
          else if typeof a[0] is 'string' and typeof a[1] is 'object'
            x = _split(a[0])
            _a = a[1]
            if x.class
              _a.class = (_a.class or '') + (if _a.class then ' ' else '') + x.class
            if x.id
              _a.id = x.id
        else if a.length is 1
          if typeof a[0] is 'string'
            h = a[0]
          else if typeof a[0] is 'object'
            _a = a[0]
          else if typeof a[0] is 'function'
            h = a[0]
        if typeof _a is 'object' and typeof af is 'function'
          _a = af(_a)
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
      coffeescript: (f) ->
        globals.script (''+f).replace(/^function \(\) ?{\s*/,'').replace(/\s*}$/,'')
      comment: (s,f) -> globals.tag('<!--'+s, null, '', '-->')(f)
      doctype: (v) -> t = o.doctypes[v or 5] + t
      ie: (s,f) -> globals.tag('<!--[if '+s+']>', null, '', '<![endif]-->')(f)
      text: (s) -> t += if o.autoescape then globals.h(s) else s
      block: (s,f) -> globals.tag('{{'+s, null, '}}', '{{/'+(s.split(`/ +/`)[0])+'}}')(f)
      markup: (s) -> t += s
    html_attributes = (a) ->
      tt = ''
      for k of a
        tt += if typeof a[k] isnt 'boolean' then ' '+k+'="'+(if o.autoescape then globals.h(a[k]) else a[k])+'"' else if val is true then ' ' + k else '' 
      return tt
    for tag in o.html_block_tags
      globals[tag] = globals.tag '<'+tag, html_attributes, '>', '</'+tag+'>'
    for tag in o.html_atomic_tags
      globals[tag] = globals.tag '<'+tag, html_attributes, '/>', ''
    (Function 'globals', 'locals', 'with(globals){('+f+').call(locals)}')(globals, locals)
    return t

  return c
)())
