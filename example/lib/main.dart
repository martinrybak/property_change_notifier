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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final model = MyModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Change Notifier',
      home: Scaffold(
        body: PropertyChangeProvider(
          value: model,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlobalListener(),
                FooListener(),
                BarListener(),
                FooUpdater(),
                BarUpdater(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlobalListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<MyModel>(
      builder: (context, model, property) {
        if (property == null) return Container();
        return Text('$property changed');
      },
    );
  }
}

class FooListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<MyModel>(
      properties: ['foo'],
      builder: (context, model, property) {
        return Text('Foo is ${model.foo}');
      },
    );
  }
}

class BarListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<MyModel>(
      properties: ['bar'],
      builder: (context, model, property) {
        return Text('Bar is ${model.bar}');
      },
    );
  }
}

class FooUpdater extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<MyModel>(context, listen: false).value;
    return RaisedButton(
      child: Text('Update foo'),
      onPressed: () => model.foo++
    );
  }
}

class BarUpdater extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<MyModel>(context, listen: false).value;
    return RaisedButton(
      child: Text('Update bar'),
      onPressed: () => model.bar++
    );
  }
}
