import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:search/app/search/domain/entities/result.dart';
import 'package:search/app/search/domain/errors/erros.dart';
import 'package:search/app/search/domain/usecases/search_by_text.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx_triple/mobx_triple.dart';
import 'package:rxdart/rxdart.dart';

part 'search_store.g.dart';

@Injectable()
class SearchStore extends MobXStore<Failure, List<Result>>
    implements Disposable {
  final SearchByText searchByText;
  final _textStream = StreamController<String>(sync: true);
  late final StreamSubscription _sub;

  SearchStore(this.searchByText) : super([]) {
    _sub = _textStream.stream
        .debounceTime(Duration(milliseconds: 300))
        .map(startLoading)
        .asyncMap(searchByText.call)
        .switchMap((value) => Stream.value(value))
        .listen(_makeSearch);
  }

  String startLoading(String value) {
    setLoading(true);
    return value;
  }

  Future<void> _makeSearch(Either<Failure, List<Result>> result) async {
    result.fold(setError, update);
    setLoading(false);
  }

  void setSearchText(String value) => _textStream.add(value);

  @override
  void dispose() {
    _sub.cancel();
    _textStream.close();
  }
}
