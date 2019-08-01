library property_change_notifier;

import 'package:flutter/foundation.dart';

/// To work correctly, [property] must implement `operator==` and `hashCode`.
class PropertyChangeNotifier extends ChangeNotifier {
  final _propertyListeners = Map<dynamic, ObserverList<VoidCallback>>();

  @override
  bool get hasListeners {
    return super.hasListeners || _propertyListeners.isNotEmpty;
  }

  @override
  void addListener(VoidCallback listener, [List<Object> properties]) {
    assert(listener != null);

    // No properties provided, register global listener
    if (properties == null) {
      super.addListener(listener);
      return;
    }

    for (final property in properties) {
      // Property has no listeners yet; create map entry
      if (!_propertyListeners.containsKey(property)) {
        _propertyListeners[property] = ObserverList<VoidCallback>();
      }

      // Listener already registered
      if (_propertyListeners[property].contains(listener)) {
        throw(Exception('Listener already registered for $property.'));
      }

      _propertyListeners[property].add(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener, [List<Object> properties]) {
    assert(listener != null);

    // No properties provided; remove global listener.
    if (properties == null) {
      super.removeListener(listener);
      return;
    }

    for (final property in properties) {
      // No map entry exists for property
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
  void notifyListeners([Object property]) {
    assert(!(property is Iterable), 'notifyListeners() should only be called for one property at a time');

    // Always notify global listeners
    super.notifyListeners();

    // No property provided
    if (property == null) {
      return;
    }

    // No listeners for this property
    if (!_propertyListeners.containsKey(property)) {
      return;
    }

    // Create a local copy of _propertyListeners in case a callback calls
    // [addListener] or [removeListener] while we are iterating through the list.
    final currentListeners = _propertyListeners[property];
    final localListeners = List<VoidCallback>.from(currentListeners);

    for (final listener in localListeners) {
      // One last check to make sure the listener hasn't been removed
      // from the original list since the time we made our local copy.
      if (currentListeners.contains(listener)) {
        listener();
      }
    }
  }
}
