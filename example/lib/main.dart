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
        body: MyInherited(
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
        BarListener(),
        BazListener(),
      ],
    ));
  }
}

class BarListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = MyInherited.of(context, 'bar');
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
    final model = MyInherited.of(context, 'baz');
    return RaisedButton(
      child: Text(model.baz),
      onPressed: () {
        model.baz = DateTime.now().toIso8601String();
      },
    );
  }
}

class MyInherited extends StatefulWidget {
  static Model of(BuildContext context, String aspect) {
    return InheritedModel.inheritFrom<MyInheritedData>(context, aspect: aspect).model;
  }

  const MyInherited({Key key, this.model, this.child}) : super(key: key);

  final Widget child;
  final PropertyChangeNotifier<String> model;

  @override
  _MyInheritedState createState() => _MyInheritedState();
}

class _MyInheritedState extends State<MyInherited> {
  String _changedProperty = 'foo';

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
    return MyInheritedData(
      model: widget.model,
      changedProperty: _changedProperty,
      child: widget.child,
    );
  }

  void _listener([String property]) {
    setState(() {
      _changedProperty = property;
    });
  }
}

class MyInheritedData extends InheritedModel<String> {
  final Model model;
  final String changedProperty;

  MyInheritedData({
    Key key,
    this.model,
    this.changedProperty,
    Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(MyInheritedData oldWidget) {
    return true;
//    return oldWidget.model != this.model;
  }

  @override
  bool updateShouldNotifyDependent(MyInheritedData oldWidget, Set<String> aspects) {
    return aspects.contains(this.changedProperty);
  }
}
