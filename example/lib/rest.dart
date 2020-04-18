import 'dart:io' show HttpException;
import 'dart:convert' show Encoding, jsonDecode, jsonEncode;

import 'package:meta/meta.dart' show required;
import 'package:http/http.dart' as http;

typedef ErrorCheck = http.Response Function(http.Response);
typedef BodyParser<T> = T Function(String body);

/// A simple [BodyParser] doing nothing.
T ignoreBody<T>(String body) => null;

/// A simple [BodyParser] returning response body as is.
String stringBody(String body) => body;

/// A [BodyParser] parsing a `JSON` response.
dynamic jsonBody(String body) => jsonDecode(body);

/// Issues a `HTTP GET` request for [uri].
///
/// with optional [headers],
/// customized [bodyParser] to parse the response body, defaults to *ignoring*,
/// customized [errorCheck] handling HTTP status, `2xx` considered successful by default.
Future<T> get<T>(uri, {
  Map<String, String> headers,
  BodyParser<T> bodyParser,
  ErrorCheck errorCheck,
}) {
  print('GET $uri headers=$headers');
  return http.get(uri, headers: headers)
      .then(errorCheck ?? _checkHttpError)
      .then((resp) => (bodyParser ?? ignoreBody)(resp.body));
}

/// `GET` a `JSON` response from [uri].
///
/// with optional [headers],
/// customized [errorCheck] handling HTTP status, `2xx` considered successful by default.
Future<dynamic> getJson(uri, {
  Map<String, String> headers,
  ErrorCheck errorCheck,
}) => get(uri, headers: headers, bodyParser: jsonBody, errorCheck: errorCheck);

/// `HTTP POST` [body] to [uri].
///
/// with optional body [encoding] and [headers],
/// customized [bodyParser] to parse the response body, defaults to *ignoring*,
/// customized [errorCheck] handling HTTP status, `2xx` considered successful by default.
///
/// see also: [http.post]
Future<T> post<T>(uri, {
  @required dynamic body,
  Encoding encoding,
  Map<String, String> headers,
  BodyParser<T> bodyParser,
  ErrorCheck errorCheck,
}) {
  print('POST $uri headers=$headers');
  return http.post(uri,
    body: body,
    encoding: encoding,
    headers: headers,
  )
      .then(errorCheck ?? _checkHttpError)
      .then((resp) => (bodyParser ?? ignoreBody)(resp.body));
}

/// `HTTP POST` a JSON [body] to [uri].
///
/// with optional body [encoding] and [headers],
/// customized [bodyParser] to parse the response body, defaults to *ignoring*,
/// customized [errorCheck] handling HTTP status, `2xx` considered successful by default.
///
/// see also: [http.post]
Future<dynamic> postJson(uri, {
  @required dynamic body,
  Encoding encoding,
  Map<String, String> headers,
  ErrorCheck errorCheck,
}) => post(
  uri,
  body: jsonEncode(body),
  encoding: encoding,
  headers: _mergeHeaders({
    'Content-type': 'application/json',
  }, headers),
  bodyParser: jsonBody,
  errorCheck: errorCheck,
);

/// Checking HTTP status code for failures
http.Response _checkHttpError(http.Response resp) {
  if (resp.statusCode < 200 || resp.statusCode >= 300) {
    throw HttpException('${resp.request.method} ${resp.request.url} failed: ${resp.statusCode}');
  }
  return resp;
}

/// Merge [extra] headers into the [base] one
Map<String, String> _mergeHeaders(Map<String, String> base, Map<String, String> extra) {
  final headers = <String, String>{};
  if (base != null) headers.addAll(base);
  if (extra != null) headers.addAll(extra);
  return headers;
}
