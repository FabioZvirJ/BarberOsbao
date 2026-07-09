import 'package:flutter/foundation.dart';

@immutable
sealed class AppState<T> {
  const AppState();

  bool get isLoading => this is AppLoading<T>;
  bool get isSuccess => this is AppSuccess<T>;
  bool get isEmpty => this is AppEmpty<T>;
  bool get isError => this is AppError<T>;
  bool get isRefreshing => this is AppRefreshing<T>;

  T? get data {
    final state = this;
    if (state is AppSuccess<T>) return state.data;
    if (state is AppRefreshing<T>) return state.data;
    return null;
  }
}

class AppLoading<T> extends AppState<T> {
  const AppLoading();
}

class AppSuccess<T> extends AppState<T> {
  @override
  final T data;
  const AppSuccess(this.data);
}

class AppEmpty<T> extends AppState<T> {
  const AppEmpty();
}

class AppError<T> extends AppState<T> {
  final String message;
  const AppError(this.message);
}

class AppRefreshing<T> extends AppState<T> {
  @override
  final T data;
  const AppRefreshing(this.data);
}
