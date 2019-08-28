import 'package:flutter/widgets.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class PropertyChangeProvider<T extends PropertyChangeNotifier> extends StatefulWidget {
  static Type _typeOf<T>() => T;

  static T of<T extends PropertyChangeNotifier<S>, S extends Object>(BuildContext context, {Iterable<S> properties, bool listen = true}) {
    assert (listen || properties == null, "No need to provide properties if you're not going to listen to them.");

    if (!listen) {
      final type = _typeOf<ObservedModel<T>>();
      return _getModel(context.ancestorWidgetOfExactType(type) as ObservedModel);
    }

    if (properties == null) {
      return _getModel(InheritedModel.inheritFrom<ObservedModel<T>>(context));
    }

    ObservedModel widget;
    for (final property in properties) {
      widget = InheritedModel.inheritFrom<ObservedModel<T>>(context, aspect: property);
    }
    return _getModel(widget);
  }

  static T _getModel<T extends PropertyChangeNotifier>(ObservedModel<T> model) {
    assert(model != null, 'Could not find an ancestor Observer<$T>');
    return model.model;
  }

  const PropertyChangeProvider({Key key, this.model, this.child}) : super(key: key);

  final Widget child;
  final T model;

  @override
  _PropertyChangeProviderState createState() => _PropertyChangeProviderState<T>();
}

class _PropertyChangeProviderState<T extends PropertyChangeNotifier> extends State<PropertyChangeProvider<T>> {
  Object _changedProperty;

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
    return ObservedModel<T>(
      model: widget.model,
      changedProperty: _changedProperty,
      child: widget.child,
    );
  }

  void _listener(Object property) {
    setState(() {
      _changedProperty = property;
    });
  }
}

class ObservedModel<T extends PropertyChangeNotifier> extends InheritedModel {
  final T model;
  final Object changedProperty;

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
  bool updateShouldNotifyDependent(ObservedModel<T> oldWidget, Set<Object> aspects) {
    return aspects.contains(this.changedProperty);
  }
}
