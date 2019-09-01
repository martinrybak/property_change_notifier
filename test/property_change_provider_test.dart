import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_change_notifier/src/property_change_notifier.dart';
import 'package:property_change_notifier/src/property_change_provider.dart';

void main() {
  group('Constructor', () {
    testWidgets('throws assertion error if value is null', (tester) async {
      final widget = Builder(builder: (context) {
        return PropertyChangeProvider(
          value: null,
          child: Container(),
        );
      });
      await tester.pumpWidget(widget);
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('throws assertion error if child is null', (tester) async {
      final widget = Builder(builder: (context) {
        return PropertyChangeProvider(
          value: PropertyChangeNotifier(),
          child: null,
        );
      });
      await tester.pumpWidget(widget);
      expect(tester.takeException(), isAssertionError);
    });
  });

  testWidgets('throws assertion error if listen is false but properties provided', (tester) async {
    final model = PropertyChangeNotifier();
    final widget = PropertyChangeProvider<PropertyChangeNotifier>(
      value: model,
      child: Builder(
        builder: (context) {
          PropertyChangeProvider.of<PropertyChangeNotifier>(context, properties: ['foo'], listen: false);
          return Container();
        },
      ),
    );

    await tester.pumpWidget(widget);
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('throws assertion error if ancestor not found', (tester) async {
    final widget = Builder(
      builder: (context) {
        PropertyChangeProvider.of<PropertyChangeNotifier>(context);
        return Container();
      },
    );

    await tester.pumpWidget(widget);
    expect(tester.takeException(), isAssertionError);
  });

  group('Non-dependent', () {
    testWidgets('does not rebuild when notifyListeners() is called with no property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: BuildDetector(listener),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('does not rebuild when notifyListeners() is called with a property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: BuildDetector(listener),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners('foo');
      await tester.pump();
    });
  });

  group('Dependent without properties', () {
    testWidgets('empty properties rebuilds when empty notifyListeners() is called', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<PropertyChangeNotifier>(context, properties: []);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('rebuilds when notifyListeners() is called with no property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<PropertyChangeNotifier>(context);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('rebuilds when notifyListeners() is called with a property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<PropertyChangeNotifier>(context);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners('foo');
      await tester.pump();
    });

    testWidgets('does not rebuild when listen is false and notifyListeners() is called with no property',
        (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<PropertyChangeNotifier>(context, listen: false);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('does not rebuild when listen is false and notifyListeners() is called with a property',
        (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<PropertyChangeNotifier>(context, listen: false);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners('foo');
      await tester.pump();
    });

    testWidgets('can access model', (tester) async {
      final model = PropertyChangeNotifier();
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<PropertyChangeNotifier>(context);
            expect(provider.value, model);
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
    });

    testWidgets('can access model when listen is false', (tester) async {
      final model = PropertyChangeNotifier();
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<PropertyChangeNotifier>(context, listen: false);
            expect(provider.value, model);
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
    });

    testWidgets('can access changed property when notifyListeners() called with a property', (tester) async {
      final model = PropertyChangeNotifier();
      final property = 'foo';
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<PropertyChangeNotifier>(context);
            if (provider.property != null) expect(provider.property, property);
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners(property);
      await tester.pump();
    });
  });

  group('Dependent with properties', () {
    testWidgets('does not rebuild when notifyListeners() is called without a property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<PropertyChangeNotifier>(context, properties: ['foo']);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('does not rebuild when notifyListeners() is called with a non-matching property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<PropertyChangeNotifier>(context, properties: ['foo']);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners('bar');
      await tester.pump();
    });

    testWidgets('rebuilds when notifyListeners() is called with a matching property', (tester) async {
      final model = PropertyChangeNotifier();
      final property = 'foo';
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<PropertyChangeNotifier>(context, properties: [property]);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners(property);
      await tester.pump();
    });

    testWidgets('can access model', (tester) async {
      final model = PropertyChangeNotifier();
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<PropertyChangeNotifier>(context, properties: ['foo']);
            expect(provider.value, model);
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
    });

    testWidgets('can access changed property when notifyListeners() called with a matching property', (tester) async {
      final model = PropertyChangeNotifier();
      final property = 'foo';
      final widget = PropertyChangeProvider<PropertyChangeNotifier>(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<PropertyChangeNotifier>(context, properties: [property]);
            if (provider.property != null) expect(provider.property, property);
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners(property);
      await tester.pump();
    });
  });
}

/// Helper widget to detect when build() is called.
class BuildDetector extends StatelessWidget {
  final Function() onBuild;

  BuildDetector(this.onBuild);

  @override
  Widget build(BuildContext context) {
    this.onBuild();
    return Container();
  }
}
