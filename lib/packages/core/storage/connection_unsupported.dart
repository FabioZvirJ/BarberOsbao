import 'package:drift/drift.dart';

QueryExecutor connect() {
  throw UnsupportedError(
    'Platform not supported. You must implement a database connection for this platform.',
  );
}
