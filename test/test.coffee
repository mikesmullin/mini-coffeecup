MiniCoffeeCup = require '../js/mini-coffeecup'
assert = require('chai').assert

describe 'MiniCoffeeCup', ->
  coffeecup = template = out = _expecting = locals = undefined
  expecting = (s)-> _expecting = s

  beforeEach ->
    template = out = _expecting = ''
    locals = {}
    coffeecup = new MiniCoffeeCup format: false, autoescape: false # defaults

  afterEach ->
    out = coffeecup.render template, locals
    if _expecting is ''
      console.log JSON.stringify out
      assert false, 'no expectation set'
    else
      assert.equal out, _expecting
    assert.ok typeof doctype is 'undefined' # ensure no global leaks

  it 'renders tags with no ending', ->
    template = ->
      div()
    expecting '<div></div>'

  it 'renders tags with attribute objects, with no ending', ->
    template = ->
      div id: 'hamster'
    expecting '<div id="hamster"></div>'

  it 'renders tags with attribute objects, ending with string', ->
    template = ->
      div id: 'block-1', class: 'block', 'content'
    expecting "<div id=\"block-1\" class=\"block\">content</div>"

  it 'renders tags with attribute objects, ending with function', ->
    template = ->
      div id: 'block-1', class: 'block', ->
        text 'content'
    expecting "<div id=\"block-1\" class=\"block\">content</div>"

  it 'renders html comments alone', ->
    template = ->
      comment 'humans'
    expecting '<!--humans-->'

  it 'renders html comments with functions', ->
    template = ->
      comment 'humans', ->
        div id: 'are', 'kind of smelly'
    expecting "<!--humans<div id=\"are\">kind of smelly</div>-->"

  it 'renders all html5 tags, including "var" tag using markup()', ->
    template = ->
      doctype(5);a();abbr();address();area();article();aside();audio();b();base();bdi();bdo();blockquote();body();br();button();canvas();caption();cite();code();col();colgroup();command();data();datagrid();datalist();dd();del();details();dfn();div();dl();dt();em();embed();eventsource();fieldset();figcaption();figure();footer();form();h1();h2();h3();h4();h5();h6();head();header();hgroup();hr();html();i();iframe();img();input();ins();kbd();keygen();label();legend();li();link();mark();map();menu();meta();meter();nav();noscript();object();ol();optgroup();option();output();p();param();pre();progress();q();ruby();rp();rt();s();samp();script();section();select();small();source();span();strong();style();sub();summary();sup();table();tbody();td();textarea();tfoot();th();thead();time();title();tr();track();u();ul();video();wbr()
      markup '<var></var>'
    expecting "<!doctype html><a></a><abbr></abbr><address></address><area/><article></article><aside></aside><audio></audio><b></b><base/><bdi></bdi><bdo></bdo><blockquote></blockquote><body></body><br/><button></button><canvas></canvas><caption></caption><cite></cite><code></code><col/><colgroup></colgroup><command></command><data></data><datagrid></datagrid><datalist></datalist><dd></dd><del></del><details></details><dfn></dfn><div></div><dl></dl><dt></dt><em></em><embed></embed><eventsource></eventsource><fieldset></fieldset><figcaption></figcaption><figure></figure><footer></footer><form></form><h1></h1><h2></h2><h3></h3><h4></h4><h5></h5><h6></h6><head></head><header></header><hgroup></hgroup><hr/><html></html><i></i><iframe></iframe><img/><input/><ins></ins><kbd></kbd><keygen></keygen><label></label><legend></legend><li></li><link/><mark></mark><map></map><menu></menu><meta/><meter></meter><nav></nav><noscript></noscript><object></object><ol></ol><optgroup></optgroup><option></option><output></output><p></p><param/><pre></pre><progress></progress><q></q><ruby></ruby><rp></rp><rt></rt><s></s><samp></samp><script></script><section></section><select></select><small></small><source></source><span></span><strong></strong><style></style><sub></sub><summary></summary><sup></sup><table></table><tbody></tbody><td></td><textarea></textarea><tfoot></tfoot><th></th><thead></thead><time></time><title></title><tr></tr><track></track><u></u><ul></ul><video></video><wbr></wbr><var></var>"

  it 'can autoescape text and attributes', ->
    coffeecup = new MiniCoffeeCup autoescape: true
    template = ->
      p "& D'oh! ><"
      div data: "& D'oh! ><"
      text "& D'oh! ><"
    expecting "<p>&amp; D&#39;oh! &gt;&lt;</p><div data=\"&amp; D&#39;oh! &gt;&lt;\"></div>&amp; D&#39;oh! &gt;&lt;"

  it 'renders local variables', ->
    locals = user: name: 'Jimmy'
    template = ->
      p "Welcome #{@user.name}!"
    expecting "<p>Welcome Jimmy!</p>"

  it 'renders handlebars markup', ->
    locals = title: 'Christmas List'
    template = ->
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
    expecting "<p>Hello, {{name}}!</p><p>Here are your Christmas lists ({{santa_laugh}}):</p><table><thead><tr>{{each children, name}}<th>{{name}}</th>{{/each}}</tr></thead><tbody><tr>{{each children, name}}<td>{{each list}}<ul><li>{{this}}</li></ul>{{/each}}</td>{{/each}}</tr></tbody></table>"

  it 'can iterate local variables', ->
    # test borrowed from ck lib
    locals =
      title: 'my first website!'
      posts: [{
        name: 'Mike'
        comment: 'Hello'
      },{
        name: 'Bob'
        comment: 'How are you?'
      }]
    template = ->
      doctype 5
      html ->
        head ->
          title @title
        body ->
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
    expecting "<!doctype html><html><head><title>my first website!</title></head><body><div id=\"content\"><div class=\"post\"><p>Mike</p><div>Hello</div></div><div class=\"post\"><p>Bob</p><div>How are you?</div></div></div><form method=\"post\"><ul><li><input name=\"name\"/></li><li><textarea name=\"comment\"></textarea></li><li><input type=\"submit\"/></li></ul></form></body></html>"

  it 'renders style and script tags', ->
    template = ->
      style '''
        body {font-family: sans-serif}
        header, nav, section, footer {display: block}
      '''
      script '''
        alert('hello!');
        console.log('how are you');
      '''
    expecting "<style>body {font-family: sans-serif}\nheader, nav, section, footer {display: block}</style><script>alert('hello!');\nconsole.log('how are you');</script>"

  it 'renders plain text'
  #  template = ->
  #    p ->
  #      text 'hello'
  #      strong 'this is the hard way'
  #      '.'
  #  expecting "<p>hello<strong>this is the hard way</strong>.</p>"

  it 'returns rendered output as string with render()'
  #  template = ->
  #    p "This text could use #{render -> a href: '/', 'a link'}."

  it 'renders markup manually', ->
    template = ->
      markup '<var>tag is annoying in coffeescript/javascript</var>'
    expecting "<var>tag is annoying in coffeescript/javascript</var>"

  it 'renders ie conditional comments', ->
    template = ->
      ie 'gte IE8', ->
        link href: 'ie.css', rel: 'stylesheet'
    expecting "<!--[if gte IE8]><link href=\"ie.css\" rel=\"stylesheet\"/><![endif]-->"

  it 'optionally renders formatted output', ->
    coffeecup = new MiniCoffeeCup format: true
    template = ->
      doctype 5
      html ->
        head ->
          meta charset: 'utf-8'
          title "#{@title or 'Untitled'} | A completely plausible website"
          meta(name: 'description', content: @description) if @description?
          link rel: 'stylesheet', href: '/css/app.css'
    expecting "<!doctype html><html>\n  <head>\n    <meta charset=\"utf-8\"/>\n    <title>Untitled | A completely plausible website</title>\n    <link rel=\"stylesheet\" href=\"/css/app.css\"/>\n  </head>\n</html>\n"

  it 'renders selector-style #id and .class names'
  #  template = ->
  #    div '#hamster', ->
  #      div '.cat', ->
  #        div '#gerbil.rat'

  it 'renders with compiled coffeescript', ->
    template = ->
      coffeescript ->
        jQuery ->
          alert 'Alerts suck!'
    expecting "<script>return jQuery(function() {\n            return alert('Alerts suck!');\n          });</script>"

  it 'renders with compiled stylus'
  it 'can compile to a function'
