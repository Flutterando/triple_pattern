import 'package:search/app/search/domain/entities/result.dart';
import 'package:search/app/search/domain/errors/erros.dart';
import 'package:search/app/search/domain/repositories/search_repository.dart';
import 'package:search/app/search/domain/usecases/search_by_text.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class SearchRepositoryMock extends Mock implements SearchRepository {}

main() {
  final repository = SearchRepositoryMock();
  final usecase = SearchByTextImpl(repository);

  test('deve retornar uma lista com resultados', () async {
    when(repository)
        .calls('getUsers')
        .withArgs(positional: ['jacob']).thenAnswer((_) async =>
            Right<Failure, List<Result>>(
                <Result>[Result(image: '', name: '', nickname: '', url: '')]));

    var result = await usecase("jacob");
    expect(result.right, isA<List<Result>>());
  });

  test('deve retornar um InvalidSearchText caso o texto seja inválido',
      () async {
    var result = await usecase(null);
    expect(result.left, isA<InvalidSearchText>());
  });
  test('deve retornar um EmptyList caso o retorno seja vazio', () async {
    when(repository).calls('getUsers').withArgs(positional: [
      'jacob'
    ]).thenAnswer((_) async => Right<Failure, List<Result>>(<Result>[]));

    var result = await usecase("jacob");
    expect(result.left, isA<EmptyList>());
  });
}
