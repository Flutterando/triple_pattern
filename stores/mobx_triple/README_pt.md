# mobx_triple

Implementação do Segmented State Pattern (Padrão de Estado Segmentado) apelidado de Triple.


## Segmentação do Estado

O SSP segmenta o estado em 3 partes reativas, o valor do estado (state), o objeto de erro (error) e a ação de carregamento do estado (loading).

.

![Triple](https://github.com/Flutterando/triple_pattern/raw/master/schema.png)

Esses segmentos são observados em um listener ou em listeners separados. Também podem ser combinados para se obter um novo segmento, sempre partindo dos 3 segmentos principais.

## Sobre o Package

Este package tem por objetivo introduzir Stores no padrão de segmentos pré-implementadas usando o MobX**(MobXStore)**).

As Stores já oferecem por padrão um observador (**store.observer()**) e os métodos **store.update()**(Atualizar o Estado), **store.setLoading()**(Para mudar o loading), **store.setError()**(Para mudar o Erro).
Também conta com o mixin **MementoMixin** que utilizam o design pattern **Memento** para desfazer ou refazer o valor do estado, portanto, os métodos **store.undo()** e **store.redo()** também são adicionado a Store por esse mixin.

O Package também conta com **Builder Widgets** para observar as modificações do estado na árvore de widget do Flutter.

## Gerênciando o Estado com MobXStore

Um Store baseado em **MobX** é chamado de **MobXStore**:

```dart
class Counter extends MobXStore<int, Exception> {

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

Nossos selectors (selectState, selectError e selectBool) agora serão **Observable** que podem ser escutados separadamente usando **.observer()** ou na Árvore de Widget com o **Observer** ambos do flutter_mobx:

```dart

store.selectError.observer((_) => print(store.state));

...

Widget builder(BuildContext context){
    return Observer(
        builder: (_) => Text(store.state);
    );
}

```

Para mais informações sobre a extensão leia a documentação do [flutter_mobx](https://pub.dev/packages/flutter_mobx)

> **IMPORTANT**: Obviamente você pode continuar a usar os listeners do **Triple** (**observer**, **ScopedBuilder** e **TripleBuilder**);


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

```dart
Observable<int> myState$ = counter.selectState;
Observable<Exception?> myError$ = counter.selectError;
Observable<bool> myLoading$ = counter.selectLoading;

```

## Usando o Padrão Memento com o MementoMixin

Você pode adicionar Desfazer ou refazer um estado usando o Memento Pattern. Isso significa que poderá retornar ao estado anterior usando o método **undo()** e também prosseguir com o método **redo()**.

```dart

class Counter extends MobXStore<int, Exception> with MementoMixin {}

```

## Dúvidas e Problemas

O Canal de **issues** está aberto para dúvidas, reportar problemas e sugestões, não exite em usar esse canal de comunicação.

> **VAMOS SER REFERRENCIAS JUNTOS**








