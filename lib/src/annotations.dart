/// Annotation to mark a class as a Socket.IO client generator
/// This class will be used to generate concrete implementation
class SocketIO {
  const SocketIO();
}

/// Annotation to mark a method as a Socket.IO listener
/// The method should return a Stream<T> where T has fromJson method
class SocketIOListener {
  final String event;
  
  const SocketIOListener(this.event);
}

/// Annotation to mark a method as a Socket.IO emitter
/// The method should accept a parameter of type T where T has toJson method
class SocketIOEmitter {
  final String event;
  
  const SocketIOEmitter(this.event);
} 