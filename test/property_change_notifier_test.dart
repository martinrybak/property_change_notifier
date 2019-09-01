import 'package:flutter_test/flutter_test.dart';
import 'package:property_change_notifier/src/property_change_notifier.dart';

void main() {
  group('hasListeners', () {
    test('invoking after dispose() throws assertion', () {
      final model = PropertyChangeNotifier();
      model.dispose();
      expect(() => model.hasListeners, throwsAssertionError);
    });

    test('initially returns false', () {
      final model = PropertyChangeNotifier();
      expect(model.hasListeners, isFalse);
    });

    test('returns true after adding a listener with no properties', () {
      final model = PropertyChangeNotifier();
      model.addListener(() {});
      expect(model.hasListeners, isTrue);
    });

    test('returns true after adding a listener with properties', () {
      final model = PropertyChangeNotifier();
      model.addListener(() {}, ['foo']);
      expect(model.hasListeners, isTrue);
    });

    test('returns false after adding and removing same listener with no properties', () {
      final model = PropertyChangeNotifier();
      final listener = () {};
      model.addListener(listener);
      model.removeListener(listener);
      expect(model.hasListeners, isFalse);
    });

    test('returns false after adding and removing same listener with properties', () {
      final property = 'foo';
      final model = PropertyChangeNotifier();
      final listener = () {};
      model.addListener(listener, [property]);
      model.removeListener(listener, [property]);
      expect(model.hasListeners, isFalse);
    });
  });

  group('addListener()', () {
    test('invoking after dispose() throws assertion', () {
      final model = PropertyChangeNotifier();
      model.dispose();
      expect(() => model.addListener(null), throwsAssertionError);
    });

    test('null listener throws assertion', () {
      final model = PropertyChangeNotifier();
      expect(() => model.addListener(null), throwsAssertionError);
    });

    test('invalid listener throws assertion', () {
      final listener = (a,b){};
      final model = PropertyChangeNotifier();
      expect(() => model.addListener(listener), throwsAssertionError);
    });

    test('empty properties registers global listener', () {
      final listener = expectAsync0(() {}, count: 1);
      final model = PropertyChangeNotifier();
      model.addListener(listener, []);
      model.notifyListeners();
    });

    test('same global listener twice returns normally', () {
      final listener = () {};
      final model = PropertyChangeNotifier();
      model.addListener(listener);
      expect(() => model.addListener(listener), returnsNormally);
    });

    test('same listener with properties twice returns normally', () {
      final property = 'foo';
      final listener = () {};
      final model = PropertyChangeNotifier();
      model.addListener(listener, [property]);
      expect(() => model.addListener(listener, [property]), returnsNormally);
    });
  });

  group('removeListener()', () {
    test('invoking after dispose() throws assertion', () {
      final model = PropertyChangeNotifier();
      model.dispose();
      expect(() => model.removeListener(null), throwsAssertionError);
    });

    test('null listener throws assertion', () {
      final model = PropertyChangeNotifier();
      expect(() => model.removeListener(null), throwsAssertionError);
    });

    test('non-existent listener with no properties returns normally', () {
      final model = PropertyChangeNotifier();
      expect(() => model.removeListener(() {}), returnsNormally);
    });

    test('non-existent listener with properties returns normally', () {
      final model = PropertyChangeNotifier();
      expect(() => model.removeListener(() {}, ['foo']), returnsNormally);
    });

    test('same global listener twice returns normally', () {
      final listener = () {};
      final model = PropertyChangeNotifier();
      model.addListener(listener);
      model.removeListener(listener);
      expect(() => model.removeListener(listener), returnsNormally);
    });

    test('same listener with properties twice returns normally', () {
      final property = 'foo';
      final listener = () {};
      final model = PropertyChangeNotifier();
      model.addListener(listener, [property]);
      model.removeListener(listener, [property]);
      model.removeListener(listener, [property]);
    });
  });

  group('notifyListeners()', () {
    test('invoking after dispose() throws assertion', () {
      final model = PropertyChangeNotifier();
      model.dispose();
      expect(() => model.notifyListeners(null), throwsAssertionError);
    });

    test('invoking with List throws assertion', () {
      final model = PropertyChangeNotifier();
      model.notifyListeners();
      expect(() => model.notifyListeners([]), throwsAssertionError);
    });

    test('removing listeners while invoking does not invoke removed listener', () {
      final model = PropertyChangeNotifier();
      final listener2 = expectAsync0(() {}, count: 0);
      final listener1 = expectAsync0(() {
        model.removeListener(listener2);
      }, count: 1);

      model.addListener(listener1);
      model.addListener(listener2);
      model.notifyListeners();
    });

    test('adding listeners while invoking does not invoke added listener', () {
      final model = PropertyChangeNotifier();
      final listener2 = expectAsync0(() {}, count: 0);
      final listener1 = expectAsync0(() {
        model.addListener(listener2);
      }, count: 1);

      model.addListener(listener1);
      model.notifyListeners();
    });

    test('same global listener is only invoked once', () {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      model.addListener(listener);
      model.addListener(listener);
      model.notifyListeners();
    });

    test('same listener with same properties is only invoked once', () {
      final property = 'foo';
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      model.addListener(listener, [property]);
      model.addListener(listener, [property]);
      model.notifyListeners(property);
    });

    test('same listener with different properties is invoked for each property', () {
      final property1 = 'foo';
      final property2 = 'bar';
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 2);
      model.addListener(listener, [property1]);
      model.addListener(listener, [property2]);
      model.notifyListeners(property1);
      model.notifyListeners(property2);
    });

    test('adding and removing same listener with different properties is invoked for remaining property only', () {
      final property1 = 'foo';
      final property2 = 'bar';
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      model.addListener(listener, [property1]);
      model.addListener(listener, [property2]);
      model.removeListener(listener, [property2]);
      model.notifyListeners(property1);
      model.notifyListeners(property2);
    });

    test('removed global listener is no longer invoked', () {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 0);
      model.addListener(listener);
      model.removeListener(listener);
      model.notifyListeners();
    });

    test('removed listener with properties is no longer invoked', () {
      final property = 'foo';
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 0);
      model.addListener(listener, [property]);
      model.removeListener(listener, [property]);
      model.notifyListeners(property);
    });

    group('global listener', () {
      group('with no property parameter', () {
        test('is invoked when notifyListeners() is invoked with no properties', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync0(() {}, count: 1);
          model.addListener(listener);
          model.notifyListeners();
        });

        test('is invoked when notifyListeners() is invoked with a property', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync0(() {}, count: 1);
          model.addListener(listener);
          model.notifyListeners('foo');
        });
      });

      group('with property parameter', () {
        test('is invoked with null property when notifyListeners() is invoked with no properties', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync1((_property) {
            expect(_property, isNull);
          }, count: 1);
          model.addListener(listener);
          model.notifyListeners();
        });

        test('is invoked with a property when notifyListeners() is invoked with a property', () {
          final property = 'foo';
          final model = PropertyChangeNotifier();
          final listener = expectAsync1((_property) {
            expect(_property, property);
          }, count: 1);
          model.addListener(listener);
          model.notifyListeners(property);
        });
      });
    });

    group('listener on one property', () {
      group('with no property parameter', () {
        test('is not invoked when notifyListeners() is invoked with no properties', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync0(() {}, count: 0);
          model.addListener(listener, ['foo']);
          model.notifyListeners();
        });

        test('is invoked when notifyListeners() is invoked with same property', () {
          final property = 'foo';
          final model = PropertyChangeNotifier();
          final listener = expectAsync0(() {}, count: 1);
          model.addListener(listener, [property]);
          model.notifyListeners(property);
        });

        test('is not invoked when notifyListeners() is invoked with different property', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync0(() {}, count: 0);
          model.addListener(listener, ['foo']);
          model.notifyListeners('bar');
        });
      });

      group('with no property parameter', () {
        test('is not invoked when notifyListeners() is invoked with no properties', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync1((_) {}, count: 0);
          model.addListener(listener, ['foo']);
          model.notifyListeners();
        });

        test('is invoked with property name when notifyListeners() is invoked with same property', () {
          final model = PropertyChangeNotifier();
          final property = 'foo';
          final listener = expectAsync1((_property) {
            expect(_property, _property);
          }, count: 1);
          model.addListener(listener, [property]);
          model.notifyListeners(property);
        });

        test('is not invoked when notifyListeners() is invoked with different property', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync1((_) {}, count: 0);
          model.addListener(listener, ['foo']);
          model.notifyListeners('bar');
        });
      });
    });

    group('listener on multiple properties', () {
      group('with no property parameter', () {
        test('is not invoked when notifyListeners() is invoked with no properties', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync0(() {}, count: 0);
          model.addListener(listener, ['foo', 'bar']);
          model.notifyListeners();
        });

        test('is invoked when notifyListeners() is invoked with matching property', () {
          final property = 'foo';
          final model = PropertyChangeNotifier();
          final listener = expectAsync0(() {}, count: 1);
          model.addListener(listener, [property, 'bar']);
          model.notifyListeners(property);
        });

        test('is not invoked when notifyListeners() is invoked with different property', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync0(() {}, count: 0);
          model.addListener(listener, ['foo', 'bar']);
          model.notifyListeners('baz');
        });
      });

      group('with property parameter', () {
        test('is not invoked when notifyListeners() is invoked with no properties', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync1((_) {}, count: 0);
          model.addListener(listener, ['foo', 'bar']);
          model.notifyListeners();
        });

        test('is invoked with property name when notifyListeners() is invoked with same property', () {
          final model = PropertyChangeNotifier();
          final property = 'foo';
          final listener = expectAsync1((_property) {
            expect(_property, _property);
          }, count: 1);
          model.addListener(listener, [property]);
          model.notifyListeners(property);
        });

        test('is invoked with property name when notifyListeners() is invoked with same property and other property',
            () {
          final model = PropertyChangeNotifier();
          final property = 'foo';
          final listener = expectAsync1((_property) {
            expect(_property, _property);
          }, count: 1);
          model.addListener(listener, [property, 'bar']);
          model.notifyListeners(property);
        });

        test('is not invoked when notifyListeners() is invoked with different property', () {
          final model = PropertyChangeNotifier();
          final listener = expectAsync1((_) {}, count: 0);
          model.addListener(listener, ['foo', 'bar']);
          model.notifyListeners('baz');
        });
      });
    });
  });
}
