# Get
Import source file/dir/zip/workspace from disk/www/GitHub/wspath

## Installation

Put .dyalog file into user command folder (`⎕SE.SALTUtils.USERDIR,'/MyUCMDs/'`)

## Usage

### Function interface

`]ULoad Get` or `2⎕FIX'file://path/to/abrudz.dyalog'`

```apl
    {namespace} Get <URI> {1}
```
`<URI>` path (relative to current dir) or URL (defaults to http) or workspace name (uses WSPATH)

`{1}` write edits done with Editor back to file (only works for local files and directories)

`{namespace}` where to import to (default is `#`)

Examples:
```apl
    Get 'path/to/file.dyalog'
    Get 'file://path/to/file.dyalog'
    Get 'http://site.co/file.dyalog' 1
    'new' Get 'https://site.co/file.dws'
    utils Get '/tmp/my-stuff.zip'
    Get 'github.com/abrudz/aplcart'
    Get 'github.com/abrudz/aplcart/blob/master/Test.aplf'
    Get 'raw.githubusercontent.com/abrudz/aplcart/master/Test.aplf'
```

### User command interface
```apl
    ]Get <URI> [-sync]
```
`<URI>` path (relative to current dir) or URL (defaults to http) or workspace name (uses WSPATH)

`-sync` write edits done with Editor back to file (only works for local files and directories)

Examples:
```apl
    ]Get "path/to/file.dyalog"
    ]Get 'file://path/to/file.dyalog'
    ]Get http://site.co/file.dyalog
    ]Get https://site.co/file.dws
    ]Get /tmp/my-stuff.zip
    ]Get github.com/abrudz/aplcart
    ]Get github.com/abrudz/aplcart/blob/master/Test.aplf
    ]Get raw.githubusercontent.com/abrudz/aplcart/master/Test.aplf
```
