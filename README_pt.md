# Triple - Segmented State Pattern

Quando falamos de estado com fluxo único acabamos resolvendo problemas na arquitetura de forma precoce, pois teremos apenas um fluxo de dado para cada estado. 
Além da manutenabilidade e facilidade arquitetural de aproveitamento também temos a possibilidade de incrementar esse fluxo com outros padrões como o Observer, que dá reatividade ao componente ao ser modificado e o Memento, que possibilita o rollback ou redo desse estado.

Um belo exemplo de padrão com fluxo único é o BLoC, dando a reatividade para um estado possibilitando todas as transformações nesse fluxo. Isso (apesar de complicado para alguns), consolida-se muito bem na arquitetura de um projeto, até mesmo os limites dessa prática são benéficos por não permitir que o desenvolvedor recorra a outras soluções fora da arquitetura e do padrão para sua feature.

Existem outras formas de promover a reatividade em uma propriedade em vez do objeto inteiro, como por exemplo, o Observable do MobX e ValueNotifier do próprio Flutter, e isso nos dá uma boa liberdade. Porém perdemos alguns limites importantes para arquitetura, o que pode colocar em cheque a manutenabilidade do projeto futuramente. Por isso precisamos de um padrão para impor limites na reatividade individual de cada propriedade e com isso melhorar a manutenabilidade dos componentes responsáveis por gerenciar os estados da aplicação.


## Padrão de Fluxo único (BLoC e Flux/Redux)
.
![schema](bloc.png)

Quando trabalhamos com estado de Fluxo único, ou seja, quando a reatividade está no objeto e não nas suas propriedades, podemos ter mais controle sobre os dados que tramitam antes de chegar a um ouvinte.
Por exemplo, se sua lógica gerencia um estado X e quer torna-lo Y basta atribuir o valor.
```dart
MyState state = X();
state = Y();
```
Porém o fluxo pode conter elementos assíncronos e sempre é interessante informar que o estado está sendo carregado. Isso é bastante comum no desenvolvimento Mobile com API's por exemplo.
```dart
MyState state = X();
state = Loading();
state = await getY(); // return Y
```
Também a recuperação desses dados pode falhar, e isso torna pertinente a existência de um estado de erro.
```dart
MyState state = X();
state = Loading();
try{
  state = await getY();
} catch(e) {
  state = Error();
}

```

Como estamos falando de um fluxo único usamos o **POLIMORFISMO** da Orientação a Objetos para dividir essas 3 responsabilidades(Valor do Estado, Loading ou Error).

```dart
abstract class MyState {}

class X extends MyState
class Y extends MyState
class Loading extends MyState
class Error extends MyState
```
Com isso temos um Fluxo único de **MyState**, pois como os objetos X, Y, Loading e Error herdam de **MyState**.
```dart
X is MyState; // it's true!
Y is MyState; // it's true!
Loading is MyState; // it's true!
Error is MyState; // it's true too!
```
Muito obrigado mãe Orientação a Objetos! :)

> **IMPORTANT:** BLoC é um acrônimo para Bussines Logic Component(Componente de Regra de Negócio).

## Segmentado o estado em State, Error, Loading
.
![schema](schema.png)

Agora como temos a possibilidade de ter reatividade por propriedade com o MobX ou ValueNotifier não precisariamos do Polimorfismo se dividimos a responsábilidade de Loading e Error para propriedades separadas dentro de uma **STORE**. E assim temos uma bifurcação tripla tornando o Loading e Error ações pós ou pré mudança de estado.
Um exemplo usando MobX:
```dart
...
@observable 
ProductData state = ProductData.empty();

@observable 
bool isLoading = false;

@observable 
Exception? error;

@action
Future<void> fetchProducts() async {
  isLoading = true;
  try{
    state = await repository.getProducts(); // return ProductData
  } catch(e){
    error = Exception('Error');
  }
  isLoading = false;
}
```

Resumindo, temos então 3 fluxos, o state que tem o valor do estado, o error que guarda as exceptions e o bool isLoading que informa quando a ação de carregamento está em vigor.
Poder escutar essas 3 ações de forma separada ajuda a transforma-las e a combina-las em outras ações enriquecendo a sua Store(Classe com a lógica responsável por gerenciar o estado do seu componente).
Como o movimento do estado sempre está em torno do trio State, Error e Loading vale a pena essa bifurcação para a padronização.

> **IMPORTANT:** Um objeto denominado **Store** tem por responsabilidade armazenar a Lógica para o estado de um componente.

## Observando os Fluxos

Tendo 3 Fluxos separados poderemos ter 3 listeners diferentes, por exemplo, escutamos o error para lança-lo em forma de "SnackBar" e quando houver Loadings lançamos um Dialog, mas se precisarmos adicionar a esse estado um padrão como o "memento" teremos que colocar as 3 propriedades em um objeto genérico.

Para fechar o padrão dos 3 Fluxos podemos criar um objeto genérico, com propriedades que podem ser reativas, bem como o próprio objeto em sí. Vejamos um exemplo com o MobX.

```dart

class Triple<Error, State> {
  final State state;
  final Error? error;
  final bool isLoading;

  Triple({required this.state, this.error, this.isLoading = false});

  Triple<Error, State> copyWith({State? state, Error? error, bool? isLoading}){
    return Triple<Error, State>(
      state: state ?? this.state,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

```

