import 'package:flutter/foundation.dart';

/// Signature of callbacks that have 1 argument and return no data.
typedef PropertyCallback<T> = void Function(T);

/// A backwards-compatible implementation of [ChangeNotifier] that allows
/// implementers to provide more granular information to listeners about what
/// specific property was changed. This lets listeners be much more efficient
/// when responding to model changes. Any number of listeners can subscribe to
/// any number of properties.
///
/// Like [ChangeNotifier], is optimized for small numbers (one or two) of listeners.
/// It is O(N) for adding and removing listeners and O(N²) for dispatching
/// notifications (where N is the number of listeners).
///
/// [T] is the type of the property name and is usually [String] but can
/// be an [Enum] or any type that subclasses [Object]. To work correctly,
/// [T] must implement `operator==` and `hashCode`.
class PropertyChangeNotifier<T extends Object> extends ChangeNotifier {
  var _globalListeners = ObserverList<Function>();
  var _propertyListeners = <T, ObserverList<Function>>{};

  /// Reimplemented from [ChangeNotifier].
  /// Clients should not depend on this value for their behavior, because having
  /// one listener's logic change when another listener happens to start or stop
  /// listening will lead to extremely hard-to-track bugs. Subclasses might use
  /// this information to determine whether to do any work when there are no
  /// listeners, however; for example, resuming a [Stream] when a listener is
  /// added and pausing it when a listener is removed.
  ///
  /// Typically this is used by overriding [addListener], checking if
  /// [hasListeners] is false before calling `super.addListener()`, and if so,
  /// starting whatever work is needed to determine when to call
  /// [notifyListeners]; and similarly, by overriding [removeListener], checking
  /// if [hasListeners] is false after calling `super.removeListener()`, and if
  /// so, stopping that same work.
  @override
  @protected
  @visibleForTesting
  bool get hasListeners {
    assert(_debugAssertNotDisposed());
    return _globalListeners.isNotEmpty || _propertyListeners.isNotEmpty;
  }

  /// Registers [listener] for the given [properties]. [listener] must not be null.
  /// If [properties] is null or empty, [listener] will be added as a global listener, meaning
  /// it will be invoked for all property changes. This is the default behavior of [ChangeNotifier].
  /// [listener] must either accept no parameters or a single [T] parameter. If [listener]
  /// accepts a [T] parameter, it will be invoked with the property name provided by [notifyListeners].
  /// The same [listener] can be added for multiple properties.
  /// Adding the same [listener] for the same property is a no-op.
  /// Adding a [listener] for a non-existent property will not fail, but is functionally pointless.
  @override
  void addListener(Function listener, [Iterable<T> properties]) {
    assert(_debugAssertNotDisposed());
    assert(listener != null);
    assert(listener is VoidCallback || listener is PropertyCallback<T>, 'Listener must be a Function() or Function(T)');

    // Register global listener only
    if (properties == null || properties.isEmpty) {
      _addListener(_globalListeners, listener);
      return;
    }

    // Register listener for every property
    for (final property in properties) {
      if (!_propertyListeners.containsKey(property)) {
        _propertyListeners[property] = ObserverList<Function>();
      }
      _addListener(_propertyListeners[property], listener);
    }
  }

  /// Removes [listener] for the given [properties]. [listener] must not be null.
  /// If [properties] is null or empty, [listener] will be removed as a global listener.
  /// Removing a listener will not affect any other properties [listeners] is registered for.
  /// Removing a non-existent listener is no-op.
  /// Removing a listener for a non-existent property will not fail.
  @override
  void removeListener(Function listener, [Iterable<T> properties]) {
    assert(_debugAssertNotDisposed());
    assert(listener != null);

    // Remove global listener only
    if (properties == null || properties.isEmpty) {
      _globalListeners.remove(listener);
      return;
    }

    // Remove listener for every property
    for (final property in properties) {
      // If no map entry exists for property, ignore
      if (!_propertyListeners.containsKey(property)) {
        continue;
      }

      // Remove listener
      final listeners = _propertyListeners[property];
      listeners.remove(listener);

      // Remove map entry if needed
      if (listeners.isEmpty) {
        _propertyListeners.remove(property);
      }
    }
  }

  /// Reimplemented from [ChangeNotifier].
  /// Discards any resources used by the object. After this is called, the
  /// object is not in a usable state and should be discarded (calls to
  /// [addListener] and [removeListener] will throw after the object is
  /// disposed).
  ///
  /// This method should only be called by the object's owner.
  @override
  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _globalListeners = null;
    _propertyListeners = null;
    super.dispose();
  }

  /// Notifies the appropriate listeners that [property] was changed.
  /// Implementers should ideally provide a [property] parameter.
  /// It is only optional for backwards compatibility with [ChangeNotifier].
  /// Global listeners will be notified every time, even if [property] is null.
  /// Listeners for specific properties will only be notified
  /// if [property] is equal (operator==) to one of those properties.
  /// If [property] is not null, must be a single instance of [T] (typically a [String]).
  @override
  @protected
  @visibleForTesting
  void notifyListeners([T property]) {
    assert(_debugAssertNotDisposed());
    assert(!(property is Iterable), 'notifyListeners() should only be called for one property at a time');

    // Always notify global listeners
    _notifyListeners(_globalListeners, property);

    // If no property provided, exit
    if (property == null) {
      return;
    }

    // If listeners exist for this property, notify them.
    if (_propertyListeners.containsKey(property)) {
      _notifyListeners(_propertyListeners[property], property);
    }
  }

  /// Adds [listener] to [listeners] only if is not already present.
  void _addListener(ObserverList<Function> listeners, Function listener) {
    if (!listeners.contains(listener)) {
      listeners.add(listener);
    }
  }

  /// Creates a local copy of [listeners] in case a callback calls
  /// [addListener] or [removeListener] while iterating through the list.
  /// Invokes each listener. If the listener accepts a property parameter, it will be provided.
  void _notifyListeners(ObserverList<Function> listeners, T property) {
    final localListeners = List<Function>.from(listeners);
    for (final listener in localListeners) {
      // One last check to make sure the listener hasn't been removed
      // from the original list since the time we made our local copy.
      if (listeners.contains(listener)) {
        if (listener is PropertyCallback<T>) {
          listener(property);
        } else {
          listener();
        }
      }
    }
  }

  /// Reimplemented from [ChangeNotifier].
  bool _debugAssertNotDisposed() {
    assert(() {
      if (_globalListeners == null || _propertyListeners == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }
}
