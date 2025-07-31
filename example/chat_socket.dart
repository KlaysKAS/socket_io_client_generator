import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client_gen_annotations/socket_io_client_gen_annotations.dart';

part 'chat_socket.socket.dart';

/// Example message model with fromJson/toJson methods
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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: int.parse(json['id'].toString()),
      text: json['text'] as String,
      sender: json['sender'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Example user model
class User {
  final String id;
  final String username;
  final String avatar;

  User({
    required this.id,
    required this.username,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
    };
  }
}

/// Abstract class that will be used to generate concrete implementation
/// This class will be used to generate the concrete implementation
@SocketIO()
abstract class ChatSocketSystem {
  factory ChatSocketSystem(Socket socket) = _ChatSocketSystem;

  /// Listen to new messages
  @SocketIOListener('new-message')
  Stream<ChatMessage> listenNewMessages();

  /// Listen to user joined events
  @SocketIOListener('user-joined')
  Stream<User> listenUserJoined();

  /// Listen to user left events
  @SocketIOListener('user-left')
  Stream<User> listenUserLeft();

  /// Emit new message
  @SocketIOEmitter('create-message')
  void emitNewMessage(ChatMessage message);

  /// Emit user join
  @SocketIOEmitter('join-chat')
  void emitJoinChat(User user);
} 