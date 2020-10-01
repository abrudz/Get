:Namespace abrudz
    ⎕ML←⎕IO←1
    debug←0
    tmpDir←'/dyalog-get-tmp-dir',⍨739⌶0
    tmpZip←tmpDir,'/dyalog-get-tmp.zip'
      Get←{ ⍝ Function interface
          debug::⎕SIGNAL⊂⎕DMX.(('EN'EN)('Message'Message))
          ⍺←#
          ''≡0/⍺:⍵ ∇⍨⍎⍺ #.⎕NS ⍬ ⍝ ns name → ref
          args←⊆⍵
          num←2|⎕DR¨args
          sync←num/args
          sync,←0∩≢sync
          path←args/⍨~num
          _←3 ⎕NDELETE tmpDir
          names←1↓∊sync(' ',⍺ _Get)¨path
          _←3 ⎕NDELETE tmpDir
          names
      }
    ∇ r←List
      r←⎕NS ⍬
      r.(Group Name Desc Parse)←'ABrudz' 'Get' 'Import whatever from wherever' '1L -sync'
    ∇
      Help←{
          ~⍺:List.Desc('    ]',⍵,' <URI> [-sync]')''(']',⍵,' -?? ⍝ for details and examples')
          r←2↑0 ∇ ⍵
          r,←'' '<URI>  path (relative to current dir) or URL (defaults to http) or workspace name (uses WSPATH)'
          r,←'' '-sync  write edits done with Editor back to file (only for local source files and directories)'
          r,←'' 'Examples:'
          Eg←,/'    ]'⍵' ',⊂
          r,←Eg'"C:\tmp\testme.apln"'
          r,←Eg'''file://C:\tmp\Take.aplf'' -sync'
          r,←Eg'C:\tmp\linktest'
          r,←Eg'/tmp/myapp -sync'
          r,←Eg'/tmp/ima.zip'
          r,←Eg'github.com/mkromberg/apldemo/blob/master/Units.csv'
          r,←Eg'github.com/Dyalog/Jarvis/blob/master/Distribution/Jarvis.dws'
          r,←Eg'http://github.com/json5/json5/blob/master/test/test.json5'
          r,←Eg'https://github.com/abrudz/Kbd'
          r,←Eg'raw.githubusercontent.com/Dyalog/MiServer/master/Config/Logger.xml'
          r,←Eg'ftp://ftp.software.ibm.com/software/test/foo.txt'
          r,←Eg'''"C:\tmp\myarray.apla"'''
          r,←Eg'HttpCommand'
          r,←Eg'dfns'
          r,←Eg']box'
          r,←'' 'Supports directories and the following file types:'
          r,←⊂'  apla aplc aplf apli apln aplo charlist charmat charvec class csv dcfg dws dyalog function interface json json5 operator script tsv xml zip'
          r,←⊂'  (all other file types are assumed to be plain text)'
          r,←'' 'Gets appropriate zip/raw file from GitHub and GitLab repository/blob URL.'
          r
      }

      Run←{ ⍝ UCMD interface
          debug::⎕DMX.Message ⎕SIGNAL ⎕EN
          params←⊃⌽⍵
          path←⊃params.Arguments
          ns←##.THIS
          ns Get path params.sync
      }
      _Get←{(sync ns path)←⍺ ⍺⍺ ⍵
     
          path←'^\s+' '\s+$'⎕R''⊢path
          path←'^"(.*)"$' '^''(.*)''$'⎕R'\1'⊢path
     
          ']'=⊃path:1↓⊃'\.[^"]+'⎕S'&',ns ⎕SE.UCMD'uload ',1↓path ⍝ ucmd
          ~∨/'/\'∊path:sync(ns _Bare)path
     
          www←≢'^((https?|ftp)://)?([^.\\/:]+\.)?([^.\\/:]+\.)+[^.\\/:]+/'⎕S 3⊢path
          path←'^file://'⎕R''⊢path
     
          (dir name ext)←⎕NPARTS path
          ext←L 1↓ext
     
          non←''≡ext
          aplf←≢'^(dyalog|apl[fonci]|function|operator|script|class|interface)$'⎕S 3⊢ext
     
          sync∧www∨non⍱aplf:⎕SIGNAL⊂('EN' 11)('Message' 'Can only sync with local directory or file')
          www:0 ∇ Download path
     
          non:sync(ns _Link)path
          aplf:sync(ns _LocalFile)path ⍝ normal file
     
          'zip'≡ext:0 ∇ LocalZip path
     
          'dws'≡ext:ns LocalWorkspace path
     
          name←Norm name
          Assign←name∘ns.{⍺⊣⍎⍺,'←⍵'}
     
          'csv'≡ext:Assign ⎕CSV path
          'tsv'≡ext:Assign ⎕CSV⍠'Separator'(⎕UCS 9)⍠'QuoteChar' ''⊢path
     
          'apla'≡ext:Assign ⎕SE.Link.Deserialise⊃⎕NGET path 1
          'charvec' 'charlist'∊⍨⊂ext:Assign⊃⎕NGET path 1
          'charmat'≡ext:Assign↑⊃⎕NGET path 1
     
          debug::⎕SIGNAL⊂('EN' 11)('Message' 'Unsupported file type')
          content←⊃⎕NGET path
     
          'dcfg' 'json'∊⍨⊂4↑ext:Assign 0 ⎕JSON⍠'Dialect' 'JSON5'⊢content
          'xml'≡ext:Assign ⎕XML content
     
          Assign content ⍝ fallback: plain text
      }
    L←{0::819⌶⍵ ⋄ ⎕C ⍵}
    Norm←'^\d+|[^\w∆⍙]+'⎕R''
      _Bare←{(sync ns path)←⍺ ⍺⍺ ⍵
          list←⎕SE.SALT.List path,' -raw'
          ×≢list:(⊂1 2)⊃list⊣⎕SE.SALT.Load path,' -target=',(⍕ns),' -nolink'/⍨~sync
          sync:⎕SIGNAL⊂('EN' 11)('Message' 'Can only sync with local directory or file')
          ns LocalWorkspace path
      }
      LocalWorkspace←{
          (path name ext)←⎕NPARTS ⍵
          name←Norm name
          name⊣(⍎name ⍺.⎕NS ⍬).⎕CY ⍵
      }
      _LocalFile←{
          path←1=≡⍵
          nget←⍺<path
          _Fix←{
              uri←'file://'{⍵,⍨⍺/⍨~⊃⍺⍷⍵}⍣path⊢⍵
              src←{⊃⎕NGET(7↓⍵)1}⍣nget⊢uri
              names←⍺ ⍺⍺.⎕FIX src
              1↓∊' ',¨names
          }
          Fix←⍺⍺ _Fix∘⍵
          0::Fix 1
          Fix 2
      }
      _Link←{
          dir←⍵↓⍨-'/\'∊⍨⊃⌽⍵
          (names types)←0 1 ⎕NINFO⍠1⊢dir,'/*'
          types≡,1:⍺ ∇⊃names
          name←'-\w+$' '\W'⎕R''⊢2⊃⎕NPARTS dir
          ref←name ⍺⍺.⎕NS ⍬
          ~⎕NEXISTS dir:⎕SIGNAL⊂('EN' 22)('Message'(dir,' not found'))
          ~⍺:name⊣⎕SE.Link.Import ref dir
          opts←⎕NS ⍬
          opts.source←'dir'
          name⊣⎕SE.Link.Create ref dir
      }
      Download←{
          _←3 ⎕MKDIR tmpDir
          ''≡3⊃⎕NPARTS ⍵:GitZip ⍵
          GitFile ⍵
      }
      GitFile←{
          url←'(gitlab.com/[^\\]+/[^\\]+/-/)blob/' 'github.com(/[^/]+/[^/]+)/blob'⎕R'\1raw/' 'raw.githubusercontent.com\1'⊢⍵
          name←∊1↓⎕NPARTS url
          file←tmpDir,'/',name
          file⊣⎕CMD'curl -L -o ',file,' ',url
      }
      GitZip←{
      ⍝ https://github.com/Dyalog/link/tree/2.0 →
      ⍝ https://github.com/Dyalog/link/archive/2.0.zip
      ⍝ https://github.com/Dyalog/link →
      ⍝ https://github.com/Dyalog/link/archive/master.zip
          url←'/tree/([^/]+)/?$' '/?$'⎕R'/archive/\1.zip' '/archive/master.zip'⊢⍵
          _←⎕CMD'curl -L -o ',tmpZip,' ',url
          dir←tmpDir,'/',2⊃⎕NPARTS ⍵
          dir LocalZip tmpZip
      }
      LocalZip←{
          ⍺←tmpDir,'/',2⊃⎕NPARTS ⍵ ⍝ default dir
          _←3 ⎕MKDIR ⍺
          cmd←∊⍵ ⍺,¨⍨⊃('unzip ' ' -d ')('tar -xf ' ' -C ')⌽⍨'Windows'≡7↑⊃# ⎕WG'APLVersion'
          ⍺⊣⎕SH cmd
      }
:EndNamespace
