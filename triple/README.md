# Triple

Este package é uma abstração do [Segmented State Pattern( Padrão de Estado Segmentado)](https://github.com/Flutterando/triple_pattern) que impõem barreiras arquiteturais para reatividades individuais.

Essa abstração server para a crição de implementações do [SSP](https://github.com/Flutterando/triple_pattern) usando qualquer objeto Reativo como base para criar uma Store(Objeto Responsável pela Lógica do Estado de um componente).

## Como criar uma Store?
.

![Triple](https://github.com/Flutterando/triple_pattern/raw/master/schema.png)

Seguindo o [SSP](https://github.com/Flutterando/triple_pattern), nossa Store precisa segmentar os dados do estado em 3 vias, um State(contendo o valor do Estado), um Error(Contendo o objeto de exception do estado) e o Loading(indicando se o valor do estado está sendo carregado). Essas 3 propriedades fazem parte do objeto Triple que é herdado como propriedade na classe abastrata Store.
Vamos entao ver passo-a-passo como criar um Store baseado em qualquer sistema de Reatividade existente.


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
class StreamStore extends Store {}
```

Também é prudente colocar "tipos genéricos" para o "state" e "error", faremos isso no **StreamStore** e depois reatribuiremos na **Store**.
> **IMPORTANTE**: Herde os tipos genéricos de Object para impedir o uso de dynamics.

e assim temos:
```dart
class StreamStore<State extends Object, Error extends Object> extends Store<State, Error> {}
```

Precisamos ainda declarar o construtor da classe pai com um valor inicial do state e assim concluimos essa etapa:

```dart
class StreamStore<State extends Object, Error extends Object> extends Store<State, Error> {

  StreamStore(State state) : super(state);

}
```

### PASSO 3: Inicie um objeto com a reatividade escolhida.
 

Inclua de forma privada uma propriedade reativa que trabalhe com o tipo **Triple<State, Error>()**:

```dart
class StreamStore<State extends Object, Error extends Object> extends Store<State, Error> {

  //main stream
  final _tripleController = StreamController<Triple<State, Error>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

}
```

### PASSO 4: Encerre o objeto reativo

Sobrescreva o método **destroy** que será chamado quando a Store for descartada.


```dart
class StreamStore<State extends Object, Error extends Object> extends Store<State, Error> {

  //main stream
  final _tripleController = StreamController<Triple<State, Error>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

  @override
  Future destory() async {
    await _tripleController.dispose();
  }

}
```

### PASSO 5: Sobrescreva o método de Propagação.

Quando o Store decide propagar um valor do tipo **Triple**, ele o faz chamando o método **propagate()**. Sobreescreva esse método para direcionar o fluxo para o seu controle principal de reatividade.

```dart
class StreamStore<State extends Object, Error extends Object> extends Store<State, Error> {

  //main stream
  final _tripleController = StreamController<Triple<State, Error>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

  @protected
  @override
  void propagate(Triple<State, Error> triple){
    _tripleController.add(triple);
  }

  @override
  Future destory() async {
    await _tripleController.dispose();
  }

}
```

> **IMPORTANTE**: O método **propagate** está assinado com **@protected** porque ele só deve ser usado dentro da classe **StreamStore**.


### PASSO 6: Sobreescreva o método **observer**

Esse método é chamado para escutar os eventos segmentados do estado(state, error e loading). Sobreescreva chamando as funções de cada segmento. 


```dart
class StreamStore<State extends Object, Error extends Object> extends Store<State, Error> {

  //main stream
  final _tripleController = StreamController<Triple<State, Error>>.broadcast(sync: true);

  StreamStore(State state) : super(state);

  @protected
  @override
  void propagate(Triple<State, Error> triple){
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
  Future destory() async {
    await _tripleController.dispose();
  }

}
```

### PASSO 7 (OPCIONAL): Defina Seletores

Pode ser interessande ter seletores de quada segmento do estado de forma reativa. Isso é um State, Error e loading reativo.

## Considerações sobre o Padrão Memento

Uma Store já contem por padrão a possibilidade de rollback de estado. Isso significa que poderá retornar ao estado anterior usando o método **undo()** e também prosseguir com o método **redo()**.

## Exemplos

- [flutter_triple](https://pub.dev/packages/flutter_triple) (StreamStore, NotifierStore, ScopedBuilder, TripleBuilder);

- [mobx_triple](https://pub.dev/packages/mobx_triple) (MobXStore);



## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
