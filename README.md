<div align="center">
  <img src="https://avatars.githubusercontent.com/u/202675624?s=400&u=dc72a2b53e8158956a3b672f8e52e39394b6b610&v=4" alt="Flutter News App Toolkit Logo" width="220">
  <h1>Data Repository</h1>
  <p><strong>A generic repository that serves as a crucial abstraction layer within the FLutter News App Full Source Code Toolkit.</strong></p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/coverage-100%25-green?style=for-the-badge" alt="coverage: 100%">
  <a href="https://flutter-news-app-full-source-code.github.io/docs/"><img src="https://img.shields.io/badge/LIVE_DOCS-VIEW-slategray?style=for-the-badge" alt="Live Docs: View"></a>
  <a href="https://github.com/flutter-news-app-full-source-code"><img src="https://img.shields.io/badge/MAIN_PROJECT-BROWSE-purple?style=for-the-badge" alt="Main Project: Browse"></a>
</p>

This `data_repository` package serves as a crucial abstraction layer within the [**Flutter News App Full Source Code Toolkit**](https://github.com/flutter-news-app-full-source-code). It provides a generic, type-safe interface for interacting with data sources, decoupling business logic from the underlying data client implementations. By mirroring the data access methods of a `DataClient`, it ensures consistency and simplifies data operations across the Flutter mobile app, web dashboard, and Dart Frog backend API.

## ⭐ Feature Showcase: Robust Data Access & Management

This package offers a comprehensive set of features for managing data entities.

<details>
<summary><strong>🧱 Core Functionality</strong></summary>

### 🚀 Generic Data Operations
- **`DataRepository<T>`:** A generic class that provides a consistent interface for CRUD (Create, Read, Update, Delete) operations, querying, counting, and aggregation for any data type `T`.
- **Abstraction over `DataClient`:** Hides the complexities of `DataClient` implementations and `SuccessApiResponse` structures, offering a clean, business-logic-focused API.

### 🔐 User Scoping & Permissions
- **Optional `userId` Parameter:** All data access methods support an optional `userId` parameter, enabling seamless management of both user-specific and global resources.

### 🔍 Advanced Querying
- **`readAll` Method:** A powerful method that returns a `Future<PaginatedResponse<T>>`, supporting rich filtering, multi-field sorting, and cursor-based pagination, compatible with modern NoSQL database capabilities.
- **`count` and `aggregate`:** Efficient methods for counting documents and executing complex data aggregation pipelines directly on the data source.

### 🔄 Reactive Updates
- **`entityUpdated` Stream:** A broadcast stream that emits the `Type` of a data entity whenever a Create, Update, or Delete operation is successfully completed. This allows other parts of the application to react to data changes in real-time, facilitating dynamic UI updates and side effects.

### 🛡️ Robust Error Handling
- **Exception Propagation:** Catches and re-throws standardized exceptions (like `HttpException` subtypes or `FormatException`) from the underlying data client layer. This ensures predictable error handling and allows higher layers (e.g., BLoCs, API route handlers) to implement specific error recovery logic.

### 💉 Dependency Injection Ready
- **Constructor Injection:** Designed to receive an `DataClient<T>` instance via its constructor, promoting loose coupling and testability.

> **💡 Your Advantage:** You get a meticulously designed, production-quality data access layer that simplifies interactions with your data sources, ensures consistency, and provides robust error handling and reactive capabilities. This package accelerates development by providing a solid foundation for data management.

</details>

## 🔑 Licensing
This `data_repository` package is an integral part of the [**Flutter News App Full Source Code Toolkit**](https://github.com/flutter-news-app-full-source-code). For comprehensive details regarding licensing, including trial and commercial options for the entire toolkit, please refer to the main toolkit organization page.
