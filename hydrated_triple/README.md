# hydrated_triple

A mixin which automatically persists and restores store state. 

```dart
void main() {

    setTripleHydratedDelegate(SharedPreferencesHydratedDelegate());

    runApp(AppWidget());
}
```
