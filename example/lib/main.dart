import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class MyModel with PropertyChangeNotifier<String> {
  int _foo = 0;
  int _bar = 0;

  int get foo => _foo;
  int get bar => _bar;

  set foo(int value) {
    _foo = value;
    notifyListeners('foo');
  }

  set bar(int value) {
    _bar = value;
    notifyListeners('bar');
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final model = MyModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Change Notifier',
      home: Scaffold(
        body: PropertyChangeProvider<MyModel, String>(
          value: model,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlobalListener(),
                FooListener(),
                BarListener(),
                FooUpdater(),
                BarUpdater(),
                BothUpdater(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlobalListener extends StatelessWidget {
  const GlobalListener({super.key});

  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<MyModel, String>(
      builder: (context, model, properties) {
        if (properties == null || properties.isEmpty) return Container();
        return Text('$properties changed');
      },
    );
  }
}

class FooListener extends StatelessWidget {
  const FooListener({super.key});

  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<MyModel, String>(
      properties: const ['foo'],
      builder: (context, model, properties) {
        return Text('Foo is ${model?.foo}');
      },
    );
  }
}

class BarListener extends StatelessWidget {
  const BarListener({super.key});

  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<MyModel, String>(
      properties: const ['bar'],
      builder: (context, model, properties) {
        return Text('Bar is ${model?.bar}');
      },
    );
  }
}

class FooUpdater extends StatelessWidget {
  const FooUpdater({super.key});

  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<MyModel, String>(context, listen: false)?.value;
    return TextButton(
        child: const Text('Update foo'),
        onPressed: () => model?.foo++
    );
  }
}

class BarUpdater extends StatelessWidget {
  const BarUpdater({super.key});

  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<MyModel, String>(context, listen: false)?.value;
    return TextButton(
        child: const Text('Update bar'),
        onPressed: () => model?.bar++
    );
  }
}

class BothUpdater extends StatelessWidget {
  const BothUpdater({super.key});

  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<MyModel, String>(context, listen: false)?.value;
    return TextButton(
        child: const Text('Update both'),
        onPressed: () {
          model?.foo++;
          model?.bar++;
        }
    );
  }
}
