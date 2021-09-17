import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

void main() {
  testWidgets('throws assertion error if ancestor PropertyChangeProvider not found', (tester) async {
    final widget = Builder(builder: (context) {
      return PropertyChangeConsumer<MyModel, String>(builder: (context, model, properties) {
        return Container();
      });
    });

    await tester.pumpWidget(widget);
    expect(tester.takeException(), isAssertionError);
  });

  group('consumer without properties', () {
    testWidgets('is rebuilt when notifyListeners() is called without a property', (tester) async {
      final model = MyModel();
      final listener = expectAsync3((context, model, properties) {
        return Container();
      }, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<MyModel, String>(builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('is rebuilt when notifyListeners() is called with a property', (tester) async {
      final model = MyModel();
      final listener = expectAsync3((context, model, properties) {
        return Container();
      }, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<MyModel, String>(builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners('foo');
      await tester.pump();
    });

    testWidgets('provides model instance to builder', (tester) async {
      final model = MyModel();
      final listener = expectAsync3((context, _model, property) {
        expect(model, _model);
        return Container();
      }, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<MyModel, String>(builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
    });

    testWidgets('provides changed property to builder', (tester) async {
      final model = MyModel();
      const property = 'foo';
      final multi = MultiExpectAsync3([
        expectAsync3((context, model, Set<String>? properties) {
          expect(properties, isEmpty);
          return Container();
        }),
        expectAsync3((context, model, Set<String>? properties) {
          expect(properties!.contains(property), isTrue);
          return Container();
        })
      ]);

      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<MyModel, String>(builder: multi.listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners(property);
      await tester.pump();
    });
  });

  group('consumer with properties', () {
    testWidgets('is not rebuilt when notifyListeners() is called without a property', (tester) async {
      final model = MyModel();
      final listener = expectAsync3((context, model, properties) {
        return Container();
      }, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<MyModel, String>(properties: const ['foo'], builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('is not rebuilt when notifyListeners() is called with a non-matching property', (tester) async {
      final model = MyModel();
      final listener = expectAsync3((context, model, properties) {
        return Container();
      }, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<MyModel, String>(properties: const ['foo'], builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners('bar');
      await tester.pump();
    });

    testWidgets('is rebuilt when notifyListeners() is called with a matching property', (tester) async {
      final model = MyModel();
      const property = 'foo';
      final listener = expectAsync3((context, model, properties) {
        return Container();
      }, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<MyModel, String>(properties: const [property], builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners(property);
      await tester.pump();
    });

    testWidgets('provides model instance to builder', (tester) async {
      final model = MyModel();
      final listener = expectAsync3((context, _model, property) {
        expect(model, _model);
        return Container();
      }, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<MyModel, String>(properties: const ['foo'], builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
    });

    testWidgets('provides changed property to builder', (tester) async {
      final model = MyModel();
      const property = 'foo';
      final multi = MultiExpectAsync3([
        expectAsync3((context, model, Set<String>? properties) {
          expect(properties, isEmpty);
          return Container();
        }),
        expectAsync3((context, model, Set<String>? properties) {
          expect(properties!.contains(property), isTrue);
          return Container();
        })
      ]);

      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<MyModel, String>(properties: const [property], builder: multi.listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners(property);
      await tester.pump();
    });
  });
}

class MyModel extends PropertyChangeNotifier<String> { }

/// Convenience class for invoking multiple [expectAsync3] sequentially.
class MultiExpectAsync3<T, A, B, C> {
  final List<Func3<T, A, B, C>> _listeners;
  int _invocation = 0;

  MultiExpectAsync3(this._listeners) : assert(_listeners.isNotEmpty);

  Func3<T, A, B, C> get listener {
    return expectAsync3((context, model, properties) {
      return _listeners[_invocation++](context, model, properties);
    }, count: _listeners.length);
  }
}
