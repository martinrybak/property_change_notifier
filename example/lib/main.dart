import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

void main() => runApp(MyApp());

class Model extends PropertyChangeNotifier<String> {
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
        body: Observer<Model, String>(
          model: _model,
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
      ],
    ));
  }
}

class NotListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Observer.of<Model, String>(context, listen: false);
    return Text(DateTime.now().toIso8601String());
  }
}

class GlobalListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Observer.of<Model, String>(context);
    return Text(DateTime.now().toIso8601String());
  }
}

class MultiListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Observer.of<Model, String>(context, properties: ['bar', 'baz']);
    return Text(DateTime.now().toIso8601String());
  }
}

class BarListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Observer.of<Model, String>(context, properties: ['bar']);
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
    final model = Observer.of<Model, String>(context, properties: ['baz']);
    return RaisedButton(
      child: Text(model.baz),
      onPressed: () {
        model.baz = DateTime.now().toIso8601String();
      },
    );
  }
}

class Observer<T extends PropertyChangeNotifier<S>, S extends Object> extends StatefulWidget {
  static Type _typeOf<T>() => T;

  static T of<T extends PropertyChangeNotifier<S>, S extends Object>(BuildContext context, {Iterable<S> properties, bool listen = true}) {
    assert (listen || properties == null, "No need to provide properties if you're not going to listen to them.");

    if (!listen) {
      final type = _typeOf<ObservedModel<T, S>>();
      return (context.ancestorWidgetOfExactType(type) as ObservedModel).model;
    }

    if (properties == null) {
      return InheritedModel.inheritFrom<ObservedModel<T, S>>(context).model;
    }

    ObservedModel widget;
    for (final property in properties) {
      widget = InheritedModel.inheritFrom<ObservedModel<T, S>>(context, aspect: property);
    }
    return widget.model;
  }

  const Observer({Key key, this.model, this.child}) : super(key: key);

  final Widget child;
  final T model;

  @override
  _ObserverState createState() => _ObserverState<T, S>();
}

class _ObserverState<T extends PropertyChangeNotifier<S>, S extends Object> extends State<Observer> {
  S _changedProperty;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_listener);
  }

  @override
  void dispose() {
    widget.model.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ObservedModel<T, S>(
      model: widget.model,
      changedProperty: _changedProperty,
      child: widget.child,
    );
  }

  void _listener(S property) {
    setState(() {
      _changedProperty = property;
    });
  }
}

class ObservedModel<T extends PropertyChangeNotifier<S>, S extends Object> extends InheritedModel<String> {
  final T model;
  final S changedProperty;

  ObservedModel({
    Key key,
    this.model,
    this.changedProperty,
    Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(ObservedModel oldWidget) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(ObservedModel oldWidget, Set<String> aspects) {
    return aspects.contains(this.changedProperty);
  }
}
