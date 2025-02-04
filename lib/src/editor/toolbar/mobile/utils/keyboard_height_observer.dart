import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';

typedef KeyboardHeightCallback = void Function(double height);

// the KeyboardHeightPlugin only accepts one listener, so we need to create a
//  singleton class to manage the multiple listeners.
class KeyboardHeightObserver {
  KeyboardHeightObserver._() {
    _keyboardHeightPlugin.onKeyboardHeightChanged((height) {
      notify(height);
    });
  }

  static final KeyboardHeightObserver instance = KeyboardHeightObserver._();

  final List<KeyboardHeightCallback> _listeners = [];
  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();

  void addListener(KeyboardHeightCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(KeyboardHeightCallback listener) {
    _listeners.remove(listener);
  }

  void dispose() {
    _listeners.clear();
    _keyboardHeightPlugin.dispose();
  }

  void notify(double height) {
    for (final listener in _listeners) {
      listener(height);
    }
  }
}
