import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart';
import 'package:search/app/search/infra/datasources/search_datasource.dart';
import 'package:search/app/search/infra/models/result_model.dart';

part 'github_search_datasource.g.dart';

@Injectable(singleton: false)
class GithubSearchDatasource implements SearchDatasource {
  final Client client;

  GithubSearchDatasource(this.client);

  @override
  Future<List<ResultModel>> searchText(String textSearch) async {
    final result = await client
        .get("https://api.github.com/search/users?q=${textSearch.trim().replaceAll(' ', '+')}");
    if (result.statusCode == 200) {
      final json = jsonDecode(result.body);
      debugPrint('execute datasource');
      final jsonList = json['items'] as List;
      final list = jsonList
          .map(
            (item) => ResultModel(
              name: '',
              nickname: item['login'],
              image: item['avatar_url'],
              url: item['url'],
            ),
          )
          .toList();
      return list;
    } else {
      throw Exception();
    }
  }
}
