import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

void main() {
  testWidgets('throws assertion error if child is null', (tester) async {
    final widget = Builder(builder: (context) {
      return PropertyChangeConsumer<PropertyChangeNotifier>(builder: null);
    });
    await tester.pumpWidget(widget);
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('throws assertion error if ancestor PropertyChangeProvider not found', (tester) async {
    final widget = Builder(builder: (context) {
      return PropertyChangeConsumer<PropertyChangeNotifier>(builder: (context, model, properties) {
        return Container();
      });
    });
    await tester.pumpWidget(widget);
    expect(tester.takeException(), isAssertionError);
  });

  group('consumer without properties', () {
    testWidgets('is rebuilt when notifyListeners() is called without a property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync3((context, model, properties) {
        return Container();
      }, count: 2);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<PropertyChangeNotifier>(builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('is rebuilt when notifyListeners() is called with a property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync3((context, model, properties) {
        return Container();
      }, count: 2);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<PropertyChangeNotifier>(builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners('foo');
      await tester.pump();
    });

    testWidgets('provides model instance to builder', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync3((context, _model, property) {
        expect(model, _model);
        return Container();
      }, count: 1);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<PropertyChangeNotifier>(builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
    });

    testWidgets('provides changed property to builder', (tester) async {
      final model = PropertyChangeNotifier();
      final property = 'foo';
      final listener = expectAsync3((context, model, properties) {
        if (properties.isNotEmpty) expect(properties.contains(property), isTrue);
        return Container();
      }, count: 2);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<PropertyChangeNotifier>(builder: listener);
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
      final model = PropertyChangeNotifier();
      final listener = expectAsync3((context, model, properties) {
        return Container();
      }, count: 1);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<PropertyChangeNotifier>(properties: ['foo'], builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('is not rebuilt when notifyListeners() is called with a non-matching property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync3((context, model, properties) {
        return Container();
      }, count: 1);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<PropertyChangeNotifier>(properties: ['foo'], builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners('bar');
      await tester.pump();
    });

    testWidgets('is rebuilt when notifyListeners() is called with a matching property', (tester) async {
      final model = PropertyChangeNotifier();
      final property = 'foo';
      final listener = expectAsync3((context, model, properties) {
        return Container();
      }, count: 2);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<PropertyChangeNotifier>(properties: [property], builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners(property);
      await tester.pump();
    });

    testWidgets('provides model instance to builder', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync3((context, _model, property) {
        expect(model, _model);
        return Container();
      }, count: 1);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<PropertyChangeNotifier>(properties: ['foo'], builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
    });

    testWidgets('provides changed property to builder', (tester) async {
      final model = PropertyChangeNotifier();
      final property = 'foo';
      final listener = expectAsync3((context, model, properties) {
        if (properties.isNotEmpty) expect(properties.contains(property), isTrue);
        return Container();
      }, count: 2);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            return PropertyChangeConsumer<PropertyChangeNotifier>(properties: [property], builder: listener);
          },
        ),
      );
      await tester.pumpWidget(widget);
      model.notifyListeners(property);
      await tester.pump();
    });
  });
}
