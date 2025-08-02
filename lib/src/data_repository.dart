// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:core/core.dart';
import 'package:data_client/data_client.dart';

/// {@template data_repository}
/// A generic repository that acts as an abstraction layer over an [DataClient].
///
/// It mirrors the data access methods provided by the [DataClient] interface
/// (CRUD operations, querying) for a specific data type [T].
///
/// This repository requires an instance of [DataClient<T>] to be injected
/// via its constructor. It delegates all data operations to the underlying client.
///
/// Error Handling:
/// The repository catches exceptions thrown by the injected [DataClient]
/// (typically subtypes of [HttpException] from the network layer, or
/// potentially [FormatException] during deserialization) and re-throws them.
/// This allows higher layers (like BLoCs or API route handlers) to implement
/// specific error handling logic based on the exception type.
///
/// It also provides a stream, [entityUpdated], that emits an event whenever
/// a CUD (Create, Update, Delete) operation is successfully completed,
/// allowing other parts of the application to react to data changes.
/// {@endtemplate}
class DataRepository<T> {
  /// {@macro data_repository}
  DataRepository({required DataClient<T> dataClient})
    : _dataClient = dataClient;

  final DataClient<T> _dataClient;

  final _entityUpdatedController = StreamController<Type>.broadcast();

  /// A stream that emits the [Type] of a data entity when it is created,
  /// updated, or deleted.
  ///
  /// This is useful for allowing different parts of the application to listen
  /// for changes to specific data types and trigger UI refreshes or other
  /// side effects accordingly.
  ///
  /// Example:
  /// ```dart
  /// repository.entityUpdated.where((type) => type == Headline).listen((_) {
  ///   print('A headline was changed! Refreshing headline list.');
  /// });
  /// ```
  Stream<Type> get entityUpdated => _entityUpdatedController.stream;

  /// Closes the underlying stream controller.
  ///
  /// This should be called when the repository is no longer needed to prevent
  /// memory leaks.
  void dispose() {
    _entityUpdatedController.close();
  }

  /// Creates a new resource item of type [T] by delegating to the client.
  ///
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// created item of type [T].
  ///
  /// Re-throws any [HttpException] or [FormatException] from the client.
  Future<T> create({required T item, String? userId}) async {
    try {
      final response = await _dataClient.create(item: item, userId: userId);
      _entityUpdatedController.add(T);
      return response.data;
    } on HttpException {
      rethrow; // Propagate client-level HTTP exceptions
    } on FormatException {
      rethrow; // Propagate serialization/deserialization errors
    }
    // Catch-all for unexpected errors, though specific catches are preferred.
    // Consider logging here if necessary.
  }

  /// Reads a single resource item of type [T] by its unique [id] via the client.
  ///
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// deserialized item of type [T].
  ///
  /// Re-throws any [HttpException] (like [NotFoundException]) or
  /// [FormatException] from the client.
  Future<T> read({required String id, String? userId}) async {
    try {
      final response = await _dataClient.read(id: id, userId: userId);
      return response.data;
    } on HttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Reads multiple resource items of type [T] via the client, with support
  /// for rich filtering, sorting, and pagination.
  ///
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// [PaginatedResponse] containing the list of deserialized items and
  /// pagination details.
  ///
  /// Re-throws any [HttpException] or [FormatException] from the client.
  Future<PaginatedResponse<T>> readAll({
    String? userId,
    Map<String, dynamic>? filter,
    PaginationOptions? pagination,
    List<SortOption>? sort,
  }) async {
    try {
      final response = await _dataClient.readAll(
        userId: userId,
        filter: filter,
        pagination: pagination,
        sort: sort,
      );
      return response.data;
    } on HttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Updates an existing resource item of type [T] identified by [id] via the client.
  ///
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// updated item of type [T].
  ///
  /// Re-throws any [HttpException] (like [NotFoundException]) or
  /// [FormatException] from the client.
  Future<T> update({
    required String id,
    required T item,
    String? userId,
  }) async {
    try {
      final response = await _dataClient.update(
        id: id,
        item: item,
        userId: userId,
      );
      _entityUpdatedController.add(T);
      return response.data;
    } on HttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Deletes a resource item identified by [id] via the client.
  ///
  /// Returns `void` upon successful deletion.
  ///
  /// Re-throws any [HttpException] (like [NotFoundException]) from the client.
  Future<void> delete({required String id, String? userId}) async {
    try {
      await _dataClient.delete(id: id, userId: userId);
      _entityUpdatedController.add(T);
    } on HttpException {
      rethrow;
    }
  }

  /// Counts the number of resource items matching the given criteria by
  /// delegating to the client.
  ///
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// total count as an integer.
  ///
  /// Re-throws any [HttpException] or [FormatException] from the client.
  Future<int> count({String? userId, Map<String, dynamic>? filter}) async {
    try {
      final response = await _dataClient.count(userId: userId, filter: filter);
      return response.data;
    } on HttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Executes a complex aggregation pipeline on the data source by delegating
  /// to the client.
  ///
  /// Unwraps the [SuccessApiResponse] from the client and returns the
  /// resulting list of documents.
  ///
  /// Re-throws any [HttpException] or [FormatException] from the client.
  Future<List<Map<String, dynamic>>> aggregate({
    required List<Map<String, dynamic>> pipeline,
    String? userId,
  }) async {
    try {
      final response = await _dataClient.aggregate(
        pipeline: pipeline,
        userId: userId,
      );
      return response.data;
    } on HttpException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }
}
