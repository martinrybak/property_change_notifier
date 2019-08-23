import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          body: MyInherited(
        child: Foo(),
      )),
    );
  }
}

class Foo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Bar());
  }
}

class Bar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = MyInherited.of(context, 'a');
    return RaisedButton(
      child: Text(model.myField),
      onPressed: () {
        model.onMyFieldChange(DateTime.now().toIso8601String());
      },
    );
  }
}

class MyInherited extends StatefulWidget {
  static MyInheritedData of(BuildContext context, String aspect) {
    return InheritedModel.inheritFrom<MyInheritedData>(context, aspect: aspect);
  }

  const MyInherited({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _MyInheritedState createState() => _MyInheritedState();
}

class _MyInheritedState extends State<MyInherited> {
  String myField = 'foo';

  void onMyFieldChange(String newValue) {
    setState(() {
      myField = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyInheritedData(
      myField: myField,
      onMyFieldChange: onMyFieldChange,
      child: widget.child,
    );
  }
}

class MyInheritedData extends InheritedModel<String> {
  final String myField;
  final ValueChanged<String> onMyFieldChange;

  MyInheritedData({
    Key key,
    this.myField,
    this.onMyFieldChange,
    Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(MyInheritedData oldWidget) {
    return oldWidget.myField != myField || oldWidget.onMyFieldChange != onMyFieldChange;
  }

  @override
  bool updateShouldNotifyDependent(MyInheritedData oldWidget, Set<String> aspects) {
    return aspects.contains('a');
  }
}
