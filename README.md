# Socket.IO Client Generator for Flutter

A Flutter/Dart plugin that generates type-safe Socket.IO client code using annotations. It creates classes that subscribe to Socket.IO events and redirect them to Dart streams for easy and safe consumption in your app.

## Features

- 🔌 Type-safe Socket.IO client code generation
- 📡 Stream-based event subscription with auto-unsubscribe
- 🏗️ Simple annotation-based API
- 🚀 No boilerplate, just describe your contract and generate

## Getting started

Add the dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  socket_io_client_generator:
  socket_io_client:
```

## Usage

### 1. Define your data models

Your models must have `fromJson` and `toJson` methods:

```dart
class ChatMessage {
  final int id;
  final String text;
  final String sender;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: int.parse(json['id'].toString()),
    text: json['text'] as String,
    sender: json['sender'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'sender': sender,
    'timestamp': timestamp.toIso8601String(),
  };
}
```

### 2. Опишите абстрактный класс с аннотациями

```dart
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client_generator/socket_io_client_generator.dart';

part 'chat_socket.socket.dart';

@SocketIO()
abstract class ChatSocketSystem {
  factory ChatSocketSystem(Socket socket) = _ChatSocketSystem;

  @SocketIOListener('new-message')
  Stream<ChatMessage> listenNewMessages();

  @SocketIOListener('user-joined')
  Stream<User> listenUserJoined();

  @SocketIOListener('user-left')
  Stream<User> listenUserLeft();

  @SocketIOEmitter('create-message')
  void emitNewMessage(ChatMessage message);

  @SocketIOEmitter('join-chat')
  void emitJoinChat(User user);
}
```

### 3. Запустите генерацию кода

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Используйте сгенерированный класс

```dart
final socket = io('http://localhost:3000');
final chatSystem = ChatSocketSystem(socket);

chatSystem.listenNewMessages().listen((msg) {
  print('New message: \\${msg.text}');
});

chatSystem.emitNewMessage(ChatMessage(...));
```

## Как это работает?

- Для каждого метода с `@SocketIOListener` создается Stream, который подписывается на событие сокета через `socket.on(event, handler)`.
- При отмене подписки стрим автоматически вызывает `socket.off(event, handler)` и закрывает контроллер.
- Для методов с `@SocketIOEmitter` генерируется вызов `socket.emit(event, data.toJson())`.
- Все типы должны иметь методы `fromJson` и `toJson`.

## Аннотации

- `@SocketIO()` — помечает абстрактный класс для генерации реализации
- `@SocketIOListener('event')` — помечает метод, который будет слушать событие и возвращать Stream
- `@SocketIOEmitter('event')` — помечает метод, который будет отправлять событие

## Пример сгенерированного метода

```dart
@override
Stream<ChatMessage> listenNewMessages() {
  final eventName = 'new-message';
  final controller = StreamController<ChatMessage>();

  dynamic listener(dynamic data) {
    if (data is Map<String, dynamic>) {
      controller.add(ChatMessage.fromJson(data));
    } else {
      controller.addError(ArgumentError('Expected Map<String, dynamic> but got \\${data.runtimeType}'));
    }
  }

  _socket.on(eventName, listener);

  controller.onCancel = () {
    _socket.off(eventName, listener);
    controller.close();
  };

  return controller.stream;
}
```
