# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.3] - 2025-08-14

### Added
- **Primitive type support for listeners**: Added support for `Stream<String>`, `Stream<int>`, `Stream<double>`, `Stream<bool>`, and `Stream<num>` listeners
- **List of primitives support**: Added support for `Stream<List<String>>`, `Stream<List<int>>`, `Stream<List<double>>`, `Stream<List<bool>>`, and `Stream<List<num>>` listeners
- **Enhanced emitter type handling**: Emitters now support primitives and raw `Map`/`List` data directly without calling `toJson()`
- **Standard generated file headers**: All generated files now include coverage ignore and analyzer ignore directives
- **Type-safe primitive handling**: Primitive listeners include runtime type checking with descriptive error messages
- **Safe primitive list casting**: Lists of primitives use safe casting with error handling

### Changed
- **Builder architecture**: Refactored builder to handle primitive types separately from model types
- **Listener generation logic**: Enhanced to branch between primitive, list-of-primitive, and model listeners
- **Emitter generation**: Updated to detect primitive types and emit them directly vs. calling `toJson()`
- **Example interface**: Extended `example/chat_socket.dart` to showcase all supported listener types
- **Documentation**: Completely rewrote README.md with current features and usage examples

### Technical Details
- Primitive listeners use `data is Type` checks and emit type errors for mismatches
- List of primitives use `data.cast<Type>().toList()` for safe conversion
- Emitters detect primitives via `getDisplayString(withNullability: false)` and type name matching
- Generated files include standard headers: `// coverage:ignore-file` and comprehensive `// ignore_for_file` directives

## [0.0.2] - 2025-07-31

### Changed
- **Dependency upgrades**: Updated plugin dependencies to latest compatible versions
- **Builder optimizations**: Improved code generation efficiency and reduced boilerplate

## [0.0.1] - 2025-07-10

### Added
- **Initial release**: Basic Socket.IO client code generation
- **Core annotations**: `@SocketIO()`, `@SocketIOListener()`, and `@SocketIOEmitter()`
- **Model support**: Generated listeners for custom models with `fromJson()` methods
- **Stream-based API**: All listeners return Dart streams with automatic cleanup
- **Basic examples**: Initial example interface and model implementations
- **Build system integration**: `build.yaml` configuration for code generation
- **Documentation**: Initial README with setup and usage instructions

### Features
- Abstract class annotation with `@SocketIO()`
- Event listener methods returning typed streams
- Event emitter methods for sending data
- Automatic Socket.IO event subscription management
- Stream cleanup and listener removal on cancel
