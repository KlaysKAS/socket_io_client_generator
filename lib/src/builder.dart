import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:socket_io_client_gen_annotations/socket_io_client_gen_annotations.dart';
import 'package:source_gen/source_gen.dart' as sg;

Builder socketBuilder(BuilderOptions options) =>
    sg.LibraryBuilder(SocketBuilder(), generatedExtension: '.socket.dart');

class SocketBuilder extends sg.GeneratorForAnnotation<SocketIO> {
  const SocketBuilder();

  @override
  String generateForAnnotatedElement(
    Element element,
    sg.ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw sg.InvalidGenerationSourceError(
        'SocketIO annotation can only be applied to classes',
        element: element,
      );
    }

    if (!element.isAbstract) {
      throw sg.InvalidGenerationSourceError(
        'SocketIO annotation can only be applied to abstract classes',
        element: element,
      );
    }

    final className = element.name;
    final implementationClassName = '_$className';

    final methods = <Method>[];
    final fields = <Field>[];

    // Add socket field
    fields.add(
      Field(
        (b) => b
          ..name = '_socket'
          ..type = refer('Socket')
          ..modifier = FieldModifier.final$,
      ),
    );

    // Process methods
    for (final method in element.methods) {
      if (method.isStatic || method.kind == ElementKind.CONSTRUCTOR) continue;

      final socketListener = _getSocketListenerAnnotation(method);
      final socketEmitter = _getSocketEmitterAnnotation(method);

      if (socketListener != null) {
        methods.add(_generateListenerMethod(method, socketListener));
      } else if (socketEmitter != null) {
        methods.add(_generateEmitterMethod(method, socketEmitter));
      }
    }

    // Generate the implementation class
    final classBuilder = Class((b) {
      b
        ..name = implementationClassName
        ..implements.add(refer(className))
        ..fields.addAll(fields)
        ..constructors.add(
          Constructor(
            (b) => b
              ..requiredParameters.add(
                Parameter(
                  (b) => b
                    ..name = 'socket'
                    ..type = refer('Socket'),
                ),
              )
              ..initializers.add(Code('_socket = socket')),
          ),
        )
        ..methods.addAll(methods);
    });

    final library = Library((b) {
      b
        ..directives.add(
          Directive.partOf('${buildStep.inputId.pathSegments.last.replaceAll('.dart', '')}.dart'),
        )
        ..body.add(classBuilder);
    });

    final emitter = DartEmitter();
    final code = library.accept(emitter).toString();
    final formatter = DartFormatter(languageVersion: Version(3, 8, 0));
    return formatter.format(code);
  }

  SocketIOListener? _getSocketListenerAnnotation(MethodElement method) {
    for (final annotation in method.metadata) {
      final element = annotation.element;
      if (element is ConstructorElement && element.enclosingElement3.name == 'SocketIOListener') {
        final reader = sg.ConstantReader(annotation.computeConstantValue());
        return SocketIOListener(reader.read('event').stringValue);
      }
    }
    return null;
  }

  SocketIOEmitter? _getSocketEmitterAnnotation(MethodElement method) {
    for (final annotation in method.metadata) {
      final element = annotation.element;
      if (element is ConstructorElement && element.enclosingElement3.name == 'SocketIOEmitter') {
        final reader = sg.ConstantReader(annotation.computeConstantValue());
        return SocketIOEmitter(reader.read('event').stringValue);
      }
    }
    return null;
  }

  Method _generateListenerMethod(MethodElement method, SocketIOListener annotation) {
    final returnType = method.returnType;
    if (!returnType.toString().startsWith('Stream<')) {
      throw sg.InvalidGenerationSourceError(
        'SocketIOListener methods must return Stream<T>',
        element: method,
      );
    }
    final genericType = returnType.toString().substring(7, returnType.toString().length - 1);
    return Method(
      (b) => b
        ..name = method.name
        ..returns = refer('Stream<$genericType>')
        ..annotations.add(refer('override'))
        ..body = Code('''
        final eventName = '${annotation.event}';
        final controller = StreamController<$genericType>();
        
        dynamic listener(dynamic data) {
          if (data is Map<String, dynamic>) {
            controller.add($genericType.fromJson(data));
          } else {
            controller.addError(ArgumentError('Expected Map<String, dynamic> but got \${data.runtimeType}'));
          }
        }
        
        _socket.on(eventName, listener);
        
        controller.onCancel = () {
          _socket.off(eventName, listener);
          controller.close();
        };
        
        return controller.stream;
      '''),
    );
  }

  Method _generateEmitterMethod(MethodElement method, SocketIOEmitter annotation) {
    if (method.parameters.isEmpty) {
      throw sg.InvalidGenerationSourceError(
        'SocketIOEmitter methods must have at least one parameter',
        element: method,
      );
    }
    final parameter = method.parameters.first;
    final parameterType = parameter.type.toString();
    return Method(
      (b) => b
        ..name = method.name
        ..returns = refer('void')
        ..annotations.add(refer('override'))
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = parameter.name
              ..type = refer(parameterType),
          ),
        )
        ..body = Code('''
        _socket.emit('${annotation.event}', ${parameter.name}.toJson());
      '''),
    );
  }
}
