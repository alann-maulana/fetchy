import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_request.dart';
import '../models/api_response.dart';
import '../services/http_client.dart';
import '../services/request_service.dart';

class KVEntry {
  final String key;
  final String value;
  final bool enabled;

  const KVEntry({this.key = '', this.value = '', this.enabled = true});

  KVEntry copyWith({String? key, String? value, bool? enabled}) {
    return KVEntry(
      key: key ?? this.key,
      value: value ?? this.value,
      enabled: enabled ?? this.enabled,
    );
  }
}

class RequestEditorState {
  final String method;
  final String url;
  final List<KVEntry> queryParams;
  final List<KVEntry> headers;
  final String bodyType;
  final String bodyContent;
  final String authType;
  final String authUsername;
  final String authPassword;
  final String authToken;
  final String authKey;
  final String authValue;
  final String authAddTo;
  final ApiResponse? response;
  final bool isLoading;
  final String? error;
  final int selectedTab;
  final String? currentRequestId;

  const RequestEditorState({
    this.method = 'GET',
    this.url = '',
    this.queryParams = const [],
    this.headers = const [],
    this.bodyType = 'none',
    this.bodyContent = '',
    this.authType = 'none',
    this.authUsername = '',
    this.authPassword = '',
    this.authToken = '',
    this.authKey = '',
    this.authValue = '',
    this.authAddTo = 'header',
    this.response,
    this.isLoading = false,
    this.error,
    this.selectedTab = 0,
    this.currentRequestId,
  });

  Map<String, dynamic> get headersMap {
    final m = <String, dynamic>{};
    for (final e in headers) {
      if (e.enabled && e.key.isNotEmpty) m[e.key] = e.value;
    }
    return m;
  }

  Map<String, dynamic> get queryParamsMap {
    final m = <String, dynamic>{};
    for (final e in queryParams) {
      if (e.enabled && e.key.isNotEmpty) m[e.key] = e.value;
    }
    return m;
  }

  RequestEditorState copyWith({
    String? method,
    String? url,
    List<KVEntry>? queryParams,
    List<KVEntry>? headers,
    String? bodyType,
    String? bodyContent,
    String? authType,
    String? authUsername,
    String? authPassword,
    String? authToken,
    String? authKey,
    String? authValue,
    String? authAddTo,
    ApiResponse? response,
    bool? isLoading,
    String? error,
    int? selectedTab,
    String? currentRequestId,
    bool clearResponse = false,
    bool clearError = false,
  }) {
    return RequestEditorState(
      method: method ?? this.method,
      url: url ?? this.url,
      queryParams: queryParams ?? this.queryParams,
      headers: headers ?? this.headers,
      bodyType: bodyType ?? this.bodyType,
      bodyContent: bodyContent ?? this.bodyContent,
      authType: authType ?? this.authType,
      authUsername: authUsername ?? this.authUsername,
      authPassword: authPassword ?? this.authPassword,
      authToken: authToken ?? this.authToken,
      authKey: authKey ?? this.authKey,
      authValue: authValue ?? this.authValue,
      authAddTo: authAddTo ?? this.authAddTo,
      response: clearResponse ? null : (response ?? this.response),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedTab: selectedTab ?? this.selectedTab,
      currentRequestId: currentRequestId ?? this.currentRequestId,
    );
  }
}

final httpClientProvider = Provider<HttpClientService>((ref) => HttpClientService());
final requestServiceProvider = Provider<RequestService>(
  (ref) => RequestService(ref.read(httpClientProvider)),
);

class RequestEditorNotifier extends StateNotifier<RequestEditorState> {
  final RequestService _requestService;

  RequestEditorNotifier(this._requestService) : super(const RequestEditorState());

  void setMethod(String m) => state = state.copyWith(method: m, clearResponse: true);
  void setUrl(String u) {
    final uri = Uri.tryParse(u);
    if (uri != null && uri.queryParameters.isNotEmpty) {
      final urlParams = uri.queryParameters;
      final cleanUrl = u.split('?')[0];
      final merged = <KVEntry>[];
      final urlKeys = <String>{};
      for (final e in urlParams.entries) {
        urlKeys.add(e.key);
        merged.add(KVEntry(key: e.key, value: e.value));
      }
      for (final e in state.queryParams) {
        if (!urlKeys.contains(e.key)) {
          merged.add(e);
        }
      }
      state = state.copyWith(url: cleanUrl, queryParams: merged, clearResponse: true);
    } else {
      state = state.copyWith(url: u, clearResponse: true);
    }
  }
  void setTab(int t) => state = state.copyWith(selectedTab: t);
  void setQueryParams(List<KVEntry> p) => state = state.copyWith(queryParams: p, clearResponse: true);
  void setHeaders(List<KVEntry> h) => state = state.copyWith(headers: h, clearResponse: true);
  void setBodyType(String t) => state = state.copyWith(bodyType: t, clearResponse: true);
  void setBodyContent(String c) => state = state.copyWith(bodyContent: c, clearResponse: true);
  void setAuthType(String t) => state = state.copyWith(authType: t, clearResponse: true);
  void setAuthUsername(String v) => state = state.copyWith(authUsername: v, clearResponse: true);
  void setAuthPassword(String v) => state = state.copyWith(authPassword: v, clearResponse: true);
  void setAuthToken(String v) => state = state.copyWith(authToken: v, clearResponse: true);
  void setAuthKey(String v) => state = state.copyWith(authKey: v, clearResponse: true);
  void setAuthValue(String v) => state = state.copyWith(authValue: v, clearResponse: true);
  void setAuthAddTo(String v) => state = state.copyWith(authAddTo: v, clearResponse: true);

