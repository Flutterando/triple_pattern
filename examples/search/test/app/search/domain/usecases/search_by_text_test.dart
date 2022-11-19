import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:search/app/search/domain/entities/result.dart';
import 'package:search/app/search/domain/errors/erros.dart';
import 'package:search/app/search/domain/repositories/search_repository.dart';
import 'package:search/app/search/domain/usecases/search_by_text.dart';

class SearchRepositoryMock extends Mock implements SearchRepository {}

void main() {
  final repository = SearchRepositoryMock();
  final usecase = SearchByTextImpl(repository);

  test('deve retornar uma lista com resultados', () async {
    when(
      () => repository.getUsers(
        any(),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<Result>>(
        <Result>[
          Result(
            image: '',
            name: '',
            nickname: '',
            url: '',
          ),
        ],
      ),
    );

    final result = await usecase('jacob');
    expect(result | [], isA<List<Result>>());
  });

  test('deve retornar um EmptyList caso o retorno seja vazio', () async {
    when(() => repository.getUsers(any())).thenAnswer(
      (_) async => const Right<Failure, List<Result>>(
        <Result>[],
      ),
    );

    final result = await usecase('jacob');
    expect(result.isRight(), true);
    expect(result | [], const []);
  });
}
