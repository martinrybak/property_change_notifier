# property_change_notifier

A drop-in replacement for [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) that lets listeners observe only certain properties of a model.

![](screenshot.png)

## Why?

[ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) is useful for observing changes to a model. The problem is that it takes an all-or-none approach. There is no way to listen only to specific properties. To do so requires every property to be implemented as a [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) or similar. Even then, it is not possible to listen to multiple properties with a single listener. The [Observable](https://medium.com/r/?url=https%3A%2F%2Fpub.dev%2Fpackages%2Fobservable) package has some powerful tools but they are not backwards-compatible with [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html).

`PropertyChangeNotifier` is an implementation of a more granular observer pattern similar to [PropertyChangeListener](https://docs.oracle.com/javase/7/docs/api/java/beans/PropertyChangeListener.html) in Java and [INotifyPropertyChanged](https://docs.microsoft.com/en-us/dotnet/api/system.componentmodel.inotifypropertychanged.propertychanged?view=netframework-4.8) in .NET. **When a property changes, the name of the property is included in the notification. Listeners can then choose to observe only one or many properties.**

## How?

`PropertyChangeNotifier` works by extending [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) in a way that makes it 100% backwards compatible with existing code.

1. Replace `ChangeNotifier` with `PropertyChangeNotifier` in your model.
1. Update your model to include the property name when calling `notifyListeners()`.
1. Existing listeners continue to receive all property updates just as before. Over time, update those listeners to only observe specific properties.

## Usage

### Model implementation

```
class MyModel with PropertyChangeNotifier<String> {
  String _foo;
  String _bar;

  String get foo => _foo;
  String get bar => _bar;

  set foo(String value) {
    _foo = value;
    notifyListeners('foo');
  }

  set bar(String value) {
    _bar = value;
    notifyListeners('bar');
  }
}
```

You can use `PropertyChangeNotifier` as a superclass or a mixin. `<String>` is the generic type of the property you provide to `notifyListeners()`. This is typically a `String` but can be any type.

### Listening to a single property
When creating a listener, provide an additional parameter containing the property name you wish to observe, wrapped in an [Iterable](https://api.dartlang.org/stable/2.4.0/dart-core/Iterable-class.html) (typically a [List](https://api.dartlang.org/stable/2.4.0/dart-core/List-class.html)):

```
final model = MyModel();
model.addListener(_listener, ['foo']);

void _listener() {
  print('foo was changed');
}

```

### Listening to multiple properties
Create a listener with an additional parameter containing the property names you wish to observe. The listener will be invoked when any of the given properties change. If the listener accepts a property parameter, it will be provided the name of the property that changed. 

```
final model = MyModel();
model.addListener(_listener, ['foo', 'bar']);

void _listener(String property) {
  print('$property was changed');
}

```

### Listening to all properties
This is the default behavior of `ChangeNotifier` and remains the same, even if you've update your model to invoke `notifyListeners()` with a property name. If the listener accepts a property parameter, it will be provided the name of the property that changed.

```
final model = MyModel();
model.addListener(_listenerOne);
model.addListener(_listenerTwo);

void _listenerOne() {
  print('model was changed');
}

void _listenerTwo(String property) {
  print('$property was changed');
}

```

### Adding listeners
Listeners can be added at any time. A listener cannot be `null`. Adding a listener with no parameters will cause it to listen to all properties. The same listener can be added to multiple properties. Adding the same listener again is a no-op. It doesn't hurt to add a listener to a non-existent property, but it serves no purpose; `PropertyChangeNotifier` has no way of knowing if the property actually exists. 

```
final model = MyModel();
model.addListener(_fooListener, ['foo']);
model.addListener(_bothListener, ['foo', 'bar']);
model.addListener(_allListener);

// _fooListener is listening to foo only.
// _bothListener is listening to foo and bar only.
// _allListener is listening to all properties.

```

### Removing listeners
Listeners can be removed at any time. A listener can be removed from one or more properties without being removed from other properties. Removing a listener that does not exist is a no-op.

```
final model = MyModel();
model.addListener(_listener, ['foo', 'bar', 'baz']);
model.removeListener(_listener, ['bar', 'baz']);

// _listener is now listening to foo only.

```

### String constants as property names

Referring to properties using [string literals](https://api.dartlang.org/stable/2.4.1/dart-core/String-class.html) is error-prone and leads to [stringly-typed](https://www.techopedia.com/definition/31876/stringly-typed) code. To avoid this, you can reference string constants in both your model and listeners so that they can be safely checked by the compiler:

```
// Properties
abstract class MyModelProperties {
  static String get foo => 'foo';
  static String get bar => 'bar';
}

// Model
class MyModel with PropertyChangeNotifier<String> {
  set foo(String value) {
    _foo = value;
    notifyListeners(MyModelProperties.foo);
  }
  …
}

// Listener
final model = MyModel();
model.addListener(_listener, [MyModelProperties.foo]);
```

### Enum values as property names

It might be more convenient to use enum values for property names. Remember to pass the property type as a generic argument to the `PropertyChangeNotifier` declaration.

```
// Properties
enum MyModelProperties {
  bar,
  baz,
}

// Model
class MyModel with PropertyChangeNotifier<MyModelProperties> {
  set foo(FooProperties value) {
    _foo = value;
    notifyListeners(MyModelProperties.foo);
  }
  …
}

// Listener
final model = MyModel();
model.addListener(_listener, [MyModelProperties.foo]);
```

You can even use your own custom types as property names. They just must extend [Object](https://api.dartlang.org/stable/2.4.0/dart-core/Object-class.html) and correctly implement equality using ``==`` and ``hashCode``. 

## Compilation Error

If you see the following error when compiling:

```
error: The class 'PropertyChangeNotifier' can't be used as a mixin because it extends a class other than Object.
```
The solution is to ignore the `mixin_inherits_from_not_object` static analyzer rule. You can do this by adding the following line above your model class declaration:

```
// ignore: mixin_inherits_from_not_object
class MyModel with PropertyChangeNotifier<String> {
...
}
```

Or you can add the following to your `analysis_options.yaml` file:

```
analyzer:
  errors:
    mixin_inherits_from_not_object: ignore
```    

## Unit Tests

This library has 100% [test coverage](coverage/index.html).