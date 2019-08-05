library property_change_notifier;

import 'package:flutter/foundation.dart';

/// To work correctly, [property] must implement `operator==` and `hashCode`.
class PropertyChangeNotifier<T extends Object> extends ChangeNotifier {
  var _propertyListeners = <dynamic, ObserverList<Function>>{};

  // Reimplemented from [ChangeNotifier].
  bool _debugAssertNotDisposed() {
    assert(() {
      if (_propertyListeners == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }

  @override
  @protected
  @visibleForTesting
  bool get hasListeners {
    assert(_debugAssertNotDisposed());
    return super.hasListeners || _propertyListeners.isNotEmpty;
  }

  @override
  void addListener(Function listener, [Iterable<T> properties]) {
    assert(_debugAssertNotDisposed());
    assert(listener != null);

    // If no properties provided, register global listener only
    if (properties == null) {
      super.addListener(listener);
      return;
    }

    for (final property in properties) {
      // If property has no listeners yet; create map entry
      if (!_propertyListeners.containsKey(property)) {
        _propertyListeners[property] = ObserverList<Function>();
      }

      // If listener already registered for this property, throw
      if (_propertyListeners[property].contains(listener)) {
        throw (Exception('Listener already registered for $property.'));
      }

      _propertyListeners[property].add(listener);
    }
  }

  @override
  void removeListener(Function listener, [Iterable<T> properties]) {
    assert(_debugAssertNotDisposed());
    assert(listener != null);

    // If no properties provided, remove global listener only
    if (properties == null) {
      super.removeListener(listener);
      return;
    }

    for (final property in properties) {
      // If no map entry exists for property, exit
      if (!_propertyListeners.containsKey(property)) {
        return;
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

  @override
  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _propertyListeners = null;
    super.dispose();
  }

  @override
  @protected
  @visibleForTesting
  void notifyListeners([T property]) {
    assert(_debugAssertNotDisposed());
    assert(!(property is Iterable), 'notifyListeners() should only be called for one property at a time');

    // Always notify global listeners
    super.notifyListeners();

    // If no property provided, exit
    if (property == null) {
      return;
    }

    // If no listeners for this property, exit
    if (!_propertyListeners.containsKey(property)) {
      return;
    }

    // Create a local copy of _propertyListeners in case a callback calls
    // [addListener] or [removeListener] while we are iterating through the list.
    final currentListeners = _propertyListeners[property];
    final localListeners = List<Function>.from(currentListeners);

    for (final listener in localListeners) {
      // One last check to make sure the listener hasn't been removed
      // from the original list since the time we made our local copy.
      if (currentListeners.contains(listener)) {
        // If the listener accepts the property as a parameter, provide it.
        // Otherwise just invoke the listener.
        if (listener is Function(T property)) {
          listener(property);
        } else {
          listener();
        }
      }
    }
  }
}
