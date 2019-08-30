import 'package:flutter/widgets.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class PropertyChangeProvider<T extends PropertyChangeNotifier> extends StatefulWidget {
  static Type _typeOf<T>() => T;

  static PropertyChangeModel<T> of<T extends PropertyChangeNotifier>(
    BuildContext context, {
    Iterable<Object> properties,
    bool listen = true,
  }) {
    assert(listen || properties == null, "Don't provide properties if you're not going to listen to them.");

    final nullCheck = (InheritedModel model) {
      assert(model != null, 'Could not find an ancestor PropertyChangeProvider<$T>');
      return model;
    };

    if (!listen) {
      final type = _typeOf<PropertyChangeModel<T>>();
      return nullCheck(context.ancestorWidgetOfExactType(type) as PropertyChangeModel);
    }

    if (properties == null || properties.isEmpty) {
      return nullCheck(InheritedModel.inheritFrom<PropertyChangeModel<T>>(context));
    }

    for (final property in properties) {
      final widget = InheritedModel.inheritFrom<PropertyChangeModel<T>>(context, aspect: property);
      if (property == properties.last) {
        return nullCheck(widget);
      }
    }

    return nullCheck(null);
  }

  const PropertyChangeProvider({
    Key key,
    this.value,
    this.child,
  }) : super(key: key);

  final Widget child;
  final T value;

  @override
  _PropertyChangeProviderState createState() => _PropertyChangeProviderState<T>();
}

class _PropertyChangeProviderState<T extends PropertyChangeNotifier> extends State<PropertyChangeProvider<T>> {
  Object _property;

  @override
  void initState() {
    super.initState();
    widget.value.addListener(_listener);
  }

  @override
  void dispose() {
    widget.value.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PropertyChangeModel<T>(
      state: this,
      child: widget.child,
    );
  }

  void _listener(Object property) {
    setState(() {
      _property = property;
    });
  }
}

class PropertyChangeModel<T extends PropertyChangeNotifier> extends InheritedModel {
  final _PropertyChangeProviderState _state;

  PropertyChangeModel({
    Key key,
    _PropertyChangeProviderState state,
    Widget child,
  })  : _state = state,
        super(key: key, child: child);

  T get value => _state.widget.value;
  Object get property => _state._property;

  @override
  bool updateShouldNotify(PropertyChangeModel oldWidget) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(PropertyChangeModel<T> oldWidget, Set<Object> aspects) {
    return aspects.contains(_state._property);
  }
}

class PropertyChangeConsumer<T extends PropertyChangeNotifier> extends StatelessWidget {
  final bool listen;
  final Iterable<Object> properties;
  final Widget Function(BuildContext, T, Object) builder;

  PropertyChangeConsumer({
    Key key,
    this.properties,
    this.listen = true,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<T>(context, properties: this.properties, listen: this.listen);
    return this.builder(context, model.value, model.property);
  }
}
