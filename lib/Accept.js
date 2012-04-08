var middleware, parseAccept, parseHeaderField, parseMediaType, parseParams, parseStandard, sortMediaType, sortQuality, trimsplit;

trimsplit = function(str, delimiter) {
  var strs, _i, _len, _results;
  strs = str.split(delimiter);
  _results = [];
  for (_i = 0, _len = strs.length; _i < _len; _i++) {
    str = strs[_i];
    _results.push(str.trim());
  }
  return _results;
};

parseParams = function(str) {
  var param, paramToObj, params, paramstrs, q, strs, _i, _len;
  paramToObj = function(str, obj) {
    var param;
    param = trimsplit(str, '=');
    return obj[param[0]] = param[1];
  };
  strs = trimsplit(str, ';');
  paramstrs = strs.slice(1);
  params = {};
  for (_i = 0, _len = paramstrs.length; _i < _len; _i++) {
    param = paramstrs[_i];
    paramToObj(param, params);
  }
  if (params.q != null) {
    q = Number(params.q);
  } else {
    q = 1;
  }
  return {
    value: strs[0],
    params: params,
    quality: q
  };
};

parseMediaType = function(obj) {
  var mediarange;
  mediarange = trimsplit(obj.value, '/');
  return {
    type: mediarange[0],
    subtype: mediarange[1],
    params: obj.params,
    mediarange: obj.value,
    quality: obj.quality
  };
};

parseStandard = function(obj) {
  return obj.value;
};

parseHeaderField = function(str, map, sort) {
  var obj, objects, str, strs;
  if (!(str != null)) return;
  strs = trimsplit(str, ',');
  objects = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = strs.length; _i < _len; _i++) {
      str = strs[_i];
      _results.push(parseParams(str));
    }
    return _results;
  })();
  map = map != null ? map : parseStandard;
  sort = sort != null ? sort : sortQuality;
  objects = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = objects.length; _i < _len; _i++) {
      obj = objects[_i];
      _results.push(map(obj));
    }
    return _results;
  })();
  return objects.sort(sort);
};

parseAccept = function(str) {
  str = str != null ? str : '*/*';
  return parseHeaderField(str, parseMediaType, sortMediaType);
};

sortQuality = function(a, b) {
  if (a.quality < b.quality) return 1;
  if (a.quality > b.quality) return -1;
};

sortMediaType = function(a, b) {
  if (a.quality < b.quality) return 1;
  if (a.quality > b.quality) return -1;
  if (a.type === '*' && b.type !== '*') return 1;
  if (a.type !== '*' && b.type === '*') return -1;
  if (a.subtype === '*' && b.subtype !== '*') return 1;
  if (a.subtype !== '*' && b.subtype === '*') return -1;
  if (Object.keys(a.params).length < Object.keys(b.params).length) return 1;
  if (Object.keys(a.params).length > Object.keys(b.params).length) return -1;
  return 0;
};

middleware = function(req, res, next) {
  req.types = parseAccept(req.headers.accept);
  req.charsets = parseHeaderField(req.headers['accept-charsets']);
  req.encodings = parseHeaderField(req.headers['accept-encodings']);
  req.languages = parseHeaderField(req.headers['accept-language']);
  req.ranges = parseHeaderField(req.headers['accept-ranges']);
  return next();
};

module.exports = {
  accept: middleware,
  parser: parseHeaderField
};
