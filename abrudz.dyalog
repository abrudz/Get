:Namespace abrudz

    :Section CONST
    ⎕ML←⎕IO←1
    debug←0
    tmpDir←'/dyalog-get-tmp-dir',⍨739⌶0
    tmpZip←tmpDir,'/dyalog-get-tmp.zip'
    scriptExts←'(dyalog|apl[fonci]|function|operator|script|class|interface)'
    syncErr←⊂('EN' 11)('Message' 'Can only sync with local directory or file')
    :EndSection

    :Section IFACE
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
          ~⍺:List.Desc('    ]',⍵,' <what>[:<ext>] [-sync]')''(']',⍵,' -?? ⍝ for details and examples')
          r←2↑0 ∇ ⍵
          r,←'' '<what>  local path (relative to current dir), URI (defaults to http), workspace name (uses WSPATH), SALT name (uses WORKDIR), or user command (uses CMDDIR)'
          r,←'' ':<ext>  treat <what> as if it had the extension <ext> (d for directory, n for nested vector, s for simple vector, m for matrix)'
          r,←'' '-sync   write edits done with Editor back to file (only for local source files and directories)'
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
          r,←⊂'  apla aplc aplf apli apln aplo charlist charmat charstring charvec class csv dcf dcfg dws dyalog function interface json json5 operator script tsv xml zip'
          r,←⊂'  (all other file types are imported as character vectors)'
          r,←'' 'Gets appropriate zip/raw file from GitHub and GitLab repository/blob/release/commit URL.'
          r
      }

      Run←{ ⍝ UCMD interface
          debug::⎕DMX.Message ⎕SIGNAL ⎕EN
          params←⊃⌽⍵
          path←⊃params.Arguments
          ns←##.THIS
          ns Get path params.sync
      }
    :EndSection

    :Section UTILS
    L←{0::819⌶⍵ ⋄ ⎕C ⍵}
    Has←{×≢⍵ ⎕S 3⊢⍺}
    Norm←'^\d+|[^\w∆⍙]+'⎕R''

      Deserialise←{
          old←'⎕SE.Link.Deserialise'
          3=⎕NC old:(⍎old)⍵
          ⎕SE.Dyalog.Array.Deserialise ⍵
      }
      Download←{
          _←3 ⎕MKDIR tmpDir
          ''≡3⊃⎕NPARTS ⍵:WebZip ⍵
          WebFile ⍵
      }

      _Get←{(sync ns path)←⍺ ⍺⍺ ⍵
     
          as←⊃':\w+$'⎕S'&'⊢path
          path←':\w+$'⎕R''⊢path
     
          Encl←1⌽'$^',⊃∘⊆,'(.*)',⊃∘⌽∘⊆
          encls←Encl¨'\s+'('\x{201C}' '\x{201D}')('\x{2018}' '\x{2019}')'[\xAB\xBB]','"''`'
          path←encls ⎕R'\1'⍣≡path
     
          ']'=⊃path:sync ∇ as,⍨⊃'source: +(.*)'⎕S'\1'↓⎕SE.UCMD'uversion ',1↓path
          ~∨/'/\'∊path:sync(ns _Bare)path
     
          www←path Has'^((https?|ftp)://)?([^.\\/:]+\.)?([^.\\/:]+\.)+[^.\\/:]+/'
          path←'^file://'⎕R''⊢path
     
          (dir name ext)←⎕NPARTS path
          ext←L 1↓as⊣⍣(×≢as)⊢ext
     
          non←'dir'(,'d')''∊⍨⊂ext
          aplf←ext Has'^',scriptExts,'$'
     
          sync∧www∨non⍱aplf:⎕SIGNAL syncErr
          www:0 ∇ as,⍨Download path
     
          non:sync(ns _Dir)path
          aplf:sync(ns _LocalFile)path ⍝ normal file
     
          'zip'≡ext:0 ∇ LocalZip path
     
          'dws'≡ext:ns LocalWorkspace path
     
          name←Norm name
          Assign←name∘ns.{⍺⊣⍎⍺,'←⍵'}
     
          'dcf'≡ext:Assign(⎕FUNTIE⊢⊢(⎕FREAD,)¯1+2↓∘⍳/2↑⎕FSIZE)path ⎕FSTIE 0
          'csv'≡ext:Assign ⎕CSV path
          'tsv'≡ext:Assign ⎕CSV⍠'Separator'(⎕UCS 9)⍠'QuoteChar' ''⊢path
     
          'apla'≡ext:Assign Deserialise⊃⎕NGET path 1
          'charvec' 'charlist' 'vtv' 'nr'(,'n')'nv'∊⍨⊂ext:Assign⊃⎕NGET path 1
          'charmat' 'mat' 'cr'(,'m')'cm'∊⍨⊂ext:Assign↑⊃⎕NGET path 1
     
          debug::⎕SIGNAL⊂('EN' 11)('Message' 'Unsupported file type')
          content←⊃⎕NGET path
     
          'dcfg' 'json'∊⍨⊂4↑ext:Assign 0 ⎕JSON⍠'Dialect' 'JSON5'⊢content
          'xml'≡ext:Assign ⎕XML content
     
          Assign content ⍝ fallback: plain text
      }
    :EndSection

    :Section TYPES
      _Bare←{(sync ns path)←⍺ ⍺⍺ ⍵
          list←⎕SE.SALT.List path,' -raw -full=2'
          ×≢list:sync(ns _LocalFile)'.dyalog',⍨list⊃⍨⊂1 2
          sync:⎕SIGNAL SyncErr
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

      _Dir←{
          ls←⊃⎕NINFO⍠'Recurse' 2⍠1⊢⍵,'/*'
          scripts←ls Has'\.',scriptExts,'$'
          scripts:⍺(⍺⍺ _Link)⍵
     
          ws←'\.dws$'
          wss←ls Has ws
          wss∧⍺:⎕SIGNAL syncErr
          wss:⍺⍺ LocalWorkspace¨ws ⎕S'%'⊢ls
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

      WebFile←{
          glBlob←'(gitlab.com/[^\\]+/[^\\]+/-/)blob/' ⋄ glRaw←'\1raw/'
          ghBlob←'github.com(/[^/]+/[^/]+)/blob' ⋄ ghRaw←'raw.githubusercontent.com\1'
          url←glBlob ghBlob ⎕R glRaw ghRaw⊢⍵
          name←∊1↓⎕NPARTS url
          file←tmpDir,'/',name
          file⊣⎕CMD'curl -L -o ',file,' ',url
      }

      WebZip←{
      ⍝ https://github.com/Dyalog/link/tree/2.0 →
      ⍝ https://github.com/Dyalog/link/archive/2.0.zip
      ⍝ https://github.com/Dyalog/link →
      ⍝ https://github.com/Dyalog/link/archive/master.zip
      ⍝ https://github.com/Dyalog/link/commit/67f6b806f121a077e5c2a13c2f8f52c295d1a43b →
      ⍝ https://github.com/Dyalog/link/archive/67f6b806f121a077e5c2a13c2f8f52c295d1a43b.zip
      ⍝ https://github.com/Dyalog/ride/releases/tag/v4.3.3453 →
      ⍝ https://github.com/Dyalog/ride/archive/v4.3.3453.zip
      ⍝ https://github.com/abrudz/Kbd/releases/latest →
      ⍝ https://github.com/abrudz/Kbd/releases/tag/v15us
          ⍵ Has'(git(?:hub|lab).+/)releases/latest/?$':∇⊃'location: (.*)'⎕S'\1'⎕SH'curl -IL ',⍵
          url←'(git(?:hub|lab).+/)(?:tree|commit|releases/tag)/([^/]+)/?$' '(git(?:hub|lab).+)/?$'⎕R'\1archive/\2.zip' '\1/archive/master.zip'⍠'ML' 1⊢⍵
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
    :EndSection

    :Section TESTS
    ∇ ok←qa;targets;syncs;sync;target;ns
      targets←('^ +\]',List.Name,' ([^</C].*)')⎕S'\1'⊢1 Help List.Name
      syncs←¯6(' -sync'≡↑)¨targets
      targets↓¨⍨←¯6×syncs
      ok←⍬
      #.results←0⍴⊂''
      :For sync target :InEach syncs targets
          :Trap debug
              ⎕EX'ns' ⋄ 'ns'⎕NS ⍬
              #.results,←⊂ns Get target sync
              ok,←1
          :Else
              ⎕←'FAIL: ',(⍕⎕THIS),'.',List.Name,' ',(⎕SE.Dyalog.Utils.repObj target),sync/' 1'
              ok,←0
          :EndTrap
      :EndFor
      ok←∧/ok
    ∇
    :EndSection

:EndNamespace
