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

  group('Ancestor tests', () {
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

    testWidgets('listens to first ancestor provider of same type', (tester) async {
      final outerModel = PropertyChangeNotifier();
      final innerModel = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider(
        value: outerModel,
        child: PropertyChangeProvider(
          value: innerModel,
          child: Builder(
            builder: (context) {
              PropertyChangeProvider.of<PropertyChangeNotifier>(context);
              return BuildDetector(listener);
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      innerModel.notifyListeners();
      await tester.pump();
    });

    testWidgets('does not listen to last ancestor provider of same type', (tester) async {
      final outerModel = PropertyChangeNotifier();
      final innerModel = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider(
        value: outerModel,
        child: PropertyChangeProvider(
          value: innerModel,
          child: Builder(
            builder: (context) {
              PropertyChangeProvider.of<PropertyChangeNotifier>(context);
              return BuildDetector(listener);
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      outerModel.notifyListeners();
      await tester.pump();
    });

    testWidgets('listens to first ancestor provider of correct type', (tester) async {
      final outerModel = MyModel();
      final innerModel = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider(
        value: outerModel,
        child: PropertyChangeProvider(
          value: innerModel,
          child: Builder(
            builder: (context) {
              PropertyChangeProvider.of<MyModel>(context);
              return BuildDetector(listener);
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      outerModel.notifyListeners();
      await tester.pump();
    });

    testWidgets('does not listen to first ancestor provider of wrong type', (tester) async {
      final outerModel = MyModel();
      final innerModel = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider(
        value: outerModel,
        child: PropertyChangeProvider(
          value: innerModel,
          child: Builder(
            builder: (context) {
              PropertyChangeProvider.of<MyModel>(context);
              return BuildDetector(listener);
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      innerModel.notifyListeners();
      await tester.pump();
    });
  });

  group('Non-dependent', () {
    testWidgets('does not rebuild when notifyListeners() is called with no property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
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

    testWidgets('can access changed properties when notifyListeners() called with a property', (tester) async {
      final model = PropertyChangeNotifier();
      final property = 'foo';
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<PropertyChangeNotifier>(context);
            if (provider.properties.isNotEmpty) expect(provider.properties.contains(property), isTrue);
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
    testWidgets('throws assertion error if listen is false', (tester) async {
      final model = PropertyChangeNotifier();
      final widget = PropertyChangeProvider(
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

    testWidgets('does not rebuild when notifyListeners() is called without a property', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
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

    testWidgets('rebuilds when notifyListeners() is called multiple times with the first property matching', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<PropertyChangeNotifier>(context, properties: ['foo']);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners('foo');
      model.notifyListeners('bar');
      await tester.pump();
    });

    testWidgets('rebuilds when notifyListeners() is called multiple times with the last property matching', (tester) async {
      final model = PropertyChangeNotifier();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<PropertyChangeNotifier>(context, properties: ['bar']);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners('foo');
      model.notifyListeners('bar');
      await tester.pump();
    });

    testWidgets('can access model', (tester) async {
      final model = PropertyChangeNotifier();
      final widget = PropertyChangeProvider(
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
      final widget = PropertyChangeProvider(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<PropertyChangeNotifier>(context, properties: [property]);
            if (provider.properties.isNotEmpty) expect(provider.properties.contains(property), isTrue);
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

class MyModel extends PropertyChangeNotifier<String> {}

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
