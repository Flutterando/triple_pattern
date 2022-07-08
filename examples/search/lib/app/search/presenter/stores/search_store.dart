import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx_triple/mobx_triple.dart';
import 'package:search/app/search/domain/entities/result.dart';
import 'package:search/app/search/domain/errors/erros.dart';
import 'package:search/app/search/domain/usecases/search_by_text.dart';

part 'search_store.g.dart';

@Injectable()
class SearchStore extends MobXStore<Failure, List<Result>> {
  final SearchByText searchByText;

  SearchStore(this.searchByText) : super([]);

  void setSearchText(String value) async {
    setLoading(true);

    searchByText(value).then(
      (value) {
        if (value is EitherAdapter<Failure, List<Result>>) {
          value.fold((e) => setError(e, force: true), (s) => update(s, force: true));
          setLoading(false);
        }
      },
    );
  }
}
