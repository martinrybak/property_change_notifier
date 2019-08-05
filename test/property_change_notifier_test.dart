import 'package:flutter_test/flutter_test.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

void main() {
  group('hasListeners', () {
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
      final model = PropertyChangeNotifier();
      final listener = () {};
      model.addListener(listener, ['foo']);
      model.removeListener(listener, ['foo']);
      expect(model.hasListeners, isFalse);
    });
  });

  group('addListener()', () {
    test('null listener throws assertion', () {
      final model = PropertyChangeNotifier();
      expect(() => model.addListener(null), throwsAssertionError);
    });

    test('adding same listener with same properties throws exception', () {
      final model = PropertyChangeNotifier();
      final listener = () {};
      expect(() {
        model.addListener(listener, ['foo']);
        model.addListener(listener, ['foo']);
      }, throwsException);
    });

    test('adding same listener with different properties returns normally', () {
      final model = PropertyChangeNotifier();
      final listener = () {};
      expect(() {
        model.addListener(listener, ['foo']);
        model.addListener(listener, ['bar']);
      }, returnsNormally);
    });
  });

  group('removeListener()', () {
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
  });

  group('notifyListeners()', () {
    test('invoking with List throws assertion', () {
      final model = PropertyChangeNotifier();
      model.notifyListeners();
      expect(() => model.notifyListeners([]), throwsAssertionError);
    });

    group('listener with no properties', () {
      test('is invoked once when notifyListeners() is invoked with no properties', () {
        final model = PropertyChangeNotifier();
        final listener = expectAsync0(() {}, count: 1);
        model.addListener(listener);
        model.notifyListeners();
      });

      test('is invoked once when notifyListeners() is invoked with a property', () {
        final model = PropertyChangeNotifier();
        final listener = expectAsync0(() {}, count: 1);
        model.addListener(listener);
        model.notifyListeners('foo');
      });
    });

    group('listener with one property', () {
      test('is not invoked once when notifyListeners() is invoked with no properties', () {
        final model = PropertyChangeNotifier();
        final listener = expectAsync0(() {}, count: 0);
        model.addListener(listener, ['foo']);
        model.notifyListeners();
      });

      test('is invoked once when notifyListeners() is invoked with same property', () {
        final model = PropertyChangeNotifier();
        final listener = expectAsync0(() {}, count: 1);
        model.addListener(listener, ['foo']);
        model.notifyListeners('foo');
      });

      test('is not invoked when notifyListeners() is invoked with different property', () {
        final model = PropertyChangeNotifier();
        final listener = expectAsync0(() {}, count: 0);
        model.addListener(listener, ['foo']);
        model.notifyListeners('bar');
      });
    });

    group('listener with multiple properties', () {
      test('is not invoked once when notifyListeners() is invoked with no properties', () {
        final model = PropertyChangeNotifier();
        final listener = expectAsync0(() {}, count: 0);
        model.addListener(listener, ['foo', 'bar']);
        model.notifyListeners();
      });

      test('is invoked once when notifyListeners() is invoked with matching property', () {
        final model = PropertyChangeNotifier();
        final listener = expectAsync0(() {}, count: 1);
        model.addListener(listener, ['foo', 'bar']);
        model.notifyListeners('foo');
      });

      test('is not invoked when notifyListeners() is invoked with different property', () {
        final model = PropertyChangeNotifier();
        final listener = expectAsync0(() {}, count: 0);
        model.addListener(listener, ['foo', 'bar']);
        model.notifyListeners('baz');
      });
    });
  });
}
