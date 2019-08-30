import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:property_change_notifier/property_change_provider.dart';

void main() {
  group('Overall', () {
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
  });

  group('Global listener', () {
    testWidgets('rebuilds dependent when notifyListeners() is called without a property', (tester) async {
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

    testWidgets('rebuilds dependent when notifyListeners() is called with a property', (tester) async {
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

    testWidgets('does not rebuild dependent when listen is false', (tester) async {
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

    testWidgets('does not rebuild dependent when listen is false and notifyListeners() called with property', (tester) async {
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
  });

  group('Property listener', () {
    testWidgets('does not rebuild dependent when notifyListeners() is called without a property', (tester) async {
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

    testWidgets('does not rebuild dependent when notifyListeners() is called with a non-matching property', (tester) async {
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

    testWidgets('rebuilds dependent when notifyListeners() is called with a matching property', (tester) async {
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
