import '../models/api_request.dart';
import '../models/collection.dart';
import '../models/environment.dart';

class PostmanService {
  static const _schema =
      'https://schema.getpostman.com/json/collection/v2.1.0/collection.json';

  Map<String, dynamic> exportCollection(
    Collection collection,
    List<ApiRequest> requests,
  ) {
    final items = collection.requestIds
        .map((id) => requests.where((r) => r.id == id).firstOrNull)
        .whereType<ApiRequest>()
        .map(_requestToItem)
        .toList();

    return {
      'info': {
        '_postman_id': collection.id,
        'name': collection.name,
        'description': collection.description ?? '',
        'schema': _schema,
      },
      'item': items,
    };
  }

  Map<String, dynamic> exportEnvironment(Environment env) {
    return {
      'id': env.id,
      'name': env.name,
      'values': env.variables.entries.map((e) {
        return {
          'key': e.key,
          'value': e.value,
          'type': 'default',
          'enabled': true,
        };
      }).toList(),
      '_postman_variable_scope': 'environment',
    };
  }

  ({Collection collection, List<ApiRequest> requests}) importCollection(
    Map<String, dynamic> json,
  ) {
    final info = json['info'] as Map<String, dynamic>? ?? {};
    final name = info['name'] as String? ?? 'Imported';
    final description = info['description'] as String?;

    final collection = Collection(
      id: info['_postman_id'] as String?,
      name: name,
      description: description,
    );

    final items = json['item'] as List<dynamic>? ?? [];
    final requests = <ApiRequest>[];
    final requestIds = <String>[];

    void collect(Map<String, dynamic> item) {
      if (item.containsKey('item')) {
        final subItems = item['item'] as List<dynamic>? ?? [];
        for (final sub in subItems) {
          if (sub is Map<String, dynamic>) collect(sub);
        }
        return;
      }
      final result = _parseItem(item, collection.id);
      if (result != null) {
        requests.add(result);
        requestIds.add(result.id);
      }
    }

    for (final item in items) {
      if (item is Map<String, dynamic>) collect(item);
    }

    final finalCollection = collection.copyWith(requestIds: requestIds);
    return (collection: finalCollection, requests: requests);
  }

  Environment importEnvironment(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Imported';
    final values = json['values'] as List<dynamic>? ?? [];
    final variables = <String, String>{};
    for (final v in values) {
      if (v is Map<String, dynamic>) {
        final key = v['key'] as String? ?? '';
        final value = v['value']?.toString() ?? '';
        if (key.isNotEmpty) {
          variables[key] = value;
        }
      }
    }
    return Environment(
      id: json['id'] as String?,
      name: name,
      variables: variables,
    );
  }

  // --- Internal ---

  Map<String, dynamic> _requestToItem(ApiRequest req) {
    final headerList = <Map<String, dynamic>>[];
    if (req.headers != null) {
      for (final e in req.headers!.entries) {
        headerList.add({
          'key': e.key,
          'value': e.value.toString(),
          'type': 'text',
        });
      }
    }

    Map<String, dynamic>? body;
    if (req.bodyType != null && req.bodyType != 'none') {
      body = _buildBody(req);
    }

    Map<String, dynamic>? auth;
    if (req.authType != null && req.authType != 'none') {
      auth = _buildAuth(req);
    }

    final urlParts = _parseUrl(req.url);
    final queryList = <Map<String, dynamic>>[];
    if (req.queryParams != null) {
      for (final e in req.queryParams!.entries) {
        queryList.add({
          'key': e.key,
          'value': e.value.toString(),
        });
      }
    }

    return {
      'name': req.name,
      'request': {
        'method': req.method,
        'header': headerList,
        'url': {
          'raw': req.url,
          ...?urlParts,
          if (queryList.isNotEmpty) 'query': queryList,
        },
        // ignore: use_null_aware_elements
        if (body != null) 'body': body,
        // ignore: use_null_aware_elements
        if (auth != null) 'auth': auth,
      },
      'response': [],
    };
  }

  Map<String, dynamic>? _buildBody(ApiRequest req) {
    final mode = switch (req.bodyType) {
      'json' => 'raw',
      'raw' => 'raw',
      'form-data' => 'formdata',
      'x-www-form-urlencoded' => 'urlencoded',
      _ => null,
    };
    if (mode == null) return null;

    return {
      'mode': mode,
      if (mode == 'raw')
        'raw': req.body?.toString() ?? ''
      else if (mode == 'formdata')
        'formdata': _buildFormData(req.body, false)
      else if (mode == 'urlencoded')
        'urlencoded': _buildFormData(req.body, true),
    };
  }

  List<Map<String, dynamic>> _buildFormData(dynamic body, bool isUrlEncoded) {
    if (body is Map) {
      return body.entries.map((e) {
        return {
          'key': e.key.toString(),
          'value': e.value.toString(),
          'type': 'text',
        };
      }).toList();
    }
    return [];
  }

