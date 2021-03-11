import 'package:flutter/widgets.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

typedef PropertyChangeBuilder<T, S> = Widget Function(BuildContext, T?, Set<S>?);

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
class PropertyChangeConsumer<T extends PropertyChangeNotifier<S>, S extends Object> extends StatelessWidget {
  final Iterable<S>? properties;
  final PropertyChangeBuilder<T, S> builder;

  const PropertyChangeConsumer({
    Key? key,
    this.properties,
    required this.builder,
  })  : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = PropertyChangeProvider.of<T, S>(context, properties: properties, listen: true);
    return builder(context, model?.value, model?.properties);
  }
}
