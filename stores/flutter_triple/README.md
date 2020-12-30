# flutter_triple

Implementação do Segmented State Pattern (Padrão de Estado Segmentado) apelidado de Triple.


## Segmentação do Estado

O SSP segmenta o estado em 3 partes reativas, o valor do estado (state), o objeto de erro (error) e a ação de carregamento do estado (loading).

.

![Triple](https://github.com/Flutterando/triple_pattern/raw/master/schema.png)

Esses segmentos são observados em um listener ou em listeners separados. Também podem ser combinados para se obter um novo segmento, sempre partindo dos 3 segmentos principais.

## Sobre o Package

Este package tem por objetivo introduzir Stores no padrão de segmentos pré-implementadas usando a API de Streams(StreamStore) e do objeto ValueNotifier (NotifierStore).

As Stores já oferecem por padrão um observador (**store.observer()**) e os métodos **store.update()**(Atualizar o Estado), **store.setLoading()**(Para mudar o loading), **store.setError()**(Para mudar o Erro).
Também conta com o mixin **MementoMixin** que utilizam o design pattern **Memento** para desfazer ou refazer o valor do estado, portanto, os métodos **store.undo()** e **store.redo()** também são adicionado a Store por esse mixin.

Usando o ValueNotifier(NotifierStore), as propriedades *state*,*loading* e *error* são reativas graças a extensão [rx_notifier](https://pub.dev/packages/rx_notifier).

O Package também conta com **Builder Widgets** para observar as modificações do estado na árvore de widget do Flutter.

## Gerênciando o Estado com Streams

Para criar uma Store que ficará responsável pela Lógica do estado, crie uma classe e herde de **StreamStore**:

```dart
class Counter extends StreamStore {}
```

Você também pode colocar tipos no valor do estado e no objeto de exception que iremos trabalhar nesse Store:

```dart
class Counter extends StreamStore<int, Exception> {}
```

Finalizamos atribuindo um valor inicial para o estado desse Store invocando o construtor da classe pai (super):

```dart
class Counter extends StreamStore<int, Exception> {

    Counter() : super(0);
}
```

Temos disponível na Store 3 métodos para mudar os segmentos **(setState, setError e setLoading)**. Vamos começar incrementando o estado:

```dart
class Counter extends StreamStore<int, Exception> {

    Counter() : super(0);

    void increment(){
        update(state + 1);
    }
}
```

Esse código já é o suficiente para fazer o contador funcionar.
Vamos adicionar um pouco de código assincrono para apresentar os métodos **setError** e **setLoading**

```dart
class Counter extends StreamStore<int, Exception> {

    Counter() : super(0);

    Future<void> increment() async {
        setLoading(true);

        await Future.delayer(Duration(seconds: 1));

        int value = state + 1;
        if(value < 5) {
            update(value);
        } else {
            setError(Exception('Error: state not can be > 4'))
        }
        setLoading(false);
    }
}
```

Aqui experimentamos a mudança de estados e os outros segmentos de loading e error. 
> **NOTE**: Tudo o que foi mostrado aqui para o **StreamStore** também server para o **NotifierStore**.

Os 3 segmentos operam separados mas podem ser "escutados" juntos. Agora iremos ver como observar esse store.

## Observers and Builders

### observer

Podemos observar os segmentos de forma individual ou de todos usando o método **store.observer()**;

```dart
counter.observer(
    onState: (state) => print(state),
    onError: (error) => print(error),
    onLoading: (loading) => print(loading),
);
```
Já nos Widgets podemos escolher escutar em um Builder com Escopo ou escutar todas as modificações do Triple.

### ScopedBuilder

Use o **ScopedBuilder** para escutar os segmentos de forma individual ou de todos, semelhante ao que faz o método **store.observer()**;

```dart
ScopedBuilder(
    store: counter,
    onState: (context, state) => Text('$state'),
    onError: (context, error) => Text(error.toString()),
    onLoading: (context, loading) => CircularProgressIndicator(),
);
```

> **NOTE**: No ScopedBuilder O **onLoading** só é chamado quando for "true". Isso significa que se o estado for modificado ou for adicionado um erro, o widget a ser construido será o do **onState** ou do **onError**. Porém é muito importante modificar o Loading para "false" quando a ação de carregamento for completada. Os **observers** do Triple *NÃO PROPAGAM OBJETOS REPETIDOS* (mais sobre isso na sessão sobre **distinct**). Esse é um comportamento exclusivo do ScopedBuilder.

### TripleBuilder

Use o **TripleBuilder** para escutar todas as modificações dos segmentos e refleti-las na arvore de Widgets.

```dart
TripleBuilder(
    store: counter,
    builder: (context, triple) => Text('${triple.state}'),
);
```

> **NOTE**: O Builder do **TripleBuilder** é chamado quando há qualquer alteração nos segmentos. Seu uso é recomendado apenas se tiver interesse em escutar todos os segmentos ao mesmo tempo.

### Distinct

Por padrão, o observer da Store não reage a objetos repetidos. Esse comportamento é benéfico pois evita reconstruções de estado e notificações se o segmento não foi alterado.

É uma boa prática sobreescrever o **operation==** do valor do estado e error. Uma boa dica também é usar o package [equateble](https://pub.dev/packages/equatable) para simplificar esse tipo de comparação.

## Selectors

Podemos recuperar a reatividade dos segmentos de forma individual para transformações ou combinações. Temos então 3 selectors que podem ser recuperados como propriedades do Store: **store.selectState**, **store.selectError** e **store.selectLoading**.

O Tipo dos selectors muda dependendo da ferramenta reativa que estiver utilizando nos Stores. Por exemplo, se estiver usando **StreamStore** então seus selectors serão Streams, porém se estiver usando **NotifierStore** então seus selectors serão ValueListenable;

```dart
//StreamStore
Stream<int> myState$ = counter.selectState;
Stream<Exception> myError$ = counter.selectError;
Stream<bool> myLoading$ = counter.selectLoading;

//NotifierStore
ValueListenable<int> myState$ = counter.selectState;
ValueListenable<Exception?> myError$ = counter.selectError;
ValueListenable<bool> myLoading$ = counter.selectLoading;

```

## Gerênciando o Estado com ValueNotifier

[ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) é uma implementação de [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) e está presente em todo o ecosistema do Flutter, desde ScrollController ao TabController.

Usar a API do *ChangeNotifier* significa reaproveitar tudo o que já existe no Flutter, por isso é normal considerá o seu uso.

O ValueNotifier usado nessa Store é extendido pela library [rx_notifier](https://pub.dev/packages/rx_notifier) que trás a possibilidade de aplicar a **functional reactive programming (TFRP)**, escutando as mudanças de seus valores de forma transparente como faz o [MobX](https://pub.dev/packages/mobx) por exemplo.

Um Store baseado em **ValueNotifier** é chamado de **NotifierStore**:

```dart
class Counter extends NotifierStore<int, Exception> {

    Counter() : super(0);

    Future<void> increment() async {
        setLoading(true);

        await Future.delayer(Duration(seconds: 1));

        int value = state + 1;
        if(value < 5) {
            update(value);
        } else {
            setError(Exception('Error: state not can be > 4'))
        }
        setLoading(false);
    }
}
```

Nossos selectors (selectState, selectError e selectBool) agora serão **ValueListenable** que podem ser escutados separadamente usando **.addListener()** ou na Árvore de Widget com o **AnimatedBuilder** ambos do próprio Flutter:

```dart

store.selectError.addListener(() => print(store.state));

...

Widget builder(BuildContext context){
    return AnimatedBuilder(
        animation: store.selectState,
        builder: (_, __, ___) => Text(store.state);
    );
}

```

Ou escutar as reações de forma transparente usando o **rxObserver** ou na árvore widget com o **RxBuilder**:

```dart

rxObserver(() => print(store.state));

...

Widget builder(BuildContext context){
    return RxBuilder(
        builder: (_) => Text(store.state);
    );
}

```

Para mais informações sobre a extensão leia a documentação do [rx_notifier](https://pub.dev/packages/rx_notifier)

> **IMPORTANT**: Obviamente você pode continuar a usar os listeners do **Triple** (**observer**, **ScopedBuilder** e **TripleBuilder**);

## Usando o Padrão Memento com o MementoMixin

Você pode adicionar Desfazer ou refazer um estado usando o Memento Pattern. Isso significa que poderá retornar ao estado anterior usando o método **undo()** e também prosseguir com o método **redo()**.

```dart

class Counter extends StreamStore<int, Exception> with MementoMixin {}

```

## Dúvidas e Problemas

O Canal de **issues** está aberto para dúvidas, reportar problemas e sugestões, não exite em usar esse canal de comunicação.

> **VAMOS SER REFERRENCIAS JUNTOS**








