# Triple

Este package é uma abstração do [Segmented State Pattern( Padrão de Estado Segmentado)](https://github.com/Flutterando/triple_pattern) que impõem barreiras arquiteturais para reatividades individuais.

Essa abstração serve para a crição de implementações do [SSP](https://github.com/Flutterando/triple_pattern) usando qualquer objeto Reativo como base para criar uma Store(Objeto Responsável pela Lógica do Estado de um componente).

## Como criar uma Store?
.

![Triple](https://github.com/Flutterando/triple_pattern/raw/master/schema.png)

Seguindo o [SSP](https://github.com/Flutterando/triple_pattern), nossa Store precisa segmentar os dados do estado em 3 vias, um State(contendo o valor do Estado), um Error(Contendo o objeto de exception do estado) e o Loading(indicando se o valor do estado está sendo carregado). Essas 3 propriedades fazem parte do objeto Triple que é herdado como propriedade na classe abstrata Store.
Vamos então ver passo-a-passo como criar um Store baseado em qualquer sistema de Reatividade existente.




### PASSO 1: Escolha uma forma de Reatividade.

O SSP não coloca nenhum requerimento sobre o tipo de reatividade que poderá ser utilizada no padrão, então o desenvolvedor deve escolher a que mais lhe agrada para criar uma Store.
Alguns exemplos de ferramentas:
- Streams
- ValueNotifier/ChangeNotifier
- MobX

Para os próximos passos usaremos "Streams", mas fique a vontade sobre essa escolha.

### PASSO 2: Crie uma classe que herde de **Store**

Como já falamos, um objeto **Store** serve para armazenar a Lógica de Estado de um componente.
```dart
abstract class StreamStore extends Store {}
```

Também é prudente colocar "tipos genéricos" para o "error" e "state", faremos isso no **StreamStore** e depois reatribuiremos na **Store**.
> **IMPORTANTE**: Herde os tipos genéricos de Object para impedir o uso de dynamics.

e assim temos:
```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {}
```

Precisamos ainda declarar o construtor da classe pai com um valor inicial do state e assim concluímos essa etapa:

```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {

  StreamStore(State state) : super(state);

}
```

### PASSO 3: Inicie um objeto com a reatividade escolhida.
 

Inclua de forma privada uma propriedade reativa que trabalhe com o tipo **Triple<Error, State>()**:

```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {

  //main stream
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

}
```

### PASSO 4: Encerre o objeto reativo

Sobrescreva o método **destroy** que será chamado quando a Store for descartada.


```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {

  //main stream
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

  @override
  Future destroy() async {
    await _tripleController.dispose();
  }

}
```

### PASSO 5: Sobrescreva o método de Propagação.

Quando o Store decide propagar um valor do tipo **Triple**, ele o faz chamando o método **propagate()**. Sobrescreva esse método para direcionar o fluxo para o seu controle principal de reatividade. Não se esqueça de chamar o método **super.propagate()**.

```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {

  //main stream
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

  @protected
  @override
  void propagate(Triple<Error, State> triple){
    super.propagate(triple);
    _tripleController.add(triple);
  }

  @override
  Future destroy() async {
    await _tripleController.dispose();
  }

}
```

> **IMPORTANTE**: O método **propagate** está assinado com **@protected** porque ele só deve ser usado dentro da classe **StreamStore**.


### PASSO 6: Sobreescreva o método **observer**

Esse método é chamado para escutar os eventos segmentados do estado(state, error e loading). Sobrescreva chamando as funções de cada segmento. 


```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State> {

  //main stream
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

  @protected
  @override
  void propagate(Triple<Error, State> triple){
    _tripleController.add(triple);
  }

  @override
  Disposer observer({
    void Function(State state)? onState,
    void Function(Error error)? onError,
    void Function(bool loading)? onLoading,
  }){
    final _sub = _tripleController.listen((triple){
      if(triple.event == TripleEvent.state){
        onState(triple.state);
      } else if(triple.event == TripleEvent.error){
        onError(triple.error);
      } else if(triple.event == TripleEvent.loading){
        onLoading(triple.loading);
      }
    });
    return () async {
      await _sub.cancel();
    }
  }

  @override
  Future destroy() async {
    await _tripleController.dispose();
  }

}
```

### PASSO 7 (OPCIONAL): Defina Seletores

Pode ser interessante ter seletores de cada segmento do estado de forma reativa. Isso é um Error, State e loading reativo.
Se deseja ter essa possibilidade no Store implemente a interface **Selectors**:

```dart
abstract class StreamStore<Error extends Object, State extends Object> extends Store<Error, State>
implements Selectors<Stream<Error>, Stream<State>, Stream<bool>>
 {

  //main stream
  final _tripleController = StreamController<Triple<Error, State>>.broadcast(sync: true);

  @override
  late final Stream<State> selectState = _tripleController.stream
      .where((triple) => triple.event == TripleEvent.state)
      .map((triple) => triple.state);

  @override
  late final Stream<Error> selectError = _tripleController.stream
      .where((triple) => triple.event == TripleEvent.error)
      .where((triple) => triple.error != null)
      .map((triple) => triple.error!);

  @override
  late final Stream<bool> selectLoading = _tripleController.stream
      .where((triple) => triple.event == TripleEvent.loading)
      .map((triple) => triple.loading);

  StreamStore(State state) : super(state);

  ...
```

## Middleware

Podemos adicionar interceptadores e modificar o triple quando for executado a ação de setLoading, setError ou update.

```dart
class Counter extends StreamStore<Exception, int> {

  Counter(0): super(0);

  ...
  @override
  Triple<Exception, int> middleware(triple){
    if(triple.event == TripleEvent.state){
      return triple.copyWith(state + 2);
    }

    return triple;
  }

}
```

## Executors

Um padrão muito comum em uma requisição assincrona é:

```dart

  @override
  Future<void> fetchData(){
    setLoading(true);
    try {
      final result = await repository.fetch();
      update(result);
    } catch(e){
      setError(e);
    }
    setLoading(false);
  }

```

Você pode utilizar o método **execute** e passar a Future para executar os mesmos passos descritos no exemplo anterior:

```dart

  @override
  Future<void> fetchData(){
   execute(() => repository.fetch());
  }

```
para usuários que utilizam o **dartz** utilizando o Clean Architecture por exemplo, também podem executar os eithers utilizando o método **executeEither**:

```dart
 @override
  Future<void> fetchData(){
   executeEither(() => myUsecase());
  }
```

## Usando o Padrão Memento com o MementoMixin

Você pode adicionar Desfazer ou refazer um estado usando o Memento Pattern. Isso significa que poderá retornar ao estado anterior usando o método **undo()** e também prosseguir com o método **redo()**.

```dart

class Counter extends StreamStore<Exception, int> with MementoMixin {}

```


## Exemplos

- [flutter_triple](https://pub.dev/packages/flutter_triple) (StreamStore, NotifierStore, ScopedBuilder, TripleBuilder);

- [mobx_triple](https://pub.dev/packages/mobx_triple) (MobXStore);
- [getx_triple](https://pub.dev/packages/getx_triple) (GetXStore);



## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