  Map<String, dynamic>? _buildAuth(ApiRequest req) {
    if (req.authData == null) return null;
    return switch (req.authType) {
      'basic' => {
          'type': 'basic',
          'basic': [
            {'key': 'username', 'value': req.authData!['username'] ?? '', 'type': 'string'},
            {'key': 'password', 'value': req.authData!['password'] ?? '', 'type': 'string'},
          ],
        },
      'bearer' => {
          'type': 'bearer',
          'bearer': [
            {'key': 'token', 'value': req.authData!['token'] ?? '', 'type': 'string'},
          ],
        },
      'apikey' => {
          'type': 'apikey',
          'apikey': [
            {'key': 'key', 'value': req.authData!['key'] ?? '', 'type': 'string'},
            {
              'key': 'value',
              'value': req.authData!['value'] ?? '',
              'type': 'string',
            },
            {
              'key': 'in',
              'value': req.authData!['addTo'] ?? 'header',
              'type': 'string',
            },
          ],
        },
      _ => null,
    };
  }

  ApiRequest? _parseItem(Map<String, dynamic> item, String? collectionId) {
    final name = item['name'] as String? ?? 'Untitled';
    final request = item['request'] as Map<String, dynamic>?;
    if (request == null) return null;

    final method = request['method'] as String? ?? 'GET';
    final url = _extractUrl(request['url']);
    final headers = _parseHeaders(request['header'] as List<dynamic>?);
    final queryParams = _parseQueryParams(request['url']);
    final (body, bodyType) = _parseBody(request['body'] as Map<String, dynamic>?);
    final (authType, authData) = _parseAuth(request['auth'] as Map<String, dynamic>?);

    return ApiRequest(
      name: name,
      url: url,
      method: method,
      headers: headers,
      queryParams: queryParams,
      body: body,
      bodyType: bodyType,
      authType: authType,
      authData: authData,
      collectionId: collectionId,
    );
  }

  String _extractUrl(dynamic urlField) {
    if (urlField is String) return urlField;
    if (urlField is Map<String, dynamic>) {
      return urlField['raw'] as String? ?? '';
    }
    return '';
  }

  Map<String, dynamic>? _parseHeaders(List<dynamic>? headerList) {
    if (headerList == null || headerList.isEmpty) return null;
    final m = <String, dynamic>{};
    for (final h in headerList) {
      if (h is Map<String, dynamic>) {
        final key = h['key'] as String?;
        final value = h['value']?.toString();
        if (key != null && value != null && key.isNotEmpty) {
          m[key] = value;
        }
      }
    }
    return m.isEmpty ? null : m;
  }

  Map<String, dynamic>? _parseQueryParams(dynamic urlField) {
    if (urlField is! Map<String, dynamic>) return null;
    final query = urlField['query'] as List<dynamic>?;
    if (query == null || query.isEmpty) return null;
    final m = <String, dynamic>{};
    for (final q in query) {
      if (q is Map<String, dynamic>) {
        final key = q['key'] as String?;
        final value = q['value']?.toString();
        if (key != null && value != null && key.isNotEmpty) {
          m[key] = value;
        }
      }
    }
    return m.isEmpty ? null : m;
  }

  (dynamic body, String? bodyType) _parseBody(Map<String, dynamic>? bodyField) {
    if (bodyField == null) return (null, null);
    final mode = bodyField['mode'] as String?;

    return switch (mode) {
      'raw' => (bodyField['raw']?.toString(), 'json'),
      'formdata' => (_parseFormBody(
          bodyField['formdata'] as List<dynamic>?,
        ), 'form-data'),
      'urlencoded' => (_parseFormBody(
          bodyField['urlencoded'] as List<dynamic>?,
        ), 'x-www-form-urlencoded'),
      'file' => (null, 'none'),
      _ => (null, null),
    };
  }

  Map<String, dynamic>? _parseFormBody(List<dynamic>? list) {
    if (list == null || list.isEmpty) return null;
    final m = <String, dynamic>{};
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final key = item['key'] as String?;
        final value = item['value']?.toString();
        if (key != null && value != null && key.isNotEmpty) {
          m[key] = value;
        }
      }
    }
    return m.isEmpty ? null : m;
  }

  (String? authType, Map<String, dynamic>? authData) _parseAuth(
    Map<String, dynamic>? authField,
  ) {
    if (authField == null) return (null, null);
    final type = authField['type'] as String?;
    final params = authField[type] as List<dynamic>? ?? [];
    final map = <String, dynamic>{};
    for (final p in params) {
      if (p is Map<String, dynamic>) {
        map[p['key'] as String? ?? ''] = p['value']?.toString() ?? '';
      }
    }
    return (type, map);
  }

  Map<String, dynamic>? _parseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (!uri.isAbsolute) return null;
      final host = uri.host.split('.');
      final path = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      return {
        'protocol': uri.scheme,
        'host': host,
        if (path.isNotEmpty) 'path': path,
      };
    } catch (_) {
      return null;
    }
  }
}
