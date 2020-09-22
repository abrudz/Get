:Namespace abrudz
    ⎕ML←⎕IO←1
    tmpDir←'/dyalog-get-tmp-dir',⍨739⌶0
    tmpZip←tmpDir,'/dyalog-get-tmp.zip'
      Get←{ ⍝ Function interface
          0::⎕SIGNAL⊂⎕DMX.(('EN'EN)('Message'Message))
          ⍺←#
          ''≡0/⍺:⍵ ∇⍨⍎⍺ #.⎕NS ⍬
          args←⊆⍵
          num←2|⎕DR¨args
          sync←num/args
          sync,←0/⍨0=≢sync
          path←args/⍨~num
          _←3 ⎕NDELETE tmpDir
          names←1↓∊sync(' ',⍺ _Get)¨path
          _←3 ⎕NDELETE tmpDir
          names
      }
    ∇ r←List
      r←⎕NS ⍬
      r.(Group Name Desc Parse)←'ABrudz' 'Get' 'Import source file/dir/zip/workspace from disk/www/GitHub/wspath' '1L -sync'
    ∇
      Help←{
          ~⍺:List.Desc('    ]',⍵,' <URI> [-sync]')''(']',⍵,' -?? ⍝ for details and examples')
          r←2↑0 ∇ ⍵
          r,←'' '<URI>  path (relative to current dir) or URL (defaults to http) or workspace name (uses WSPATH)'
          r,←'' '-sync  write edits done with Editor back to file (only works for local files and directories)'
          r,←'' 'Examples:'
          Eg←,/'    ]'⍵' ',⊂
          r,←Eg'"path/to/file.dyalog"'
          r,←Eg'''file://path/to/file.dyalog'''
          r,←Eg'http://site.co/file.dyalog'
          r,←Eg'https://site.co/file.dws'
          r,←Eg'/tmp/my-stuff.zip'
          r,←Eg'github.com/abrudz/aplcart'
          r,←Eg'github.com/abrudz/aplcart/blob/master/Test.aplf'
          r,←Eg'raw.githubusercontent.com/abrudz/aplcart/master/Test.aplf'
          r
      }

      Run←{ ⍝ UCMD interface
          0::⎕DMX.Message ⎕SIGNAL ⎕EN
          params←⊃⌽⍵
          path←⊃params.Arguments
          ns←##.THIS
          ns Get path params.sync
      }
      _Get←{(sync ns path)←⍺ ⍺⍺ ⍵
          www←≢'^(https?://)?([^.\\/:]+\.)?[^.\\/:]+\.[^.\\/:]+/'⎕S 3⊢path
          www∧sync:⎕SIGNAL⊂('EN' 11)('Message' 'Cannot sync with www')
          www:0 ∇ Download path
          ext←L 3⊃⎕NPARTS path
          non←''≡ext
          zip←'.zip'≡ext
          dws←'.dws'≡ext
          dws∨←non>∨/'/\'∊path
          dws∧sync:⎕SIGNAL⊂('EN' 11)('Message' 'Cannot sync with workspace')
          dws:ns LocalWorkspace path
          non:sync(ns _Link)path
          zip:0 ∇⊃⎕NPARTS tmpDir,'/',Zip path
          sync(ns _LocalFile)path ⍝ normal file
      }
    L←{0::819⌶⍵ ⋄ ⎕C ⍵}
      LocalWorkspace←{
          (path name ext)←⎕NPARTS ⍵
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
          name←'-\w+$' '\W'⎕R''⊢2⊃⎕NPARTS dir
          ref←name ⍺⍺.⎕NS ⍬
          ~⎕NEXISTS dir:⎕SIGNAL⊂('EN' 22)('Message'(dir,' not found'))
          ~⍺:name⊣⎕SE.Link.Import ref dir
          opts←⎕NS ⍬
          opts.source←'dir'
          name⊣⎕SE.Link.Create ref dir
      }
      Download←{
          _←3(⎕MKDIR⊣⎕NDELETE)tmpDir
          ''≡3⊃⎕NPARTS ⍵:tmpDir,'/',GitHubZip ⍵
          GitHubFile ⍵
      }
      GitHubFile←{
          url←'github.com(/[^/]+/[^/]+)/blob'⎕R'raw.githubusercontent.com\1'⊢⍵
          name←∊1↓⎕NPARTS url
          file←tmpDir,'/',name
          file⊣⎕CMD'curl -L -o ',file,' ',url
      }
      GitHubZip←{
      ⍝ https://github.com/Dyalog/link/tree/2.0 →
      ⍝ https://github.com/Dyalog/link/archive/2.0.zip
      ⍝ https://github.com/Dyalog/link →
      ⍝ https://github.com/Dyalog/link/archive/master.zip
          url←'/tree/([^/]+)/?$' '/?$'⎕R'/archive/\1.zip' '/archive/master.zip'⊢⍵
          _←⎕CMD'curl -L -o ',tmpZip,' ',url
          'Windows'≡7↑⊃# ⎕WG'APLVersion':WinUnzip tmpZip
          UxUnzip tmpZip
      }
      WinUnzip←{
          _←⎕CMD'tar -xf ',⍵,' -C ',tmpDir
          ⊃⎕CMD'tar -tf ',⍵
      }
      UxUnzip←{
          rep←3⊃⎕SH'unzip ',⍵,' -d ',tmpDir
          2⊃⎕NPARTS'\S+$'⎕S'\1'⊢rep
      }
      Zip←{
          'Windows'≡7↑⊃# ⎕WG'APLVersion':WinUnzip ⍵
          UxUnzip ⍵
      }
:EndNamespace
