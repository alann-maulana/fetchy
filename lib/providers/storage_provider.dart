import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/api_request.dart';
import '../models/collection.dart';
import '../models/environment.dart';

final requestsBoxProvider = Provider<Box<ApiRequest>>((ref) {
  return Hive.box<ApiRequest>('requests');
});

final collectionsBoxProvider = Provider<Box<Collection>>((ref) {
  return Hive.box<Collection>('collections');
});

final environmentsBoxProvider = Provider<Box<Environment>>((ref) {
  return Hive.box<Environment>('environments');
});

// --- Saved Requests ---

final savedRequestsProvider =
    NotifierProvider<SavedRequestsNotifier, List<ApiRequest>>(
  SavedRequestsNotifier.new,
);

class SavedRequestsNotifier extends Notifier<List<ApiRequest>> {
  @override
  List<ApiRequest> build() {
    final box = ref.watch(requestsBoxProvider);
    final sub = box.watch().listen((_) {
      state = _getList(box);
    });
    ref.onDispose(() => sub.cancel());
    return _getList(box);
  }

  List<ApiRequest> _getList(Box<ApiRequest> box) {
    final list = box.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  void save(ApiRequest request) {
    ref.read(requestsBoxProvider).put(request.id, request);
  }

  void delete(String id) {
    ref.read(requestsBoxProvider).delete(id);
    final collectionsBox = ref.read(collectionsBoxProvider);
    for (final c in collectionsBox.values) {
      if (c.requestIds.contains(id)) {
        collectionsBox.put(
          c.id,
          c.copyWith(
            requestIds: c.requestIds.where((rId) => rId != id).toList(),
          ),
        );
      }
    }
  }

  void rename(String id, String name) {
    final box = ref.read(requestsBoxProvider);
    final existing = box.get(id);
    if (existing != null) {
      box.put(id, existing.copyWith(name: name));
    }
  }
}

// --- Collections ---

final collectionsProvider =
    NotifierProvider<CollectionsNotifier, List<Collection>>(
  CollectionsNotifier.new,
);

class CollectionsNotifier extends Notifier<List<Collection>> {
  @override
  List<Collection> build() {
    final box = ref.watch(collectionsBoxProvider);
    final sub = box.watch().listen((_) {
      state = _getList(box);
    });
    ref.onDispose(() => sub.cancel());
    return _getList(box);
  }

  List<Collection> _getList(Box<Collection> box) {
    final list = box.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Collection create(String name, {String? description}) {
    final box = ref.read(collectionsBoxProvider);
    final collection = Collection(name: name, description: description);
    box.put(collection.id, collection);
    return collection;
  }

  void update(String id, {String? name, String? description}) {
    final box = ref.read(collectionsBoxProvider);
    final existing = box.get(id);
    if (existing != null) {
      box.put(id, existing.copyWith(name: name, description: description));
    }
  }

  void delete(String id) {
    final box = ref.read(collectionsBoxProvider);
    box.delete(id);
  }

  void addRequest(String collectionId, String requestId) {
    final box = ref.read(collectionsBoxProvider);
    final collection = box.get(collectionId);
    if (collection != null && !collection.requestIds.contains(requestId)) {
      box.put(
        collectionId,
        collection.copyWith(
          requestIds: [...collection.requestIds, requestId],
        ),
      );
    }
  }

  void removeRequest(String collectionId, String requestId) {
    final box = ref.read(collectionsBoxProvider);
    final collection = box.get(collectionId);
    if (collection != null) {
      box.put(
        collectionId,
        collection.copyWith(
          requestIds:
              collection.requestIds.where((id) => id != requestId).toList(),
        ),
      );
    }
  }
}

// --- Environments ---

final environmentsProvider =
    NotifierProvider<EnvironmentsNotifier, List<Environment>>(
  EnvironmentsNotifier.new,
);

class EnvironmentsNotifier extends Notifier<List<Environment>> {
  @override
  List<Environment> build() {
    final box = ref.watch(environmentsBoxProvider);
    final sub = box.watch().listen((_) {
      state = _getList(box);
    });
    ref.onDispose(() => sub.cancel());
    return _getList(box);
  }

  List<Environment> _getList(Box<Environment> box) {
    final list = box.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Environment create(String name) {
    final box = ref.read(environmentsBoxProvider);
    final env = Environment(name: name);
    box.put(env.id, env);
    return env;
  }

  void update(String id, {String? name, Map<String, String>? variables}) {
    final box = ref.read(environmentsBoxProvider);
    final existing = box.get(id);
    if (existing != null) {
      box.put(id, existing.copyWith(name: name, variables: variables));
    }
  }

  void delete(String id) {
    final box = ref.read(environmentsBoxProvider);
    final env = box.get(id);
    if (env != null && env.isActive) {
      box.put(id, env.copyWith(isActive: false));
    }
    box.delete(id);
  }

  void activate(String id) {
    final box = ref.read(environmentsBoxProvider);
    for (final env in box.values) {
      if (env.isActive) {
        box.put(env.id, env.copyWith(isActive: false));
      }
    }
    if (id.isNotEmpty) {
      final env = box.get(id);
      if (env != null) {
        box.put(id, env.copyWith(isActive: true));
      }
    }
  }

  Environment? get active {
    for (final env in state) {
      if (env.isActive) return env;
    }
    return null;
  }
}
