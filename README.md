# Get
Import source file/dir/zip/workspace from disk/www/GitHub/wspath

## Installation

Put .dyalog file into user command folder (`⎕SE.SALTUtils.USERDIR,'/MyUCMDs/'`)

## Usage

### Function interface

`]ULoad Get` or `2⎕FIX'file://path/to/abrudz.dyalog'`

```apl
    {namespace} Get <URIs> {1}
```
`<URIs>` paths (relative to current dir) or URLs (defaults to http) or workspace names (uses WSPATH) ― can a have a suffix consisting of a colon and a file extension to override the inferred type (`d` for directory, `n` for nested vector, `s` for simple vector, `m` for matrix)

`{1}` write edits done with Editor back to file (only works for local files and directories)

`{namespace}` where to import to (default is `#`)

Examples:
```apl
    Get 'path/to/file.dyalog'
    Get 'file://path/to/file.dyalog' 'http://site.co/file.dyalog:apla' 1
    'new' Get 'https://site.co/file.dws' '/tmp/my-stuff.zip'
    utils Get 'github.com/abrudz/aplcart'
    Get 'github.com/abrudz/aplcart/blob/master/Test.aplf:n'
    Get 'raw.githubusercontent.com/abrudz/aplcart/master/Test.aplf'
```

### User command interface
```apl
    ]Get <URI>[:<ext>] [-sync]
```
`<URI>` path (relative to current dir) or URL (defaults to http) or workspace name (uses WSPATH)

`:<ext>` treat `<URI>` as if it had the extension `<ext>` (`d` for directory, `n` for nested vector, `s` for simple vector, `m` for matrix) 

`-sync` write edits done with Editor back to file (only works for local files and directories)

Examples:
```apl
    ]Get "path/to/file.dyalog"
    ]Get 'file://path/to/file.dyalog'
    ]Get http://site.co/file.dyalog:apla
    ]Get https://site.co/file.dws
    ]Get /tmp/my-stuff.zip
    ]Get github.com/abrudz/aplcart
    ]Get github.com/abrudz/aplcart/blob/master/Test.aplf:n
    ]Get raw.githubusercontent.com/abrudz/aplcart/master/Test.aplf
```
