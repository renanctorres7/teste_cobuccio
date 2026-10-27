import 'package:flutter_test/flutter_test.dart';
import 'package:teste_cobuccio/app/core/errors/failures.dart';
import 'package:teste_cobuccio/app/core/errors/result.dart';

void main() {
  test('Success when/map', () {
    const result = Success<int>(2);
    expect(result.isSuccess, isTrue);
    expect(result.isFailure, isFalse);
    expect(result.when(success: (v) => v * 2, error: (_) => -1), 4);
    final mapped = result.map((v) => v.toString());
    expect(mapped, isA<Success<String>>());
    expect((mapped as Success<String>).data, '2');
  });

  test('Error when/map', () {
    const result = Error<int>(NetworkFailure());
    expect(result.isSuccess, isFalse);
    expect(result.isFailure, isTrue);
    expect(
      result.when(success: (_) => 0, error: (f) => f),
      const NetworkFailure(),
    );
    final mapped = result.map((v) => v.toString());
    expect(mapped, isA<Error<String>>());
    expect((mapped as Error<String>).failure, const NetworkFailure());
  });
}
