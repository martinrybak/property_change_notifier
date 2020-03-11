import 'package:flutter/widgets.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

typedef PropertyChangeBuilder<T> = Widget Function(BuildContext, T, Set<Object>);

/// A widget-based listener for cases where a [BuildContext] is hard to access, or if you prefer this kind of API.
/// To register the widget to be rebuilt only on specific property changes, provide a [properties] parameter.
///
/// Access both the model value and the changed properties via the [builder] callback:
/// ```dart
/// PropertyChangeConsumer<MyModel>(
///    properties: ['foo', 'bar'],
///    builder: (context, model, properties) {
///      return Column(
///        children: [
///          Text('$properties were changed!'),
///          RaisedButton(
///            child: Text('Update foo'),
///            onPressed: () {
///              model.foo = DateTime.now().toString();
///            },
///          ),
///          RaisedButton(
///            child: Text('Update bar'),
///            onPressed: () {
///              model.bar = DateTime.now().toString();
///            },
///          ),
///        ],
///      );
///    },
///  );
/// ```
class PropertyChangeConsumer<T extends PropertyChangeNotifier> extends StatelessWidget {
  final Iterable<Object> properties;
  final PropertyChangeBuilder<T> builder;

  const PropertyChangeConsumer({
    Key key,
    this.properties,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<T>(context, properties: this.properties, listen: true);
    return this.builder(context, model.value, model.properties);
  }
}
