# property_change_notifier

A drop-in replacement for ChangeNotifier that lets listeners observe only certain properties of a model.

## Why?

[ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) is a useful technique for observing changes to a model. The problem is that takes an all-or-none approach. There is no way to listen only to specific properties. To do so requires every property to be implemented as a [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html), which is a lot of boilerplate. Even then, it is not possible to listen to multiple properties with a single listener.

`PropertyChangeNotifier` is an implementation of the observer pattern provided by [PropertyChangeListener](https://docs.oracle.com/javase/7/docs/api/java/beans/PropertyChangeListener.html) in Java and [INotifyPropertyChanged](https://docs.microsoft.com/en-us/dotnet/api/system.componentmodel.inotifypropertychanged.propertychanged?view=netframework-4.8) in .NET. When a property changes, the name of the property is included in the event. This gives the listener flexibility to handle the event for a particular property or ignore it.

## How?

`PropertyChangeNotifier` works by extending [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) in a way that makes it 100% backwards compatible with existing code. After replacing `ChangeNotifier` with `PropertyChangeNotifier` in your model, existing code still functions without any changes. However, models can now publish more granular information about property changes, and listeners have the ability to listen to only one or more property changes.

## Usage

### Implementation
Change your model to inherit from `PropertyChangeNotifier`. Wherever `notifyListeners()` is called, add a parameter containing the name of your property. This value is usually a [String](https://api.dartlang.org/stable/2.4.0/dart-core/String-class.html) but can be any Dart [Object](https://api.dartlang.org/stable/2.4.0/dart-core/Object-class.html). The object must correctly implement equality using ``==`` and ``hashCode``.

```
class Foo extends PropertyChangeNotifier {
  String _bar;
  String _baz;

  String get bar => _bar;
  String get baz => _baz;

  void set bar(String value) {
    _bar = value;
    notifyListeners('bar');
  }

  void set baz(String value) {
    _baz = value;
    notifyListeners('baz');
  }
}
```

### Listen to a single property only
Update existing listeners by passing in an additional parameter containing the property name you wish to observe, wrapped in a `List`:

```
final model = Foo();
model.addListener(_listener, ['bar']);

void _listener() {
  ...
}

```

### Listen to multiple properties
Create a listener with a callback and a `List` containing the property names you wish to observe:

```
final model = Foo();
model.addListener(_listener, ['bar', 'baz']);

void _listener() {
  ...
}

```

### Listen to all properties
This is the current behavior of `ChangeNotifier` and is not affected, even if your model calls `notifyListeners()` with a property name.

```
final model = Foo();
model.addListener(_listener);

void _listener() {
  ...
}

```

### Adding listeners
Listeners can be added at any time. A listener cannot be `null`. The same listener can be added to multiple properties. The same listener *cannot* be added multiple times to the same property. If you add a listener to a non-existent property, nothing happens. `PropertyChangeNotifier` does not check if the property actually exists. Adding a listener with no property listens to all properties.

```
final model = Foo();
model.addListener(_barListener, ['bar']);
model.addListener(_barBazListener, ['bar']);
model.addListener(_barBazListener, ['baz']);
model.addListener(_allListener);

```

### Removing listeners
Listeners can be removed at any time. A listener can be removed for one or more properties without being removed from other properties. Removing a listener on a property that does not exist is a no-op.

```
final model = Foo();
model.addListener(_listener, ['bar', 'baz', 'bah']);
model.removeListener(_listener, ['bar', 'bah']);
// _listener is now listening to baz only.

```

### Strongly Typed Properties

Referring to properties by strings is error-prone and results in stringly-typed code. To avoid this, you can use string constants:

```
class FooProperties {
  static String get bar => 'bar';
  static String get baz => 'baz';
}
```

Or you can use an enum:

```
enum FooProperties {
  bar,
  baz,
}
```

Now you can reference these values in your model and listeners so that they can be checked by your compiler:

```
// Model
class Foo extends PropertyChangeNotifier {
  ...
  void set bar(String value) {
    _bar = value;
    notifyListeners(FooProperties.bar);
  }
  ...
}

// Listener
final model = Foo();
model.addListener(_listener, [FooProperties.bar, FooProperties.baz]);
```

You can even use your own custom types as property names. They must extend [Object](https://api.dartlang.org/stable/2.4.0/dart-core/Object-class.html) and correctly implement equality using ``==`` and ``hashCode``.