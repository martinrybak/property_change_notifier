import 'package:flutter/widgets.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

/// An [InheritedWidget] that provides access to a [PropertyChangeNotifier] to descendant widgets.
/// The type parameter [T] is the type of the [PropertyChangeNotifier<S>] subclass.
/// The type parameter [S] is the type of the properties to observe.
///
/// Given the following model:
/// ```dart
/// class MyModel extends PropertyChangeNotifier<String> {...}
/// ```
///
/// A descendant widget can access the model instance by using the following syntax.
/// This will automatically register the widget to be rebuilt whenever any property changes on the model:
/// ```dart
/// final model = PropertyChangeProvider.of<MyModel, String>(context).value;
/// ```
///
/// To access the properties that were changed in the current build frame, use the following syntax.
/// ```dart
/// final properties = PropertyChangeProvider.of<MyModel, String>(context).properties;
/// ```
///
/// To register the widget to be rebuilt only on specific property changes, provide a [properties] parameter:
/// ```dart
/// final model = PropertyChangeProvider.of<MyModel, String>(context, properties: ['foo', 'bar']).value;
/// ```
///
/// To only access the model without registering the widget to be rebuilt, provide a [listen] parameter with a value of false:
/// ```dart
/// final model = PropertyChangeProvider.of<MyModel, String>(context, listen: false).value;
/// ```
class PropertyChangeProvider<T extends PropertyChangeNotifier<S>, S extends Object> extends StatefulWidget {
  /// Retrieves the [PropertyChangeModel] from the nearest ancestor [PropertyChangeProvider].
  /// If [listen] is true (which is the default), the calling widget will also be rebuilt
  /// whenever the ancestor's [PropertyChangeNotifier] model changes. To only rebuild
  /// for certain properties, provide them in the [properties] parameter.
  /// If [listen] is false, the [properties] parameter must be null or empty.
  static PropertyChangeModel<T, S>? of<T extends PropertyChangeNotifier<S>, S extends Object>(
    BuildContext context, {
    Iterable<S>? properties,
    bool listen = true,
  }) {
    assert(listen || properties == null, "Don't provide properties if you're not going to listen to them.");

    PropertyChangeModel<T, S>? nullCheck(PropertyChangeModel<T, S>? model) {
      assert(model != null, 'Could not find an ancestor PropertyChangeProvider<$T, $S>');
      return model;
    }

    if (!listen) {
      return nullCheck(context.findAncestorWidgetOfExactType<PropertyChangeModel<T, S>>());
    }

    if (properties == null || properties.isEmpty) {
      return nullCheck(context.dependOnInheritedWidgetOfExactType<PropertyChangeModel<T, S>>());
    }

    PropertyChangeModel<T, S>? widget;
    for (final property in properties) {
      widget = InheritedModel.inheritFrom<PropertyChangeModel<T, S>>(context, aspect: property);
    }

    return nullCheck(widget);
  }

  /// Creates a [PropertyChangeProvider] that can be accessed by descendant widgets.
  const PropertyChangeProvider({
    super.key,
    required this.value,
    required this.child,
  });

  /// The instance of [T] to provide to descendant widgets.
  final T value;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  PropertyChangeProviderState createState() => PropertyChangeProviderState<T, S>();
}

/// A convenience typedef to use in the common use case where property names are of type [String].
typedef StringPropertyChangeProvider<T extends PropertyChangeNotifier<String>> = PropertyChangeProvider<T, String>;

/// The companion [State] object to [PropertyChangeProvider]. For private use only.
/// Subscribes as a global listener to the [PropertyChangeNotifier] instance at [widget].[value].
/// Rebuilds whenever a property is changed and creates a new [PropertyChangeModel] with a reference
/// to itself so it can access the original model instance and changed property names.
class PropertyChangeProviderState<T extends PropertyChangeNotifier<S>, S extends Object> extends State<PropertyChangeProvider<T, S>> {
  Set<S> _properties = {};

  @override
  void initState() {
    super.initState();
    widget.value.addListener(_listener);
  }

  @override
  void didUpdateWidget(covariant PropertyChangeProvider<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      oldWidget.value.removeListener(_listener);
      widget.value.addListener(_listener);
    }
  }

  @override
  void dispose() {
    widget.value.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PropertyChangeModel<T, S>(
      state: this,
      child: widget.child,
    );
  }

  void _listener(S? property) {
    setState(() {
      _addProperty(property);
    });
  }

  void _addProperty(S? property) {
    if (property == null) return;
    final element = context as StatefulElement;
    if (element.dirty) {
      _properties.add(property);
    } else {
      _properties = {property};
    }
  }
}

/// The [InheritedModel] subclass that is rebuilt by [_PropertyChangeProviderState]
/// whenever its [PropertyChangeNotifier] is updated. Notifies dependents when the
/// names of the changed properties intersect with the list of properties provided
/// to the [PropertyChangeProvider].[of] method.
/// The type parameter [T] is the type of the [PropertyChangeNotifier<S>] subclass.
/// The type parameter [S] is the type of the properties to observe.
class PropertyChangeModel<T extends PropertyChangeNotifier<S>, S extends Object> extends InheritedModel<S> {
  final PropertyChangeProviderState<T, S> _state;

  const PropertyChangeModel({
    super.key,
    required PropertyChangeProviderState<T, S> state,
    required super.child,
  })  : _state = state;

  /// The instance of [T] originally provided to the [PropertyChangeProvider] constructor.
  T get value => _state.widget.value;

  /// The names of the properties on the [value] instance that were changed in the current build frame.
  Set<S> get properties => _state._properties;

  @override
  bool updateShouldNotify(PropertyChangeModel oldWidget) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(PropertyChangeModel<T, S> oldWidget, Set<S> dependencies) {
    return dependencies.intersection(_state._properties).isNotEmpty;
  }
}
