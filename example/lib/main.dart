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
  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<MyModel>(
      builder: (context, model, properties) {
        if (properties.isEmpty) return Container();
        return Text('$properties changed');
      },
    );
  }
}

class FooListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<MyModel>(
      properties: ['foo'],
      builder: (context, model, properties) {
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
      builder: (context, model, properties) {
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

class BothUpdater extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<MyModel>(context, listen: false).value;
    return RaisedButton(
        child: Text('Update both'),
        onPressed: () {
          model.foo++;
          model.bar++;
        }
    );
  }
}
