<p align="center">
<img src="https://raw.githubusercontent.com/Flutterando/triple_pattern/master/doc/static/img/docusaurus.png" height="200" alt="Triple" />
</p>

<p align="center">
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---
## Overview


[VSCode](https://code.visualstudio.com/) support for the [Triple Library](https://triple.flutterando.com.br/) and provides tools for effectively creating Stores for [Flutter](https://flutter.dev/) apps.
## Installation

Flutter Triple can be installed from the [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=Flutterando.flutter-triple) or by [searching within VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Code Actions

| Action                               | Description                                          |
| ------------------------------------ | ---------------------------------------------------- |
| `Wrap with ScopedBuilder`            | Wraps current widget in a `ScopedBuilder`            |
| `Wrap with ScopedBuilder.transition` | Wraps current widget in a `ScopedBuilder.transition` |
| `Wrap with TripleBuilder`            | Wraps current widget in a `TripleBuilder`            |

![demo](https://raw.githubusercontent.com/Flutterando/triple_pattern/master/extensions/vscode/assets/wrap-with-usage.gif)

## Snippets

### Triple

| Shortcut                | Description                            |
| ----------------------- | -------------------------------------- |
| `importfluttertriple`   | Imports `package:flutter_triple`.      |
| `importtripletest`      | Imports `package:triple_test`          |
| `triplenotifierstore`   | Creates a `NotifierStore` class        |
| `tripleobserver`        | Creates a `TripleObserver.addListener` |
| `triplestoreobserver`   | Creates a `store.observer`             |
| `triplestreamstore`     | Creates a `StreamStore` class          |
| `mockstore`             | Creates a class extending `MockStore`  |
| `tripletestwhenobserve` | Creates a `whenObserve`                |
| `tripleteststore`       | Creates a `storeTest`                  |

> **LET'S BE REFERENCES TOGETHER 💙**
