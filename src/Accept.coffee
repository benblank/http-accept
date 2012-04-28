###
Copyright (c) 2012 Niclas Hoyer, Fiona Schmidtke

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
###

# Accept

# ## Util Functions
# Split a string and trim its splitted pieces.
trimsplit = (str, delimiter) ->
	strs = str.split delimiter
	str.trim() for str in strs

# ## Parse Functions

# Parse parameters including quality `q` from `Accept` header field.
parseParams = (str) ->

	paramToObj = (str,obj) ->
		param = trimsplit str, '='
		obj[param[0]] = param[1]

	strs = trimsplit str, ';'
	paramstrs = strs.slice 1

	params = {}
	paramToObj param, params for param in paramstrs

	if params.q?
		q = Number params.q
	else
		q = 1

	value: strs[0], params: params, quality: q

# Parse mediatype from object.
parseMediaType = (obj) ->
	mediarange = trimsplit obj.value, '/'
	type: mediarange[0]
	subtype: mediarange[1]
	params: obj.params
	mediarange: obj.value
	quality: obj.quality

# Just return value from object.
parseStandard = (obj) ->
	obj.value

# Parse custom `Accept` header field.
parseHeaderField = (str, map, sort) ->

	if not str?
		return

	strs = trimsplit str, ','
	objects = (parseParams str for str in strs)

	map = map ? parseStandard
	sort = sort ? sortQuality

	objects = (map obj for obj in objects)

	objects.sort sort

# Parse `Accept` header field.
parseAccept = (str) ->
	str = str ? '*/*'
	parseHeaderField str, parseMediaType, sortMediaType

# ## Sort functions

# Sort objects by quality.
sortQuality = (a, b) ->
	if a.quality < b.quality
		return 1
	if a.quality > b.quality
		return -1

# Sort objects by media type and quality.
sortMediaType = (a, b) ->
	if a.quality < b.quality
		return 1
	if a.quality > b.quality
		return -1
	if a.type is '*' and b.type isnt '*'
		return 1
	if a.type isnt '*' and b.type is '*'
		return -1
	if a.subtype is '*' and b.subtype isnt '*'
		return 1
	if a.subtype isnt '*' and b.subtype is '*'
		return -1
	if Object.keys(a.params).length < Object.keys(b.params).length
		return 1
	if Object.keys(a.params).length > Object.keys(b.params).length
		return -1
	0

# Build middleware with parsers for several accept header fields.
middleware = (req, res, next) ->
	req.accept =
		types:     parseAccept      req.headers.accept
		charsets:  parseHeaderField req.headers['accept-charset']
		encodings: parseHeaderField req.headers['accept-encoding']
		languages: parseHeaderField req.headers['accept-language']
		ranges:    parseHeaderField req.headers['accept-ranges']
	next()

module.exports        = middleware
module.exports.parser = parseHeaderField
