import 'package:search/app/search/domain/entities/result.dart';
import 'package:search/app/search/domain/errors/erros.dart';
import 'package:search/app/search/domain/usecases/search_by_text.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx_triple/mobx_triple.dart';

part 'search_store.g.dart';

@Injectable()
class SearchStore extends MobXStore<Failure, List<Result>> {
  final SearchByText searchByText;

  SearchStore(this.searchByText) : super([]);

  void setSearchText(String value) {
    execute(() async => (await searchByText(value)).fold((l) => [], (r) => r), delay: Duration(milliseconds: 500));
  }
}
