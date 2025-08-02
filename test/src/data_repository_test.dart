// ignore_for_file: lines_longer_than_80_chars, avoid_equals_and_hash_code_on_mutable_classes

import 'package:core/core.dart';
import 'package:data_client/data_client.dart';
import 'package:data_repository/data_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Define a simple dummy data class for testing the generic repository
class _MockData {
  const _MockData({required this.id, this.value = 'default'});
  final String id;
  final String value;

  // Add equals and hashCode for comparison in tests
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MockData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value;

  @override
  int get hashCode => id.hashCode ^ value.hashCode;

  @override
  String toString() => '_MockData(id: $id, value: $value)';
}

// Mock the DataClient using mocktail
class MockDataClient extends Mock implements DataClient<_MockData> {}

void main() {
  group('DataRepository', () {
    late DataClient<_MockData> mockDataClient;
    late DataRepository<_MockData> repository;

    // Dummy data instances for testing
    const mockId = 'test-id-123';
    const mockItem = _MockData(id: mockId, value: 'Test Item');
    final mockMetadata = ResponseMetadata(
      requestId: 'test-req-id',
      timestamp: DateTime.now(),
    );
    final mockSuccessResponseItem = SuccessApiResponse(
      data: mockItem,
      metadata: mockMetadata,
    );
    const updatedMockItem = _MockData(id: mockId, value: 'Updated Item');
    final mockSuccessResponseUpdatedItem = SuccessApiResponse(
      data: updatedMockItem,
      metadata: mockMetadata,
    );
    final mockItemsList = [
      const _MockData(id: 'id1', value: 'Item 1'),
      const _MockData(id: 'id2', value: 'Item 2'),
    ];
    // Helper for paginated responses
    final mockPaginatedResponse = PaginatedResponse(
      items: mockItemsList,
      cursor: null, // Assuming no cursor for these basic tests
      hasMore: false, // Assuming no more items for these basic tests
    );
    final mockSuccessResponseList = SuccessApiResponse(
      data: mockPaginatedResponse,
      metadata: mockMetadata,
    );
    final mockSuccessResponseCount = SuccessApiResponse(
      data: 10,
      metadata: mockMetadata,
    );
    final mockAggregatePipeline = [
      <String, dynamic>{
        r'$group': {'_id': r'$category', 'count': 1},
      },
    ];
    final mockAggregateResult = <Map<String, dynamic>>[
      {'_id': 'A', 'count': 5},
    ];
    final mockSuccessResponseAggregate = SuccessApiResponse(
      data: mockAggregateResult,
      metadata: mockMetadata,
    );

    final mockQuery = {'category': 'test'};
    const mockHttpException = NotFoundException('Item not found');
    const mockFormatException = FormatException('Invalid data format');
    const mockSortBy = 'name';
    // const mockSortOrder = SortOrder.asc;

    setUp(() {
      // Register fallback values for any() matchers if needed
      registerFallbackValue(const _MockData(id: 'fallback'));
      // Rely on type inference for the map fallback value
      registerFallbackValue(<String, dynamic>{});
      registerFallbackValue(SortOrder.asc);
      registerFallbackValue(const PaginationOptions());
      registerFallbackValue(<SortOption>[]);
      registerFallbackValue(<Map<String, dynamic>>[]);

      mockDataClient = MockDataClient();
      repository = DataRepository<_MockData>(dataClient: mockDataClient);
    });

    tearDown(() {
      repository.dispose();
    });

    // --- Test Cases ---

    group('create', () {
      test('should call client.create and return the SuccessApiResponse '
          'containing the created item', () async {
        // Arrange
        when(
          () => mockDataClient.create(
            item: any(named: 'item'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseItem);

        // Act
        final result = await repository.create(item: mockItem);

        // Assert
        // Repository now returns the unwrapped item
        expect(result, equals(mockItem));
        verify(
          () => mockDataClient.create(item: mockItem, userId: null),
        ).called(1);
      });

      test('should rethrow HttpException when client.create throws', () async {
        // Arrange
        when(
          () => mockDataClient.create(
            item: any(named: 'item'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(mockHttpException);

        // Act & Assert
        expect(
          () => repository.create(item: mockItem),
          throwsA(isA<HttpException>()),
        );
        verify(
          () => mockDataClient.create(item: mockItem, userId: null),
        ).called(1);
      });

      test(
        'should rethrow FormatException when client.create throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.create(
              item: any(named: 'item'),
              userId: any(named: 'userId'),
            ),
          ).thenThrow(mockFormatException);

          // Act & Assert
          expect(
            () => repository.create(item: mockItem),
            throwsA(isA<FormatException>()),
          );
          verify(
            () => mockDataClient.create(item: mockItem, userId: null),
          ).called(1);
        },
      );
    });

    group('read', () {
      test('should call client.read and return the SuccessApiResponse '
          'containing the item', () async {
        // Arrange
        when(
          () => mockDataClient.read(
            id: any(named: 'id'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseItem);

        // Act
        final result = await repository.read(id: mockId);

        // Assert
        // Repository now returns the unwrapped item
        expect(result, equals(mockItem));
        verify(() => mockDataClient.read(id: mockId, userId: null)).called(1);
      });

      test('should rethrow HttpException when client.read throws', () async {
        // Arrange
        when(
          () => mockDataClient.read(
            id: any(named: 'id'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(mockHttpException);

        // Act & Assert
        expect(
          () => repository.read(id: mockId),
          throwsA(isA<HttpException>()),
        );
        verify(() => mockDataClient.read(id: mockId, userId: null)).called(1);
      });

      test('should rethrow FormatException when client.read throws', () async {
        // Arrange
        when(
          () => mockDataClient.read(
            id: any(named: 'id'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(mockFormatException);

        // Act & Assert
        expect(
          () => repository.read(id: mockId),
          throwsA(isA<FormatException>()),
        );
        verify(() => mockDataClient.read(id: mockId, userId: null)).called(1);
      });
    });

    group('readAll', () {
      test(
        'should call client.readAll with all args and return PaginatedResponse',
        () async {
          // Arrange
          when(
            () => mockDataClient.readAll(
              userId: any(named: 'userId'),
              filter: any(named: 'filter'),
              pagination: any(named: 'pagination'),
              sort: any(named: 'sort'),
            ),
          ).thenAnswer((_) async => mockSuccessResponseList);

          // Act
          const paginationOptions = PaginationOptions(
            cursor: 'lastId',
            limit: 10,
          );
          final sortOptions = [const SortOption(mockSortBy)];
          final result = await repository.readAll(
            pagination: paginationOptions,
            sort: sortOptions,
          );

          // Assert
          expect(result, equals(mockPaginatedResponse));
          expect(result.items, equals(mockItemsList));
          verify(
            () => mockDataClient.readAll(
              userId: null,
              filter: null,
              pagination: paginationOptions,
              sort: sortOptions,
            ),
          ).called(1);
        },
      );

      test('should call client.readAll without optional args', () async {
        // Arrange
        when(
          () => mockDataClient.readAll(
            userId: any(named: 'userId'),
            filter: any(named: 'filter'),
            pagination: any(named: 'pagination'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseList);

        // Act
        final result = await repository.readAll();

        // Assert
        expect(result, equals(mockPaginatedResponse));
        expect(result.items, equals(mockItemsList));
        verify(
          () => mockDataClient.readAll(
            userId: null,
            filter: null,
            pagination: null,
            sort: null,
          ),
        ).called(1);
      });

      test('should rethrow HttpException when client.readAll throws', () async {
        // Arrange
        when(
          () => mockDataClient.readAll(
            userId: any(named: 'userId'),
            filter: any(named: 'filter'),
            pagination: any(named: 'pagination'),
            sort: any(named: 'sort'),
          ),
        ).thenThrow(mockHttpException);

        // Act & Assert
        expect(() => repository.readAll(), throwsA(isA<HttpException>()));
        verify(
          () => mockDataClient.readAll(
            userId: null,
            filter: null,
            pagination: null,
            sort: null,
          ),
        ).called(1);
      });

      test(
        'should rethrow FormatException when client.readAll throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.readAll(
              userId: any(named: 'userId'),
              filter: any(named: 'filter'),
              pagination: any(named: 'pagination'),
              sort: any(named: 'sort'),
            ),
          ).thenThrow(mockFormatException);

          // Act & Assert
          expect(() => repository.readAll(), throwsA(isA<FormatException>()));
          verify(
            () => mockDataClient.readAll(
              userId: null,
              filter: null,
              pagination: null,
              sort: null,
            ),
          ).called(1);
        },
      );
    });

    group('update', () {
      test('should call client.update and return the SuccessApiResponse '
          'containing the updated item', () async {
        // Arrange
        when(
          () => mockDataClient.update(
            id: any(named: 'id'),
            item: any(named: 'item'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseUpdatedItem);

        // Act
        final result = await repository.update(id: mockId, item: mockItem);

        // Assert
        // Repository now returns the unwrapped item
        expect(result, equals(updatedMockItem));
        verify(
          () => mockDataClient.update(id: mockId, item: mockItem, userId: null),
        ).called(1);
      });

      test('should rethrow HttpException when client.update throws', () async {
        // Arrange
        when(
          () => mockDataClient.update(
            id: any(named: 'id'),
            item: any(named: 'item'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(mockHttpException);

        // Act & Assert
        expect(
          () => repository.update(id: mockId, item: mockItem),
          throwsA(isA<HttpException>()),
        );
        verify(
          () => mockDataClient.update(id: mockId, item: mockItem, userId: null),
        ).called(1);
      });

      test(
        'should rethrow FormatException when client.update throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.update(
              id: any(named: 'id'),
              item: any(named: 'item'),
              userId: any(named: 'userId'),
            ),
          ).thenThrow(mockFormatException);

          // Act & Assert
          expect(
            () => repository.update(id: mockId, item: mockItem),
            throwsA(isA<FormatException>()),
          );
          verify(
            () =>
                mockDataClient.update(id: mockId, item: mockItem, userId: null),
          ).called(1);
        },
      );
    });

    group('delete', () {
      test('should call client.delete', () async {
        // Arrange
        when(
          () => mockDataClient.delete(
            id: any(named: 'id'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async {}); // Completes normally

        // Act
        await repository.delete(id: mockId);

        // Assert
        verify(() => mockDataClient.delete(id: mockId)).called(1);
      });

      test('should rethrow HttpException when client.delete throws', () async {
        // Arrange
        when(
          () => mockDataClient.delete(
            id: any(named: 'id'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(mockHttpException);

        // Act & Assert
        expect(
          () => repository.delete(id: mockId),
          throwsA(isA<HttpException>()),
        );
        verify(() => mockDataClient.delete(id: mockId)).called(1);
      });

      // Note: delete typically doesn't involve FormatException unless the client
      // implementation has unusual behavior, so we omit that test case here.
    });

    group('count', () {
      test('should call client.count and return the unwrapped count', () async {
        // Arrange
        when(
          () => mockDataClient.count(
            userId: any(named: 'userId'),
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseCount);

        // Act
        final result = await repository.count(filter: mockQuery);

        // Assert
        expect(result, 10);
        verify(() => mockDataClient.count(filter: mockQuery)).called(1);
      });

      test('should rethrow HttpException when client.count throws', () async {
        // Arrange
        when(
          () => mockDataClient.count(
            userId: any(named: 'userId'),
            filter: any(named: 'filter'),
          ),
        ).thenThrow(mockHttpException);

        // Act & Assert
        expect(() => repository.count(), throwsA(isA<HttpException>()));
      });

      test('should rethrow FormatException when client.count throws', () async {
        // Arrange
        when(
          () => mockDataClient.count(
            userId: any(named: 'userId'),
            filter: any(named: 'filter'),
          ),
        ).thenThrow(mockFormatException);

        // Act & Assert
        expect(() => repository.count(), throwsA(isA<FormatException>()));
      });
    });

    group('aggregate', () {
      test(
        'should call client.aggregate and return the unwrapped result',
        () async {
          // Arrange
          when(
            () => mockDataClient.aggregate(
              pipeline: any(named: 'pipeline'),
              userId: any(named: 'userId'),
            ),
          ).thenAnswer((_) async => mockSuccessResponseAggregate);

          // Act
          final result = await repository.aggregate(
            pipeline: mockAggregatePipeline,
          );

          // Assert
          expect(result, mockAggregateResult);
          verify(
            () => mockDataClient.aggregate(pipeline: mockAggregatePipeline),
          ).called(1);
        },
      );

      test(
        'should rethrow HttpException when client.aggregate throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.aggregate(
              pipeline: any(named: 'pipeline'),
              userId: any(named: 'userId'),
            ),
          ).thenThrow(mockHttpException);

          // Act & Assert
          expect(
            () => repository.aggregate(pipeline: mockAggregatePipeline),
            throwsA(isA<HttpException>()),
          );
        },
      );

      test(
        'should rethrow FormatException when client.aggregate throws',
        () async {
          // Arrange
          when(
            () => mockDataClient.aggregate(pipeline: any(named: 'pipeline')),
          ).thenThrow(mockFormatException);

          // Act & Assert
          expect(
            () => repository.aggregate(pipeline: mockAggregatePipeline),
            throwsA(isA<FormatException>()),
          );
        },
      );
    });

    group('entityUpdated stream', () {
      test('emits the entity Type when create is successful', () {
        // Arrange
        when(
          () => mockDataClient.create(
            item: any(named: 'item'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseItem);

        // Assert
        expect(repository.entityUpdated, emits(_MockData));

        // Act
        repository.create(item: mockItem);
      });

      test('emits the entity Type when update is successful', () {
        // Arrange
        when(
          () => mockDataClient.update(
            id: any(named: 'id'),
            item: any(named: 'item'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => mockSuccessResponseUpdatedItem);

        // Assert
        expect(repository.entityUpdated, emits(_MockData));

        // Act
        repository.update(id: mockId, item: mockItem);
      });

      test('emits the entity Type when delete is successful', () {
        // Arrange
        when(
          () => mockDataClient.delete(
            id: any(named: 'id'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async {});

        // Assert
        expect(repository.entityUpdated, emits(_MockData));

        // Act
        repository.delete(id: mockId);
      });

      test('does not emit an event when create fails', () async {
        // This test requires its own repository instance to control the
        // stream lifecycle and prevent a timeout with neverEmits.
        final localRepository = DataRepository<_MockData>(
          dataClient: mockDataClient,
        );
        // Arrange
        when(
          () => mockDataClient.create(
            item: any(named: 'item'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(mockHttpException);

        // Assert
        expect(localRepository.entityUpdated, neverEmits(anything));

        // Act & Assert
        // Use `expectLater` to test a Future that completes with an error.
        await expectLater(
          localRepository.create(item: mockItem),
          throwsA(isA<HttpException>()),
        );

        // Clean up the local stream controller to allow the test to complete.
        localRepository.dispose();
      });
    });

    group('dispose', () {
      test('closes the entityUpdated stream', () {
        // Act
        repository.dispose();

        // Assert
        expect(repository.entityUpdated, emitsDone);
      });
    });
  });
}
