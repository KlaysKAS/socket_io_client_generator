import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client_gen_annotations/socket_io_client_gen_annotations.dart';

import 'models/models.dart';

part 'chat_socket.socket.dart';

/// Abstract class that will be used to generate concrete implementation
/// This class showcases all supported stream types
@SocketIO()
abstract class ChatSocketSystem {
  factory ChatSocketSystem(Socket socket) = _ChatSocketSystem;

  // ===== STREAM<T> - Single object parsing =====
  /// Listen to new messages - parses single ChatMessage
  @SocketIOListener('new-message')
  Stream<ChatMessage> listenNewMessages();

  /// Listen to user joined events - parses single User
  @SocketIOListener('user-joined')
  Stream<User> listenUserJoined();

  /// Listen to user left events - parses single User
  @SocketIOListener('user-left')
  Stream<User> listenUserLeft();

  // ===== STREAM<List<T>> - List of objects parsing =====
  /// Listen to user list updates - parses List<User>
  @SocketIOListener('user-list-update')
  Stream<List<User>> listenUserListUpdate();

  /// Listen to message history - parses List<ChatMessage>
  @SocketIOListener('message-history')
  Stream<List<ChatMessage>> listenMessageHistory();

  /// Listen to notification list - parses List<Notification>
  @SocketIOListener('notification-list')
  Stream<List<Notification>> listenNotificationList();

  // ===== STREAM<dynamic> - Raw data without transformation =====
  /// Listen to raw system events - passes through any data type
  @SocketIOListener('system-event')
  Stream<dynamic> listenSystemEvents();

  /// Listen to debug information - passes through any data type
  @SocketIOListener('debug-info')
  Stream<dynamic> listenDebugInfo();

  // ===== STREAM<void> - Event-only notifications =====
  /// Listen to typing indicators - only cares about event occurrence
  @SocketIOListener('user-typing')
  Stream<void> listenUserTyping();

  /// Listen to connection status changes - only cares about event occurrence
  @SocketIOListener('connection-status')
  Stream<void> listenConnectionStatus();

  /// Listen to room join/leave events - only cares about event occurrence
  @SocketIOListener('room-event')
  Stream<void> listenRoomEvents();

  // ===== STREAM<PRIMITIVE> - Primitive values pass-through =====
  /// Listen to server version - parses String primitive
  @SocketIOListener('server-version')
  Stream<String> listenServerVersion();

  /// Listen to ping counter - parses int primitive
  @SocketIOListener('ping-count')
  Stream<int> listenPingCount();

  /// Listen to CPU load - parses double primitive
  @SocketIOListener('cpu-load')
  Stream<double> listenCpuLoad();

  /// Listen to feature flag - parses bool primitive
  @SocketIOListener('feature-flag')
  Stream<bool> listenFeatureFlag();

  // ===== STREAM<List<PRIMITIVE>> - Lists of primitive values pass-through =====
  /// Listen to tags - parses List<String>
  @SocketIOListener('tags')
  Stream<List<String>> listenTags();

  /// Listen to scores - parses List<int>
  @SocketIOListener('scores')
  Stream<List<int>> listenScores();

  // ===== EMITTERS =====
  /// Emit new message
  @SocketIOEmitter('create-message')
  void emitNewMessage(ChatMessage message);

  /// Emit user join
  @SocketIOEmitter('join-chat')
  void emitJoinChat(User user);

  /// Emit user leave
  @SocketIOEmitter('leave-chat')
  void emitLeaveChat(User user);

  /// Emit typing indicator
  @SocketIOEmitter('typing')
  void emitTyping(String userId);

  /// Emit raw data
  @SocketIOEmitter('raw-data')
  void emitRawData(dynamic data);
}
