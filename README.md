# Accept

Accept parses all accept header fields and sorts them according to the HTTP
specification.

## Supported Header Fields

### Accept
Parsed into `req.accept.types`.

### Accept-Charset
Parsed into `req.accept.charsets`.

### Accept-Encoding
Parsed into `req.accept.encodings`.

### Accept-Language
Parsed into `req.accept.languages`.

### Accept-Ranges
Parsed into `req.accept.ranges`.

## Installation

```bash
npm install http-accept
```

## Usage

Just `require 'http-accept'` and throw it into a connect compatible middlware
stack.

```coffeescript
connect  = require 'connect'
http     = require 'http'
accept   = require 'http-accept'

app = connect()
app.use connect.logger 'dev'
app.use accept
app.use (req, res) ->
	console.log req.accept
	res.end()

app.listen 3000
```

A request from a browser on `http://localhost:3000` would print out

```javascript
{ types: 
   [ { type: 'text',
       subtype: 'html',
       params: {},
       mediarange: 'text/html',
       quality: 1 },
     { type: 'application',
       subtype: 'xhtml+xml',
       params: {},
       mediarange: 'application/xhtml+xml',
       quality: 1 },
     { type: 'application',
       subtype: 'xml',
       params: [Object],
       mediarange: 'application/xml',
       quality: 0.9 },
     { type: '*',
       subtype: '*',
       params: [Object],
       mediarange: '*/*',
       quality: 0.8 } ],
  charsets: undefined,
  encodings: [ 'gzip', 'deflate' ],
  languages: [ 'de-de', 'de', 'en-us', 'en' ],
  ranges: undefined }
```
