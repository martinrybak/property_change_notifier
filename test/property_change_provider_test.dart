import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_change_notifier/src/property_change_notifier.dart';
import 'package:property_change_notifier/src/property_change_provider.dart';

void main() {
  group('Ancestor tests', () {
    testWidgets('throws assertion error if ancestor not found', (tester) async {
      final widget = Builder(
        builder: (context) {
          PropertyChangeProvider.of<MyModel, String>(context);
          return Container();
        },
      );

      await tester.pumpWidget(widget);
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('listens to first ancestor provider of same type', (tester) async {
      final outerModel = MyModel();
      final innerModel = MyModel();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: outerModel,
        child: PropertyChangeProvider<MyModel, String>(
          value: innerModel,
          child: Builder(
            builder: (context) {
              PropertyChangeProvider.of<MyModel, String>(context);
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
      final outerModel = MyModel();
      final innerModel = MyModel();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: outerModel,
        child: PropertyChangeProvider<MyModel, String>(
          value: innerModel,
          child: Builder(
            builder: (context) {
              PropertyChangeProvider.of<MyModel, String>(context);
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
      final innerModel = OtherModel();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: outerModel,
        child: PropertyChangeProvider<OtherModel, String>(
          value: innerModel,
          child: Builder(
            builder: (context) {
              PropertyChangeProvider.of<MyModel, String>(context);
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
      final innerModel = OtherModel();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: outerModel,
        child: PropertyChangeProvider<OtherModel, String>(
          value: innerModel,
          child: Builder(
            builder: (context) {
              PropertyChangeProvider.of<MyModel, String>(context);
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
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: BuildDetector(listener),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('does not rebuild when notifyListeners() is called with a property', (tester) async {
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
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
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context, properties: []);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('rebuilds when notifyListeners() is called with no property', (tester) async {
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('rebuilds when notifyListeners() is called with a property', (tester) async {
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners('foo');
      await tester.pump();
    });

    testWidgets('does not rebuild when listen is false and notifyListeners() is called with no property', (tester) async {
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context, listen: false);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('does not rebuild when listen is false and notifyListeners() is called with a property', (tester) async {
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context, listen: false);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners('foo');
      await tester.pump();
    });

    testWidgets('can access model', (tester) async {
      final model = MyModel();
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<MyModel, String>(context)!;
            expect(provider.value, model);
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
    });

    testWidgets('can access model when listen is false', (tester) async {
      final model = MyModel();
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<MyModel, String>(context, listen: false)!;
            expect(provider.value, model);
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
    });

    testWidgets('can access changed properties when notifyListeners() called with a property', (tester) async {
      final model = MyModel();
      const property = 'foo';
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<MyModel, String>(context)!;
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
      final model = MyModel();
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context, properties: ['foo'], listen: false);
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('does not rebuild when notifyListeners() is called without a property', (tester) async {
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context, properties: ['foo']);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners();
      await tester.pump();
    });

    testWidgets('does not rebuild when notifyListeners() is called with a non-matching property', (tester) async {
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 1);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context, properties: ['foo']);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners('bar');
      await tester.pump();
    });

    testWidgets('rebuilds when notifyListeners() is called with a matching property', (tester) async {
      final model = MyModel();
      const property = 'foo';
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context, properties: [property]);
            return BuildDetector(listener);
          },
        ),
      );

      await tester.pumpWidget(widget);
      model.notifyListeners(property);
      await tester.pump();
    });

    testWidgets('rebuilds when notifyListeners() is called multiple times with the first property matching', (tester) async {
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context, properties: ['foo']);
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
      final model = MyModel();
      final listener = expectAsync0(() {}, count: 2);
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            PropertyChangeProvider.of<MyModel, String>(context, properties: ['bar']);
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
      final model = MyModel();
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<MyModel, String>(context, properties: ['foo'])!;
            expect(provider.value, model);
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
    });

    testWidgets('can access changed property when notifyListeners() called with a matching property', (tester) async {
      final model = MyModel();
      const property = 'foo';
      final widget = PropertyChangeProvider<MyModel, String>(
        value: model,
        child: Builder(
          builder: (context) {
            final provider = PropertyChangeProvider.of<MyModel, String>(context, properties: [property])!;
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
class OtherModel extends PropertyChangeNotifier<String> {}

/// Helper widget to detect when build() is called.
class BuildDetector extends StatelessWidget {
  final Function() onBuild;

  const BuildDetector(this.onBuild, [Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Container();
  }
}