  Map<String, dynamic> _getAuthData() {
    return switch (state.authType) {
      'basic' => {'username': state.authUsername, 'password': state.authPassword},
      'bearer' => {'token': state.authToken},
      'apikey' => {'key': state.authKey, 'value': state.authValue, 'addTo': state.authAddTo},
      _ => {},
    };
  }

  dynamic _getBody() {
    return switch (state.bodyType) {
      'none' => null,
      'raw' || 'json' => state.bodyContent,
      _ => null,
    };
  }

  void loadRequest(ApiRequest request) {
    List<KVEntry> mapToKvs(Map<String, dynamic>? map) {
      if (map == null) return [];
      return map.entries
          .map((e) => KVEntry(key: e.key, value: e.value.toString()))
          .toList();
    }

    String authField(String key) {
      return request.authData?[key]?.toString() ?? '';
    }

    state = RequestEditorState(
      method: request.method,
      url: request.url,
      queryParams: mapToKvs(request.queryParams),
      headers: mapToKvs(request.headers),
      bodyType: request.bodyType ?? 'none',
      bodyContent: request.body?.toString() ?? '',
      authType: request.authType ?? 'none',
      authUsername: authField('username'),
      authPassword: authField('password'),
      authToken: authField('token'),
      authKey: authField('key'),
      authValue: authField('value'),
      authAddTo: authField('addTo'),
      currentRequestId: request.id,
    );
  }

  ApiRequest buildRequest({String? name, String? collectionId}) {
    return ApiRequest(
      id: state.currentRequestId,
      name: name ?? 'Untitled',
      url: state.url,
      method: state.method,
      headers: state.headersMap.isNotEmpty ? state.headersMap : null,
      queryParams: state.queryParamsMap.isNotEmpty ? state.queryParamsMap : null,
      body: _getBody(),
      bodyType: state.bodyType != 'none' ? state.bodyType : null,
      authType: state.authType != 'none' ? state.authType : null,
      authData: _getAuthData().isNotEmpty ? _getAuthData() : null,
      collectionId: collectionId,
    );
  }

  void reset() {
    state = const RequestEditorState();
  }

  void saveToCollection(String collectionId, String name) {
    final request = buildRequest(name: name, collectionId: collectionId);
    state = state.copyWith(currentRequestId: request.id);
    // Storage save is handled by the screen via provider
  }

  Future<void> sendRequest() async {
    if (state.url.isEmpty) return;
    state = state.copyWith(isLoading: true, clearError: true, clearResponse: true);
    try {
      final response = await _requestService.executeRequest(
        method: state.method,
        url: state.url,
        headers: state.headersMap,
        queryParameters: state.queryParamsMap,
        body: _getBody(),
        bodyType: state.bodyType,
        authType: state.authType,
        authData: _getAuthData(),
      );
      state = state.copyWith(response: response, isLoading: false);
    } catch (e) {
      if (e is DioException) {
        final r = e.response;
        if (r != null) {
          final ct = r.headers.value('content-type');
          final body = (r.data is Map || r.data is List)
              ? const JsonEncoder.withIndent('  ').convert(r.data)
              : r.data?.toString() ?? '';
          state = state.copyWith(
            response: ApiResponse(
              statusCode: r.statusCode ?? 0,
              statusMessage: r.statusMessage ?? 'Error',
              headers: r.headers.map.map((k, v) => MapEntry(k, v.join(', '))),
              body: body,
              contentType: ct,
              responseTime: 0,
            ),
            error: '${r.statusCode}: ${r.statusMessage ?? 'Request failed'}',
            isLoading: false,
          );
        } else {
          state = state.copyWith(error: e.message ?? 'Network error', isLoading: false);
        }
      } else {
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    }
  }
}

final requestEditorProvider =
    StateNotifierProvider<RequestEditorNotifier, RequestEditorState>(
  (ref) => RequestEditorNotifier(ref.read(requestServiceProvider)),
);
