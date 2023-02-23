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
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>


---

<br>

<!-- ABOUT THE PROJECT -->
## :memo: About The Project

Triple is a nickname to SSP (Segmented State Standard). Some packages were created to make it easier for developers to start using the standard. We'll call it an extension.
### Extension (Dart)
As we have seen, the purpose of the Segmented State Standard (Triple) is to help normalizing state management logic. We are working on abstractions (packages) based on reactivities developed by the community and Flutter natives ones such as ValueNotifier and Streams.
* <a href="https://pub.dev/packages/triple">triple</a> (Abstraction to Dart)  
* <a href="https://pub.dev/packages/flutter_triple">flutter_triple</a> (Implements triple building Stores based on Stream and ValueNotifier)
* <a href="https://pub.dev/packages/mobx_triple">mobx_triple</a> (MobXStore)

<br>

<i>This project is distributed under the MIT License. See `LICENSE.txt` for more information.</i>

<br>

## ✨ Usage

The SSP segments the state into 3 reactive parts, the state value (state), the error object (error), and the state loading action (loading).

These segments are observed in a listener or separate listeners. They can also be combined to obtain a new segment, always starting from the 3 main segments.

### Installation

Add to your project's pubspec.yaml.

```dart
...
dependencies:
  flutter_triple: any
...
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
