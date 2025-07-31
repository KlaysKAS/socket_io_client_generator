import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:source_gen/source_gen.dart' as sg;

import 'annotations.dart';

Builder socketBuilder(BuilderOptions options) =>
    sg.LibraryBuilder(SocketBuilder(), generatedExtension: '.socket.dart');

class SocketBuilder extends sg.GeneratorForAnnotation<SocketIO> {
  const SocketBuilder();

  @override
  String generateForAnnotatedElement(
    Element2 element,
    sg.ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement2) {
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

    final className = element.name3;
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
    for (final method in element.methods2) {
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
        ..implements.add(refer(className ?? ''))
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

  SocketIOListener? _getSocketListenerAnnotation(MethodElement2 method) {
    for (final annotation in method.metadata2.annotations) {
      final element = annotation.element2;
      if (element is ConstructorElement2 && element.enclosingElement2.name3 == 'SocketIOListener') {
        final reader = sg.ConstantReader(annotation.computeConstantValue());
        return SocketIOListener(reader.read('event').stringValue);
      }
    }
    return null;
  }

  SocketIOEmitter? _getSocketEmitterAnnotation(MethodElement2 method) {
    for (final annotation in method.metadata2.annotations) {
      final element = annotation.element2;
      if (element is ConstructorElement2 && element.enclosingElement2.name3 == 'SocketIOEmitter') {
        final reader = sg.ConstantReader(annotation.computeConstantValue());
        return SocketIOEmitter(reader.read('event').stringValue);
      }
    }
    return null;
  }

  Method _generateListenerMethod(MethodElement2 method, SocketIOListener annotation) {
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
        ..name = method.name3
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

  Method _generateEmitterMethod(MethodElement2 method, SocketIOEmitter annotation) {
    if (method.typeParameters2.isEmpty) {
      throw sg.InvalidGenerationSourceError(
        'SocketIOEmitter methods must have at least one parameter',
        element: method,
      );
    }
    final parameter = method.typeParameters2.first;
    final parameterType = parameter.bound;
    return Method(
      (b) => b
        ..name = method.name3
        ..returns = refer('void')
        ..annotations.add(refer('override'))
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = parameter.displayName
              ..type = refer(parameterType?.getDisplayString() ?? 'dynamic'),
          ),
        )
        ..body = Code('''
        _socket.emit('${annotation.event}', ${parameter.displayName}.toJson());
      '''),
    );
  }
}
