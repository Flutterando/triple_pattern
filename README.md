<a name="readme-top"></a>

<!--
*** This template was base on othneildrew's Best-README-Template. If you have a suggestion that would make this better, please fork the repo and create a pull request if it's for the template as whole. 

If it's for the Flutterando version of the template just send a message to us (our contacts are below)

*** Don't forget to give his project a star, he deserves it!
*** Thanks for your support! 
-->


  <h1 align="center">Triple - Segmented State Pattern</h1>


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://raw.githubusercontent.com/Flutterando/triple_pattern/master/doc/static/img/docusaurus.png" alt="Logo" width="80" style=" padding-right: 30px;">
  </a>
  <a href="https://github.com/Flutterando/README-Template/">
    <img src="https://raw.githubusercontent.com/Flutterando/README-Template/master/readme_assets/logo-flutterando.png" alt="Logo" width="95">
  </a>

  <br />
  <p align="center">
    Welcome to Triple!
    Design Pattern for State Management. 
    <br>
    <br>
    <a href="https://triple.flutterando.com.br">View Example</a>
    ·
    <a href="https://github.com/Flutterando/triple_pattern/issues">Report Bug</a>
    ·
    <a href="https://github.com/Flutterando/triple_pattern/pulls">Request Feature</a>
  </p>
</div>

<br>

---


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#Usage">Usage</a></li>
    <li><a href="#Contributing">Contributing</a></li>
  </ol>
</details>


---

<br>

<!-- ABOUT THE PROJECT -->
## :memo: About The Project

### What is Triple?

Triple is a nickname to SSP (Segmented State Standard).
Some packages were created to make it easier for developers to start using the standard. We'll call it an extension.

### Segmented State Pattern (SSP) 

When we talk about a single flow state, we end up solving architecture problems early, as we will have only one data flow for each state.

In addition to the maintainability and to the ease of use architecture, we also have the possibility of increasing this flow with other standards such as the Observer, which gives reactivity to the component when it is modified, and Memento, which makes it possible to revert or redo this state.

A beautiful example of a pattern with a single flow is BLoC, giving reactivity to a state allowing all transformations in that flow. This (although complicated for some), consolidates very well in the architecture of a project, even the limits of this practice are beneficial for not allowing the developer to resort to other solutions for the architecture and the standard for its resource.

There are other ways to promote reactivity in a property instead of the entire object, such as MobX's Observable and Flutter's ValueNotifier, and that gives us a lot of choices. However, we lose some important architecture limits, which can put in check the project maintenance in the future. Therefore, it needs a standard to force limits on the individual reactivity of each property and thereby improve the maintainability of the components responsible for managing the states of the application.


Triple is a nickname to SSP (Segmented State Standard). Some packages were created to make it easier for developers to start using the standard. We'll call it an extension.

<br>

<i>This project is distributed under the MIT License. See `LICENSE.txt` for more information.</i>

<br>

## ✨ Usage

The SSP segments the state into 3 reactive parts, the state value (state), the error object (error), and the state loading action (loading).

These segments are observed in a listener or separate listeners. They can also be combined to obtain a new segment, always starting from the 3 main segments.

## Installation

### Dependencies

add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_triple: ^1.3.0
```

### Import

Import the package in your code with:
```dart
import 'package:flutter_triple/flutter_triple.dart';
```

## How to use?

### Create a Store

Create a class that extends `NotifierStore<Error, State>`.
The first type is the type of the error, the second is the type of the state.


```dart
class CounterStore extends NotifierStore<Exception, int> {
  CounterStore() : super(0);

  void increment() => update(state + 1);
  void decrement() => update(state - 1);
}
```

### Consume with Listeners, Builders and Consumers

Consume the store with scopes `ScopedBuilder`, `ScopedListener` and `ScopedConsumer`.

```dart

class CounterPage extends StatefulWidget {
  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final store = CounterStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
      ),
      body: ScopedBuilder<CounterStore, Exception, int>(
        store: store,
        onLoading: (context) => Center(child: CircularProgressIndicator()),
        onError: (context, error) => Center(child: Text(error.toString())),
        onState: (context, state) => Center(
          child: Text(
            '$state',
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      ),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: store.decrement,
              tooltip: 'Decrement',
              child: Icon(Icons.remove),
            ),
            SizedBox(width: 5),
            FloatingActionButton(
              onPressed: store.increment,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ],
        ),
    );
  }
}

```
<!-- CONTRIBUTING -->
## 🧑‍💻 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**. Just create a pull request with your suggestions and changes or be in contact with us through Discord or any other of the links below. 

In addition to writing code, there are many ways for you to contribue.

You can contribute as following:
- Join and modify translations in our [Crowdin Translation Project](https://crowdin.com/project/apitablecode/invite?h=f48bc26f9eb188dcd92d5eb4a66f2c1f1555185)
- Create [Issues](https://github.com/flutterando-readme-template/flutterando-readme-template/issues/new/choose)
- Create [Documentation](./docs)
- [Contributing Code](./docs/contribute/developer-guide.md)


You can read this repository’s [Contributing Guidelines](./CONTRIBUTING.md) to learn how to contribute.

Here's a quick guide to help you contribute to Flutterando.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<br>

<!-- CONTACT -->
## 💬 Contact

Flutterando Community
- [Discord](https://discord.gg/qNBDHNARja)
- [Telegram](https://t.me/flutterando)
- [Website](https://www.flutterando.com.br)
- [Youtube Channel](https://www.youtube.com.br/flutterando)
- [Other useful links](https://linktr.ee/flutterando)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<br>

<!-- CONTRIBUTORS -->
## 👥 Contributors

<a href="https://github.com/Flutterando/triple_pattern/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=flutterando/triple_pattern" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MANTAINED BY -->
## 🛠️ Maintaned by

<br>

<p align="center">
  <a href="https://www.flutterando.com.br">
    <img width="110px" src="https://raw.githubusercontent.com/Flutterando/README-Template/master/readme_assets/logo-flutterando.png">
  </a>
  <p align="center">
    This fork version is maintained by <a href="https://www.flutterando.com.br">Flutterando</a>.
  </p>
</p>
