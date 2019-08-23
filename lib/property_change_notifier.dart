library property_change_notifier;

import 'package:flutter/foundation.dart';

/// To work correctly, [property] must implement `operator==` and `hashCode`.
class PropertyChangeNotifier<T extends Object> extends ChangeNotifier {
  var _globalListeners = ObserverList<Function>();
  var _propertyListeners = <T, ObserverList<Function>>{};

  @override
  @protected
  @visibleForTesting
  bool get hasListeners {
    assert(_debugAssertNotDisposed());
    return _globalListeners.isNotEmpty || _propertyListeners.isNotEmpty;
  }

  @override
  void addListener(Function listener, [Iterable<T> properties]) {
    assert(_debugAssertNotDisposed());
    assert(listener != null);

    // If no properties provided, register global listener only
    if (properties == null) {
      _globalListeners.add(listener);
      return;
    }

    for (final property in properties) {
      // If property has no listeners yet; create map entry
      if (!_propertyListeners.containsKey(property)) {
        _propertyListeners[property] = ObserverList<Function>();
      }

      // If listener already registered for this property, ignore
      if (_propertyListeners[property].contains(listener)) {
        continue;
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
      _globalListeners.remove(listener);
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
    _globalListeners = null;
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
    _notifyListeners(_globalListeners, property);

    // If no property provided, exit
    if (property == null) {
      return;
    }

    // If property is provided and listeners exist for this property, notify them.
    if (property != null && _propertyListeners.containsKey(property)) {
      _notifyListeners(_propertyListeners[property], property);
    }
  }

  // Creates a local copy of [listeners] in case a callback calls
  // [addListener] or [removeListener] while iterating through the list.
  // Invokes each listener. If the listener accepts a property parameter, it will be provided.
  void _notifyListeners(ObserverList<Function> listeners, T property) {
    final localListeners = List<Function>.from(listeners);
    for (final listener in localListeners) {
      // One last check to make sure the listener hasn't been removed
      // from the original list since the time we made our local copy.
      if (listeners.contains(listener)) {
        if (listener is Function(T property)) {
          listener(property);
        } else {
          listener();
        }
      }
    }
  }

  // Reimplemented from [ChangeNotifier].
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
