# data_repository

![coverage: percentage](https://img.shields.io/badge/coverage-100-green)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: PolyForm Free Trial](https://img.shields.io/badge/License-PolyForm%20Free%20Trial-blue)](https://polyformproject.org/licenses/free-trial/1.0.0)

A generic repository that acts as an abstraction layer over an `DataClient`. It provides standard data access methods (CRUD, querying) for a specific data type `T`, delegating operations to the injected client.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  data_repository:
    git:
      url: https://github.com/flutter-news-app-full-source-code/data-repository.git
      # Optionally specify a ref (branch, tag, commit hash)
      # ref: main
```

You will also need to include the `data_client` package, which this repository depends on, and potentially `http_client` if you need to handle its specific exceptions.

```yaml
dependencies:
  data_client:
    git:
      url: https://github.com/flutter-news-app-full-source-code/data-client.git
  http_client: # Needed for handling specific exceptions
    git:
      url: https://github.com/flutter-news-app-full-source-code/http-client.git
```

## Features

*   **Abstraction:** Provides a clean interface for data operations, hiding the underlying `DataClient` implementation details and the `SuccessApiResponse` envelope structure.
*   **User Scoping:** Supports optional user-scoped data operations via a `userId` parameter in all data access methods, allowing for both user-specific and global resource management.
*   **CRUD Operations:** Supports standard Create, Read (`Future<T>`), Update (`Future<T>`), and Delete (`Future<void>`) operations for a generic type `T`. These methods now accept an optional `String? userId`.
*   **Advanced Querying:** A single `readAll` method returns a `Future<PaginatedResponse<T>>` and supports rich filtering, multi-field sorting, and cursor-based pagination, aligning with modern NoSQL database capabilities.
*   **Error Propagation:** Catches and re-throws exceptions (like `HttpException` subtypes or `FormatException`) from the data client layer, allowing higher layers to handle them appropriately.
*   **Counting and Aggregation:** Exposes `count` for efficient document
    counting and `aggregate` for executing complex data pipelines.
*   **Reactive Updates:** Provides a stream, `entityUpdated`, that emits an
    event whenever a CUD (Create, Update, Delete) operation is successfully
    completed. This allows different parts of an application to react to data
    changes in real-time.
*   **Dependency Injection:** Designed to receive an `DataClient<T>` instance via its constructor.

## Usage

Instantiate the repository by providing an implementation of `DataClient<T>`.

```dart
import 'package:data_client/data_client.dart';
import 'package:data_repository/data_repository.dart';
import 'package:core/core.dart'; // For exception handling

// Define your data model
class MyData {
  final String id;
  final String name;

  MyData({required this.id, required this.name});

  // Add fromJson/toJson if needed by your client implementation
}

// Assume you have an implementation of DataClient<MyData>
// (e.g., HttpDataClient, MockDataClient, etc.)
late DataClient<MyData> myDataClient; // Initialize this appropriately

// Create the repository instance
final myDataRepository = DataRepository<MyData>(dataClient: myDataClient);

// Use the repository methods
Future<void> exampleUsage() async {
  const userId = 'example-user-id'; // Example user ID

  try {
    // Create an item for a specific user
    final newItem = MyData(id: 'temp', name: 'New Item');
    final createdItem = await myDataRepository.create(item: newItem, userId: userId);
    print('Created: ${createdItem.id}, ${createdItem.name} for user $userId');

    // Read an item for a specific user
    final readItem = await myDataRepository.read(id: createdItem.id, userId: userId);
    print('Read: ${readItem.id}, ${readItem.name} for user $userId');

    // Read all items for a user with pagination
    final allItemsResponse = await myDataRepository.readAll(
      userId: userId,
      pagination: PaginationOptions(limit: 10),
    );
    print('Read ${allItemsResponse.items.length} items for user $userId.');
    if (allItemsResponse.nextCursor != null) {
      print('More items available (nextCursor: ${allItemsResponse.nextCursor})');
    }

    // Query items for a user with filtering and sorting
    final filter = {'status': 'published'};
    final sort = [SortOption('publishDate', SortOrder.desc)];
    final queriedItemsResponse = await myDataRepository.readAll(
      userId: userId,
      filter: filter,
      sort: sort,
    );
    print('Found ${queriedItemsResponse.items.length} items matching filter for user $userId.');

    // Count items for a user
    final count = await myDataRepository.count(
      userId: userId,
      filter: {'status': 'published'},
    );
    print('User has $count published items.');

    // Aggregate data for a user
    final pipeline = [
      {
        r'$group': {'_id': r'$category', 'total': {r'$sum': 1}},
      },
      {
        r'$sort': {'total': -1},
      },
    ];
    final aggregateResult =
        await myDataRepository.aggregate(pipeline: pipeline, userId: userId);
    print('Aggregation result: $aggregateResult');

    // Update an item for a specific user
    final updatedItemData = MyData(id: createdItem.id, name: 'Updated Name');
    final updatedItem = await myDataRepository.update(id: createdItem.id, item: updatedItemData, userId: userId);
    print('Updated: ${updatedItem.id}, ${updatedItem.name} for user $userId');

    // Example of a global read (without userId)
     final PaginatedResponse<MyData> globalItemsResponse =
        await myDataRepository.readAll(pagination: PaginationOptions(limit: 5));
    print('Read ${globalItemsResponse.items.length} global items.');

    // Listen for data changes
    final subscription = myDataRepository.entityUpdated.listen((_) {
      print('A data entity was created, updated, or deleted. Refreshing UI...');
      // Trigger a refresh of the data or UI components
    });

    // ... perform more operations ...

    // Don't forget to cancel the subscription when done
    await subscription.cancel();

    // And dispose the repository when it's no longer needed
    myDataRepository.dispose();


  } on HttpException catch (e) {
    // Handle specific HTTP errors from the client
    // Note: HttpException subtypes from core do not have statusCode
    print('HTTP Error: ${e.message}');
    if (e is NotFoundException) {
      print('Item not found.');
    } else if (e is ForbiddenException) {
      print('Permission denied for this operation.');
    }
  } on FormatException catch (e) {
    // Handle data format errors during deserialization
    print('Data Format Error: $e');
  } catch (e) {
    // Handle other unexpected errors
    print('An unexpected error occurred: $e');
  }
}

```


## 🔑 Licensing

This package is source-available and licensed under the [PolyForm Free Trial 1.0.0](LICENSE). Please review the terms before use.

For commercial licensing options that grant the right to build and distribute unlimited applications, please visit the main [**Flutter News App - Full Source Code Toolkit**](https://github.com/flutter-news-app-full-source-code) organization.
