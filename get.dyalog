﻿:Namespace get ⍝ 1.01
⍝ 2021 03 24 Adam: Port from github.com/abrudz/get

    :Section CONST ─────
    debug←0 ⋄ ⎕ML←1 ⋄ ⎕IO←1
    desc←'Fetch data/code in many formats from local or remote sources'

    :namespace tmp
        dir←'/dyalog-get-tmp-dir',⍨739⌶0
        zip←dir,'/dyalog-get-tmp.zip'
    :endnamespace

    :namespace sys
        scripts←'(dyalog|apl[fonci]|function|operator|script|class|interface)'
        (os ver)←⊢∘⍎\3↑¨2↑# ⎕WG'APLVersion'
        ellip←⎕UCS 8230(3⍴46)⊃⍨1+82=⎕DR''
    :endnamespace

    :Namespace gh
        latest←'^(https?://)(?:www\.)?github.com(/[^/]+/[^/]+/releases/latest)/?$'
        api←'\1api.github.com/repos\2'

        repo←'^(https?://)?(?:www\.)?(github.com)(/[^/]+/[^/]+)/?$'
        zipball←'\1api.\2/repos\3/zipball'

        specific←'^(https?://(?:www\.)?github.com/[^/]+/[^/]+/)(?:commit|releases/tag|tree)(/[^/]+)/?$'
        zip←'\1archive\2.zip'

        blob←'github.com(/[^/]+/[^/]+)/blob'
        raw←'raw.githubusercontent.com\1'
    :EndNamespace

    :Namespace gl
        blob←'(gitlab.com/[^\\]+/[^\\]+/-/)blob/'
        raw←'\1raw/'
    :EndNamespace

    :Namespace web
        url←'^((https?|ftp)://)?([^.\\/:]+\.)?([^.\\/:]+\.)+[^.\\/:]+/'
    :endnamespace
    :EndSection

    :Section ERROR ─────
    :Namespace error
        Resignal←{⎕SIGNAL⊂⎕DMX.(('EN'EN)('Message'Message))}
        Conform←{⎕SIGNAL('EN' 5)('Message' 'Number of sync flags must be 0 or 1 or match the number of sources')}
        Old←{⎕DMX.(Message ⎕SIGNAL EN)}
        Sync←{⎕SIGNAL⊂('EN' 11)('Message' 'Can only sync with local directory or file')}
        Missing←{⎕SIGNAL⊂('EN' 22)('Message'(⍵,' not found'))}
    :Endnamespace
    :EndSection

    :Section IFACE ─────
      Get←{ ⍝ Function interface
          debug::error.Resignal ⍬
          dyad←×⎕NC'⍺'
          ⍺←⊃⎕XSI
          ''≡0/⍺:⍵ ∇⍨⍎⍺ #.⎕NS ⍬ ⍝ ns name → ref
          3≤|≡⍵:Join ⍺ ∇¨⍵
     
          args←⊆⍵
          num←2|⎕DR¨args
          sync←num/args
          path←args/⍨~num
          ~(≢sync)∊0 1,≢path:error.Conform ⍬
     
          _←cleanup
          names←Join sync(⍺ _Get)¨path
          _←cleanup
     
          target←dyad/'.',⍨,⍕⍺
          Join target∘,¨' '(≠⊆⊢)names
      }

    ∇ r←List
      r←⎕NS ⍬
      r.(Group Name Desc Parse)←'DevOps' 'Get'desc'99S -sync -target='
    ∇

      Help←{
          0=⍺:(⊂desc),Syntax ⍵
          r←0 ∇ ⍵
          b←3↑r
          a←2↓r
          a/⍨←~@(1+⍺)⊢1⍨¨a
          Fmt←{b,⍵,a}
          1=⍺:Fmt Details ⍵
          2=⍺:Fmt Examples ⍵
      }

      Run←{ ⍝ UCMD interface
          debug∨←⎕SE.SALTUtils.DEBUG
          Msgs←{
              _←⎕DL 1
              ride←3501⌶⍬
              nl←⎕UCS 13
              ⍞←'Working on it',sys.ellip,ride⍴nl
              ride:{≡⍞←'Still working on it',sys.ellip,nl⊣⎕DL 2}⍣≢1 ⍝ RIDE
              {⍴⍞←sys.ellip⊣⎕DL 0.5}⍣≢⍬
          }
          thread←Msgs&⍣(~debug)⊢⍬
          debug::error.Old ⎕TKILL thread
          params←⊃⌽⍵
          path←params.Arguments
          ns←⍎∘params.target⍣(0≢params.target)⊢##.THIS
          (⎕TKILL thread)⊢ns Get path,params.sync
      }
    :EndSection

    :Section UHELP ─────
      Syntax←{
          r←,⊂'    ]',⍵,' <source>[:<ext>] [-target=<ns>] [-sync]'
          r,←⊂''
          r,←⊂']',⍵,' -??   ⍝ for details'
          r,←⊂']',⍵,' -???  ⍝ for examples'
          r
      }
      Details←{
          r←,⊂'<source>  local path (relative to current dir), URI (defaults to http), workspace name (uses WSPATH), SALT name (uses WORKDIR), or user command (uses CMDDIR)'
          r,←⊂''
          r,←⊂':<ext>    treat <source> as if it had the extension <ext> (d for directory, n for nested vector, s for simple vector, m for matrix)'
          r,←⊂''
          r,←⊂'-target=  put imported things into <ns> (default is current namespace)'
          r,←⊂''
          r,←⊂'-sync     attempt to establish synchronisation between <source> and <ns> (only for local source files and directories)'
          r,←⊂''
          r,←⊂']',⍵,' is a development tool intended as a one-stop utility for quickly getting bringing resources into the workspace while programming. Do not use at run time, as exact results may vary. Instead, use precisely documented features like ⎕JSON, ⎕CSV, ⎕XML, and ⎕FIX in combination with loading tools like ⎕NGET, HttpCommand, ⎕SE.Link.Import, etc.'
          r,←⊂''
          r,←⊂']',⍵,' supports importing directories and the following file extensions (files with any other extensions are imported as character vectors):'
          r,←⊂'  apla aplc aplf apli apln aplo charlist charmat charstring charvec class csv dcf dcfg dws dyalog function interface js json json5 operator script tsv xml zip'
          r,←⊂''
          r,←⊂'Notes:'
          r,←⊂' ∘  GitHub repository/blob/release/commit URLs are parsed to determine the appropriate zip file (which is then extracted and imported) or source file.'
          r,←⊂' ∘  Supported formats like JSON, CSV, and XML, are converted to APL arrays based on file extensions.'
          r,←⊂' ∘  You can direct ]',⍵,' to act on a file as if it had a different extension by appending a colon (:) followed by the normal extension, for example myfile.txt:json'
          r
      }
      Examples←{
          r←,⊂'Examples:'
          Eg←,/'    ]'⍵' ',⊂
          r,←Eg'"C:\tmp\testme.apln"'
          r,←Eg'''file://C:\tmp\Take.aplf'' -sync'
          r,←Eg'C:\tmp\linktest'
          r,←Eg'/tmp/myapp -sync'
          r,←Eg'/tmp/ima.zip'
          r,←Eg'github.com/mkromberg/apldemo/blob/master/Units.csv'
          r,←Eg'github.com/Dyalog/Jarvis/blob/master/Distribution/Jarvis.dws'
          r,←Eg'http://github.com/json5/json5/blob/master/test/test.json5'
          r,←Eg'http://github.com/json5/json5/blob/master/test/test.json5:v'
          r,←Eg'https://github.com/abrudz/Kbd'
          r,←Eg'raw.githubusercontent.com/Dyalog/MiServer/master/Config/Logger.xml'
          r,←Eg'ftp://ftp.software.ibm.com/software/test/foo.txt'
          r,←Eg'''"C:\tmp\myarray.apla"'''
          r,←Eg'HttpCommand -target=⎕SE'
          r,←Eg'dfns'
          r,←Eg']box'
          r,←Eg']box:vtv'
          r
      }
    :endsection

    :Section TESTS ─────
    ∇ ok←qa;targets;syncs;sync;target;ns;whats;what;call
      ok←⍬
      3 ⎕MKDIR'/tmp/myapp'
      'foo←{⍵ ⍵ ⍵}'⎕NPUT'/tmp/myapp/foo.aplf' 1
      :For call :In 1↓Examples List.Name
          :If ∨/'ima.zip'⍷call
              :Continue
          :EndIf
          :If debug
              ⎕←call
          :EndIf
          :Trap debug
              ⎕EX'ns' ⋄ 'ns'⎕NS ⍬
              ⎕CS ns
              {}⎕SE.UCMD call
              ⎕CS ##
              ok,←1
          :Else
              ⎕CS ##
              ⎕←'*** FAIL: ',call
              ok,←0
          :EndTrap
      :EndFor
      3 ⎕NDELETE'/tmp/myapp'
      ok←∧/ok
    ∇
    :EndSection

    :Section TYPES ─────
    Unslash←{⍵↓⍨-'/\'∊⍨⊃⌽⍵}

      _Bare←{(sync ns path)←⍺ ⍺⍺ ⍵
          list←⎕SE.SALT.List path,' -raw -full=2'
          ×≢list:sync(ns _LocalFile)'.dyalog',⍨list⊃⍨⊂1 2
          sync∧⎕NEXISTS path:error.Sync ⍬
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
          (dir origDir)←Unslash¨2⍴⊆⍵
          (names types)←0 1 ⎕NINFO⍠1⊢dir,'/*'
          types≡,1:⍺ ∇(⊃names)origDir
     
          (names types)←0 1 ⎕NINFO⍠'Recurse' 2⍠1⊢dir,'/*'
          files←names/⍨2=types
     
          scripts←files Has'\.',sys.scripts,'$'
          scripts:⍺(⍺⍺ _Link)dir origDir
     
          ws←'\.dws$'
          wss←files Has ws
          wss∧⍺:error.Sync ⍬
          wss:⍺⍺ LocalWorkspace¨ws ⎕S'%'⊢files
     
          Join ⍺(⍺⍺ _Get)¨files
      }

      _Link←{
          (dir origDir)←Unslash¨2⍴⊆⍵
          (names types)←0 1 ⎕NINFO⍠1⊢dir,'/*'
          types≡,1:⍺ ∇(⊃names)origDir
          name←Norm⊢2⊃⎕NPARTS origDir
          ref←name ⍺⍺.⎕NS ⍬
          ~⎕NEXISTS dir:error.Missing dir
          opts←⎕NS ⍬
          opts.source←'dir'
          opts.fastLoad←1
          opts.overwrite←1
          ~⍺:name⊣opts ⎕SE.Link.Import ref dir
          name⊣opts ⎕SE.Link.Create ref dir
      }

      WebFile←{
          url←gl.blob gh.blob ⎕R gl.raw gh.raw⊢⍵
          name←∊1↓⎕NPARTS url
          file←tmp.dir,'/',name
          file Curl url
      }

      WebZip←{
     
          ⍝ github.com/USER/REPO/
          ⍝                                          → zipball/
          ⍝                      archive/NAME.zip    → archive/NAME.zip
          ⍝                      commit/NAME         → archive/NAME.zip
          ⍝                      releases/tag/NAME   → archive/NAME.zip
          ⍝                      releases/latest     → zipball_url from https://api.github.com/repos/{user}/{repo}/releases/latest
          ⍝                      tree/NAME           → /archive/NAME.zip
     
          dir←tmp.dir,'/',2⊃⎕NPARTS Unslash ⍵
          (HasExt∧∘~Has∘gh.specific)⍵:dir LocalZip tmp.zip Curl ⍵
          ×≢api←∊gh.(latest ⎕S api)⍵:∇ ZipURL api
          url←gh.(repo specific ⎕R zipball zip)⍵
          dir←tmp.dir,'/',2⊃⎕NPARTS ⍵
          dir LocalZip tmp.zip Curl url
      }

      ZipURL←{
          req←⎕SE.SALT.New'HttpCommand'('Get'⍵)
          data←req.Run.Data
          ns←0 ⎕JSON data
          ns.zipball_url
      }

      Curl←{
          _←⎕CMD'curl -L -o ',⍺,' ',⍵
          'not found'≡L⊃⎕NGET ⍺:error.Missing ⍵
          ⍺
      }

      LocalZip←{
          ⍺←tmp.dir,'/',2⊃⎕NPARTS ⍵ ⍝ default dir
          _←3 ⎕MKDIR ⍺
          cmd←∊⍵ ⍺,¨⍨⊃('unzip ' ' -d ')('tar -xf ' ' -C ')⌽⍨'Win'≡sys.os
          ⍺⊣⎕NDELETE ⍵⊣⎕SH cmd
      }
    :EndSection

    :Section UTILS ─────
    L←{18≤sys.ver:⎕C ⍵ ⋄ 819⌶⍵}
    Has←{×≢⍵ ⎕S 3⊢⍺}
    Norm←'^\d' '[-. ]+' '[^\d\wÀ-ÖØ-Ýß-öø-üþ∆⍙Ⓐ-Ⓩ]+'⎕R'_&' '_' ''
    Join←{1↓∊' ',¨⍵}
    HasExt←''≢3⊃⎕NPARTS

    ∇ {r}←cleanup
      3 ⎕NDELETE tmp.dir
      r←⍬
    ∇

      IsDir←{
          ⎕NEXISTS ⍵:1=1 ⎕NINFO ⍵
          0
      }
    ∇ F←Deserialise
      :If 3=⎕NC old←'⎕SE.Link.Deserialise'
          F←⍎old
      :Else
          F←⎕SE.Dyalog.Array.Deserialise
      :EndIf
      ⎕EX⊃⎕SI
      Deserialise←F
    ∇

      Download←{
          _←3 ⎕MKDIR tmp.dir
          (Has∘gh.specific∨~∘HasExt)⍵:WebZip ⍵
          WebFile ⍵
      }

      ExpEnv←{
          untilded←'(\W|^)~\+' '(\W|^)~-' '(\W|^)~(\W|$)'⎕R'\1[PWD]' '\1[OLDPWD]' '\1[HOME]\2'⍠'UCP' 1⊢⍵
          bracked←'\$env:([\pL_]\w*)' '\$([\pL_]\w*)' '\$\{([^}]+)}' '\[([^]]+)]' '%([^%]+)%'⎕R'[\1]'⍠'UCP' 1⊢untilded
          '\[([^]]+)]'⎕R{⎕SE.Dyalog.Utils.Config 1↓¯1↓⍵.Match}bracked
      }

      _Get←{(sync ns path)←⍺ ⍺⍺ ⍵
     
          as←⊃':\w+$'⎕S'&'⊢path               ⍝ extract type
          path←'^\s+' ':\w+$' '\s+$'⎕R''⊢path ⍝ strip blanks and type
     
          path←ExpEnv path
     
          Encl←1⌽'$^',⊃∘⊆,'(.*)',⊃∘⌽∘⊆ ⍝ e.g. "→"abc" and `´→`abc´
          encls←Encl¨'"''`',('\x{201C}' '\x{201D}')'[\xAB\xBB]'('\x{2018}' '\x{2019}')
          path Has encls:⍺ ∇ encls ⎕R'\1'⊢path
     
          ∨/'*?'∊path:Join sync ∇¨⊃⎕NINFO⍠1⊢path
     
          ']'=⊃path:sync ∇ as,⍨⊃'source: +(.*)'⎕S'\1'↓⎕SE.UCMD'uversion ',1↓path
          ~∨/'/\'∊path:sync(ns _Bare)path
     
          www←path Has web.url
          path←'^file://'⎕R''⊢path
     
          (dir name ext)←⎕NPARTS path
          ext←L 1↓as⊣⍣(×≢as)⊢ext
     
          non←'dir'(,'d')''∊⍨⊂ext
          non∨←IsDir path
          aplf←ext Has'^',sys.scripts,'$'
     
          sync∧www∨non⍱aplf:error.Sync ⍬
          www:0 ∇ as,⍨Download path
     
          non:sync(ns _Dir)path
          aplf:sync(ns _LocalFile)path ⍝ normal file
     
          'zip'≡ext:0 ∇ LocalZip path
     
          'dws'≡ext:ns LocalWorkspace path
     
          name←Norm name
          Assign←name∘ns.{⍺⊣⍎⍺,'←⍵'}
     
          'dcf'≡ext:Assign(⎕FUNTIE⊢⊢(⎕FREAD,)¯1+2↓∘⍳/2↑⎕FSIZE)path ⎕FSTIE 0
          'csv'≡ext:Assign ⎕CSV⍠'Trim' 0⊢path
          'tsv' 'tab'∊⍨⊂ext:Assign ⎕CSV⍠'Trim' 0⍠'Separator'(⎕UCS 9)⍠'QuoteChar' ''⊢path
          'ssv'≡ext:Assign ⎕CSV⍠'Trim' 0⍠'Separator' ';'⍠'QuoteChar' ''⍠'Decimal' ','⊢path
          'psv'≡ext:Assign ⎕CSV⍠'Trim' 0⍠'Separator' '|'⍠'QuoteChar' ''⊢path
     
          'apla'≡ext:Assign Deserialise⊃⎕NGET path 1
          'charvec' 'charlist' 'vtv' 'nr'(,'n')'nv'∊⍨⊂ext:Assign⊃⎕NGET path 1
          'charmat' 'mat' 'cr'(,'m')'cm'∊⍨⊂ext:Assign↑⊃⎕NGET path 1
     
          content←⊃⎕NGET path
     
          'dcfg' 'js' 'json' 'json5'∊⍨⊂4↑ext:Assign 0 ⎕JSON⍠'Dialect' 'JSON5'⊢content
          'xml'≡ext:Assign ⎕XML content
     
          Assign content ⍝ fallback: plain text
      }
    :EndSection

:EndNamespace
