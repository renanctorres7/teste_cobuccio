// Gera cobertura filtrada (domínio + ViewModel) e imprime o resumo.
//
// Uso (na raiz do projeto):
//   dart run tool/coverage.dart
import 'dart:io';

const _thresholdPercent = 70.0;

bool _includeSource(String sf) {
  // Flutter emits relative paths like `lib/app/...` (no leading slash).
  final normalized = sf.replaceAll('\\', '/');
  if (normalized.contains('lib/app/core/domain/')) {
    return true;
  }
  if (normalized.contains('lib/app/features/') &&
      normalized.contains('/domain/')) {
    return true;
  }
  if (normalized.contains('lib/app/presentation/') &&
      normalized.contains('/view_model/')) {
    return true;
  }
  return false;
}

Future<void> main() async {
  stdout.writeln('→ flutter test --coverage');
  final test = await Process.start(
    'flutter',
    ['test', '--coverage'],
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
  final testCode = await test.exitCode;
  if (testCode != 0) {
    stderr.writeln('flutter test --coverage falhou (exit $testCode).');
    exit(testCode);
  }

  final lcovFile = File('coverage/lcov.info');
  if (!lcovFile.existsSync()) {
    stderr.writeln('Arquivo coverage/lcov.info não encontrado.');
    exit(1);
  }

  final filtered = _filterLcov(lcovFile.readAsStringSync());
  final outFile = File('coverage/domain_viewmodel.info')
    ..createSync(recursive: true);
  outFile.writeAsStringSync(filtered.content);

  final pct = filtered.found == 0
      ? 0.0
      : (100.0 * filtered.hit / filtered.found);

  stdout.writeln('');
  stdout.writeln('Cobertura domínio + ViewModel');
  stdout.writeln('  Linhas: ${filtered.hit} / ${filtered.found}');
  stdout.writeln('  Percentual: ${pct.toStringAsFixed(1)}%');
  stdout.writeln('  Meta: ≥ ${_thresholdPercent.toStringAsFixed(0)}%');
  stdout.writeln('  Saída: coverage/domain_viewmodel.info');

  if (pct + 1e-9 < _thresholdPercent) {
    stderr.writeln(
      'Cobertura ${pct.toStringAsFixed(1)}% abaixo da meta '
      '${_thresholdPercent.toStringAsFixed(0)}%.',
    );
    exit(1);
  }

  stdout.writeln('Meta atingida.');
}

typedef _LcovStats = ({String content, int hit, int found});

_LcovStats _filterLcov(String raw) {
  final buffer = StringBuffer();
  final current = StringBuffer();
  String? sf;
  var include = false;
  var hit = 0;
  var found = 0;
  var recordHit = 0;
  var recordFound = 0;

  void flush() {
    if (!include || sf == null) {
      current.clear();
      sf = null;
      include = false;
      recordHit = 0;
      recordFound = 0;
      return;
    }
    buffer.write(current);
    hit += recordHit;
    found += recordFound;
    current.clear();
    sf = null;
    include = false;
    recordHit = 0;
    recordFound = 0;
  }

  for (final line in raw.split('\n')) {
    if (line.startsWith('SF:')) {
      flush();
      sf = line.substring(3);
      include = _includeSource(sf!);
      current.writeln(line);
      continue;
    }

    if (sf == null) {
      continue;
    }

    current.writeln(line);

    if (line.startsWith('LH:')) {
      recordHit = int.tryParse(line.substring(3)) ?? 0;
    } else if (line.startsWith('LF:')) {
      recordFound = int.tryParse(line.substring(3)) ?? 0;
    } else if (line == 'end_of_record') {
      flush();
    }
  }
  flush();

  return (content: buffer.toString(), hit: hit, found: found);
}
