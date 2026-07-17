/// A minimal Result type so domain/service code can return typed failures
/// instead of relying on exceptions for expected, recoverable error paths
/// (bad OCR input, malformed receipt text, missing model assets, etc).
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(String message) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T get valueOrThrow => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>(:final message) => throw StateError(message),
  };

  R when<R>({
    required R Function(T value) ok,
    required R Function(String message) err,
  }) {
    return switch (this) {
      Ok<T>(:final value) => ok(value),
      Err<T>(:final message) => err(message),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok<T>(:final value) => Result.ok(transform(value)),
      Err<T>(:final message) => Result.err(message),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.message);
  final String message;
}
