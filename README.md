# socket_io_client_generator

Generate a type-safe Socket.IO client API from a simple annotated Dart interface. The generator creates a concrete implementation that listens to events as Streams and emits events with strongly-typed arguments.

## What's new
- Primitive listeners supported: `Stream<String|int|double|bool|num>`
- Lists of primitives supported: `Stream<List<String|int|double|bool|num>>`
- Emitters support primitives and raw `Map`/`List` data directly; non-primitive objects use `toJson()`
- Generated files include standard headers (coverage ignore and analyzer ignores)

## Installation
Add the annotations and generator to your app/package:

```yaml
dependencies:
  socket_io_client: ^3.1.2
  socket_io_client_gen_annotations:
    git:
      url: https://github.com/KlaysKAS/socket_io_client_gen_annotations.git
      ref: v0.0.1

dev_dependencies:
  build_runner: ^3.0.2
  socket_io_client_generator:
    git:
      url: https://github.com/KlaysKAS/socket_io_client_generator.git
```

## Define your socket interface
Create an abstract interface annotated with `@SocketIO()` and declare methods for listeners and emitters. Add a `part` directive so the generator can write alongside your file.

```dart
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client_gen_annotations/socket_io_client_gen_annotations.dart';

import 'models/models.dart';

part 'chat_socket.socket.dart';

@SocketIO()
abstract class ChatSocketSystem {
  // The generator will create a private implementation `_ChatSocketSystem`.
  factory ChatSocketSystem(Socket socket) = _ChatSocketSystem;

  // Models: parsed via Model.fromJson(Map<String,dynamic>)
  @SocketIOListener('new-message')
  Stream<ChatMessage> listenNewMessages();

  @SocketIOListener('user-joined')
  Stream<User> listenUserJoined();

  // Lists of models
  @SocketIOListener('message-history')
  Stream<List<ChatMessage>> listenMessageHistory();

  // Dynamic passthrough
  @SocketIOListener('debug-info')
  Stream<dynamic> listenDebugInfo();

  // Event-only
  @SocketIOListener('user-typing')
  Stream<void> listenUserTyping();

  // PRIMITIVES (new)
  @SocketIOListener('server-version')
  Stream<String> listenServerVersion();

  @SocketIOListener('ping-count')
  Stream<int> listenPingCount();

  @SocketIOListener('cpu-load')
  Stream<double> listenCpuLoad();

  @SocketIOListener('feature-flag')
  Stream<bool> listenFeatureFlag();

  // LISTS OF PRIMITIVES (new)
  @SocketIOListener('tags')
  Stream<List<String>> listenTags();

  @SocketIOListener('scores')
  Stream<List<int>> listenScores();

  // Emitters
  @SocketIOEmitter('create-message')
  void emitNewMessage(ChatMessage message);

  @SocketIOEmitter('typing')
  void emitTyping(String userId);

  @SocketIOEmitter('raw-data')
  void emitRawData(dynamic data);
}
```

### Supported listener return types
- `Stream<T>` where `T` is one of:
  - Primitive: `String`, `int`, `double`, `bool`, `num` (passed through with type-check)
  - Model with `fromJson(Map<String, dynamic>)`
  - `dynamic` (passed through)
  - `void` (event-only; emits `null` when event arrives)
- `Stream<List<T>>` where `T` is:
  - Primitive types above (casted safely)
  - Model with `fromJson(Map<String, dynamic>)`

### Supported emitter parameter types
- Primitives: `String`, `bool`, `int`, `double`, `num`, `dynamic` (emitted as-is)
- `Map<...>` and `List<...>` (emitted as-is)
- Custom models with `toJson()` (emitted as `model.toJson()`)

## Generate
Run code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or continuously watch:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Use
Create a `Socket`, instantiate the generated implementation, then subscribe/emit.

```dart
import 'package:socket_io_client/socket_io_client.dart';
import 'chat_socket.dart';

final socket = io(
  'http://localhost:3000',
  OptionBuilder().setTransports(['websocket']).enableAutoConnect().build(),
);

final chat = ChatSocketSystem(socket);

socket.connect();

chat.listenServerVersion().listen((v) => print('server-version: $v'));
chat.listenPingCount().listen((n) => print('ping-count: $n'));
chat.listenNewMessages().listen((m) => print('new-message: ${m.text} from ${m.sender}'));

chat.emitTyping('user-123');
chat.emitRawData({'debug': true});
```

## Models
Your models should implement:

```dart
factory Model.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
```

## Generated file notes
- Files are named `your_file.socket.dart` and include standard headers to ignore coverage and common analyzer lints for generated code.
- Streams automatically remove the underlying Socket.IO listener when canceled.

## Example
See `example/` for an interface (`chat_socket.dart`) and simple models (`example/models`).
