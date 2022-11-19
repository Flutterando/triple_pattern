class Failure implements Exception {
  const Failure();
}

class InvalidSearchText extends Failure {
  const InvalidSearchText();
}

class EmptyList extends Failure {
  const EmptyList();
}

class ErrorSearch extends Failure {
  const ErrorSearch();
}

class DatasourceResultNull extends Failure {
  const DatasourceResultNull();
}