Então poderemos usar:
```dart
@observable 
var triple = Triple<ProductData, Exception>(state: ProductData.empty());

@action
Future<void> fetchProducts() async {
  triple = triple.copyWith(isLoading: true);
  try{
    final state = await repository.getProducts(); // return ProductData
    triple = triple.copyWith(isLoading: false, state: state);
  } catch(e){
    final error = Exception('Error');
    triple = triple.copyWith(isLoading: false, error: error);
  }
}
```

Agora temos um objeto que junta as 3 propriedades do estado segmentadas, que também podem ser acessadas e transformadas individualmente usando o @computed do MobX, que faz distinção automática e só dispara uma reação se a propriedade for realmente um novo objeto.

```dart
@observable 
var _triple = Triple<ProductData, Exception>(state: ProductData.empty());

@computed
ProductData get state => triple.state;

@computed
Exception get error => triple.error;

@computed
bool get isLoading => triple.isLoading;

...
```

Com o objeto reunindo o estado e as suas ações, podemos implementar outros design patterns, ou fazer transformações separadamente nas propriedades desse objeto, ou apenas fazer transformações no objeto.
Vamos ver um pequeno exemplo de implementação do Design Pattern Memento que tornará possível o estado dar rollback, isso é, retornar aos estados anteriores como uma máquina do tempo.

```dart
...

@observable 
var _triple = Triple<ProductData, Exception>(state: ProductData.empty());

@computed
ProductData get state => triple.state;
@computed
Exception get error => triple.error;
@computed
bool get isLoading => triple.isLoading;

//save all changed states
final List<Triple<ProductData, Exception>> _history = [];

@action
void update(ProductData state){
  _history.add(_triple);
  _triple = _triple.copyWith(state: state);
}

@action
void setError(Exception error){
  _triple = _triple.copyWith(error: error);
}

@action
void setLoading(bool loading){
  _triple = _triple.copyWith(loading: loading);
}

@action
void undo(){
  if(_history.length > 0){
    _triple = _history.last;
    _history.remove(_triple);
  } else {
    throw Exception('Not have history data');
  }
}

@action
Future<void> fetchProducts() async {
  triple = setLoading(true);
  try{
    final state = await repository.getProducts(); // return ProductData
    triple = update(state);
  } catch(e){
    final error = Exception('Error');
    triple = setError(error);
  }
  triple = setLoading(false);
}
```

Implementamos algo bem complexo, mas é muito fácil entender o que está acontecendo apenas lendo o código.
Assim chegamos a um padrão que pode ser usado para gerênciar estados e sub-estados usando reatividade individualmente por propriedade.

O padrão de Estado Segmentado (Ou Triple) pode ser abstraído para tornar a sua reutilização mais forte. Vamos usar mais uma vez o MobX como exemplo, mas poderemos utilizar em qualquer tipo de reatividade por propriedade.

```dart
abstract class MobXStore<Error, State> {

  @observable 
  late Triple<Error, State> _triple;

  MobXStore(State initialState){
     _triple = Triple<Error, State>(state: initialState);
  }

  @computed
  State get state => triple.state;
  @computed
  Error get error => triple.error;
  @computed
  bool get isLoading => triple.isLoading;

  //save all changed states
  final List<Triple<Error, State>> _history = [];

  @action
  void update(State state){
    _history.add(_triple);
    _triple = _triple.copyWith(state: state);
  }

  @action
  void setError(Error error){
    _triple = _triple.copyWith(error: error);
  }

  @action
  void setLoading(bool isLoading){
    _triple = _triple.copyWith(isLoading: isLoading);
  }

  @action
  void undo(){
    if(_history.length > 0){
      _triple = _history.last;
      _history.remove(_triple);
    } else {
      throw Exception('Not have history data');
    }
  }
}
```

agora basta implementar o **MobXStore** em qualquer Store do MobX que deseja utilizar.

```dart
class Product = ProductBase with _$Product;

abstract class ProductBase extends MobXStore<Exception, ProductData> with Store {

  ProductBase(): super(ProductData.empty());

  @action
  Future<void> fetchProducts() async {
    setLoading(true);
    try{
      final state = await repository.getProducts(); // return ProductData
      update(state);
    } catch(e){
      final error = Exception('Error');
      setError(error);
    }
    setLoading(true);
  }
}

```

Mais uma vez OBRIGADO MÃE ORIENTAÇÃO A OBJETOS.

## Extension (Dart)

Como vimos, o propósito do Padrão de Estado Segmentado(Triple) é ajudar na padronização das lógicas de gerenciamento do estado. Estamos trabalhando em abstrações(packages) baseados nas reatividades desenvolvidas pela comunidade, e nas reatividades nativas do próprio Flutter como o ValueNotifier e Streams. Mais detalhes na documentação das próprias abstrações.

- [triple](https://pub.dev/packages/triple) (Abstração para o Dart)
- [flutter_triple](https://pub.dev/packages/flutter_triple) (Implementa o **triple** criando Stores baseadas em Stream e ValueNotifier, )
- [mobx_triple](https://pub.dev/packages/mobx_triple) (MobXStore)
- [getx_triple](https://pub.dev/packages/getx_triple) (GetXStore)

## Exemplos

Verifique a [seção de exemplos](./examples/README.md).


## Features and bugs

O Padrão de Estado Segmentado está em constante crescimento. 
Deixe-nos saber o que está achando de tudo isso.
Se está de acordo deixe um Star nesse reposítorio representando que está assinando e concordando com o padrão proposto.
