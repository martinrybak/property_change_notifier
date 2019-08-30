import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:property_change_notifier/property_change_provider.dart';

void main() => runApp(MyApp());

class Model with PropertyChangeNotifier<String> {
  String _bar;
  String _baz;

  String get bar => _bar;
  String get baz => _baz;

  set bar(String value) {
    _bar = value;
    notifyListeners('bar');
  }

  set baz(String value) {
    _baz = value;
    notifyListeners('baz');
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _model = Model()
    ..bar = 'Bar'
    ..baz = 'Baz';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: PropertyChangeProvider(
          value: _model,
          child: Foo(),
        ),
      ),
    );
  }
}

class Foo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NotListener(),
        GlobalListener(),
        MultiListener(),
        BarListener(),
        BazListener(),
        ConsumerListener(),
      ],
    ));
  }
}

class NotListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<Model>(context, listen: false);
    return Text(DateTime.now().toIso8601String());
  }
}

class GlobalListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<Model>(context);
    return Text(DateTime.now().toIso8601String());
  }
}

class MultiListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<Model>(context, properties: ['bar', 'baz']);
    return Text('${model.property} was changed');
  }
}

class BarListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<Model>(context, properties: ['bar']).value;
    return RaisedButton(
      child: Text(model.bar),
      onPressed: () {
        model.bar = DateTime.now().toIso8601String();
      },
    );
  }
}

class BazListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<Model>(properties: ['baz'], builder: (context, model, property) {
      return RaisedButton(
        child: Text('$property was changed to ${model.baz}'),
        onPressed: () {
          model.baz = DateTime.now().toIso8601String();
        },
      );
    });
  }
}

class ConsumerListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<Model>(
      properties: ['foo', 'bar'],
      builder: (context, value, property) {
        return Column(
          children: [
            Text('$property was changed!'),
            RaisedButton(
              child: Text('Update bar'),
              onPressed: () {
                value.bar = DateTime.now().toString();
              },
            ),
            RaisedButton(
              child: Text('Update baz'),
              onPressed: () {
                value.baz = DateTime.now().toString();
              },
            ),
          ],
        );
      },
    );
  }
}
