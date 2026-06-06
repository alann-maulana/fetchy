class CurlParseResult {
  final String method;
  final String url;
  final Map<String, String> headers;
  final String? body;
  final String? authUsername;
  final String? authPassword;

  const CurlParseResult({
    this.method = 'GET',
    this.url = '',
    this.headers = const {},
    this.body,
    this.authUsername,
    this.authPassword,
  });
}

class CurlParser {
  static CurlParseResult parse(String input) {
    final trimmed = input.trim();
    if (!trimmed.toLowerCase().startsWith('curl ')) {
      return const CurlParseResult();
    }

    var method = 'GET';
    String? url;
    final headers = <String, String>{};
    final bodyParts = <String>[];
    String? authUsername;
    String? authPassword;

    final args = _tokenize(trimmed.substring(5).trim());

    var i = 0;
    while (i < args.length) {
      final arg = args[i];

      if (arg == '-X' || arg == '--request') {
        if (i + 1 < args.length) {
          method = args[i + 1].toUpperCase();
          i += 2;
          continue;
        }
      } else if (arg == '-H' || arg == '--header') {
        if (i + 1 < args.length) {
          final header = args[i + 1];
          final colon = header.indexOf(':');
          if (colon > 0) {
            final key = header.substring(0, colon).trim();
            var value = header.substring(colon + 1).trim();
            if (value.startsWith(' ')) value = value.trim();
            if (key.isNotEmpty) {
              headers[key] = value;
            }
          }
          i += 2;
          continue;
        }
      } else if (arg == '-d' ||
          arg == '--data' ||
          arg == '--data-raw' ||
          arg == '--data-binary') {
        if (i + 1 < args.length) {
          bodyParts.add(args[i + 1]);
          i += 2;
          continue;
        }
      } else if (arg == '-u' || arg == '--user') {
        if (i + 1 < args.length) {
          final userPart = args[i + 1];
          final colon = userPart.indexOf(':');
          if (colon > 0) {
            authUsername = userPart.substring(0, colon);
            authPassword = userPart.substring(colon + 1);
          } else {
            authUsername = userPart;
          }
          i += 2;
          continue;
        }
      } else if (arg == '-A' || arg == '--user-agent') {
        if (i + 1 < args.length) {
          headers['User-Agent'] = args[i + 1];
          i += 2;
          continue;
        }
      } else if (arg == '-b' || arg == '--cookie') {
        if (i + 1 < args.length) {
          headers['Cookie'] = args[i + 1];
          i += 2;
          continue;
        }
      } else if (arg.startsWith('-') && arg.length > 1) {
        if (arg.contains('=')) {
          final eq = arg.indexOf('=');
          final opt = arg.substring(0, eq);
          final val = arg.substring(eq + 1);
          _handleOpt(opt, val, headers, bodyParts, (m) => method = m,
              (u, p) { authUsername = u; authPassword = p; });
        }
        i++;
        continue;
      } else if (!arg.startsWith('-')) {
        url ??= arg;
      }

      i++;
    }

    final body = bodyParts.isNotEmpty ? _mergeBody(bodyParts) : null;

    if (body != null && method == 'GET') {
      method = 'POST';
    }
    if (body != null) {
      final ct = headers.keys.firstWhere(
        (k) => k.toLowerCase() == 'content-type',
        orElse: () => '',
      );
      if (ct.isEmpty) {
        if (body.startsWith('{') || body.startsWith('[')) {
          headers['Content-Type'] = 'application/json';
        }
      }
    }

    return CurlParseResult(
      method: method,
      url: url ?? '',
      headers: headers,
      body: body,
      authUsername: authUsername,
      authPassword: authPassword,
    );
  }

  static void _handleOpt(
    String opt,
    String val,
    Map<String, String> headers,
    List<String> bodyParts,
    void Function(String) setMethod,
    void Function(String? u, String? p) setAuth,
  ) {
    switch (opt) {
      case '-X':
      case '--request':
        setMethod(val.toUpperCase());
      case '-H':
      case '--header':
        final colon = val.indexOf(':');
        if (colon > 0) {
          final key = val.substring(0, colon).trim();
          var value = val.substring(colon + 1);
          if (value.startsWith(' ')) value = value.trim();
          if (key.isNotEmpty) headers[key] = value;
        }
      case '-d':
      case '--data':
      case '--data-raw':
      case '--data-binary':
        bodyParts.add(val);
      case '-u':
      case '--user':
        final colon = val.indexOf(':');
        if (colon > 0) {
          setAuth(val.substring(0, colon), val.substring(colon + 1));
        } else {
          setAuth(val, null);
        }
      case '-A':
      case '--user-agent':
        headers['User-Agent'] = val;
      case '-b':
      case '--cookie':
        headers['Cookie'] = val;
    }
  }

  static String _mergeBody(List<String> parts) {
    if (parts.length == 1) return parts.first;
    final first = parts.first;
    if (first.startsWith('{') || first.startsWith('[')) {
      return parts.join();
    }
    final sb = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) sb.write('&');
      sb.write(parts[i]);
    }
    return sb.toString();
  }

  static List<String> _tokenize(String input) {
    final tokens = <String>[];
    final buf = StringBuffer();
    var inSingle = false;
    var inDouble = false;
    var escape = false;

    void flush() {
      if (buf.isNotEmpty) {
        tokens.add(buf.toString());
        buf.clear();
      }
    }

    for (var i = 0; i < input.length; i++) {
      final c = input[i];

      if (escape) {
        buf.write(c);
        escape = false;
        continue;
      }

      if (c == '\\' && inDouble) {
        escape = true;
        continue;
      }

      if (c == "'" && !inDouble) {
        inSingle = !inSingle;
        continue;
      }

      if (c == '"' && !inSingle) {
        inDouble = !inDouble;
        continue;
      }

      if (c == ' ' && !inSingle && !inDouble) {
        flush();
        continue;
      }

      buf.write(c);
    }

    flush();
    return tokens;
  }
}
