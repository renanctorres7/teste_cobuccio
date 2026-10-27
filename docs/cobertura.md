# Relatório de cobertura (domínio + ViewModel)

Entregável de qualidade do desafio: cobertura mínima de **70%** nas camadas de **domínio** e **ViewModel**, com relatório gerado.

## Meta

| Escopo | Meta |
|--------|------|
| `lib/app/core/domain/**` | Incluído |
| `lib/app/features/*/domain/**` | Incluído |
| `lib/app/presentation/*/view_model/**` | Incluído |
| Data, infra, widgets, pages, DI, router | **Fora** do filtro (não entram na meta de 70%) |

A meta do enunciado é explícita para domínio e ViewModel. UI, mappers e rede têm testes (widget/integração/unitários), mas não entram neste percentual.

## Como gerar

Na raiz do projeto (um único comando):

```bash
dart run tool/coverage.dart
```

O script:

1. Roda `flutter test --coverage` → `coverage/lcov.info`
2. Filtra domínio + ViewModel → `coverage/domain_viewmodel.info`
3. Imprime o resumo e **falha** se a cobertura ficar abaixo de 70%

Não exige o binário `lcov` instalado. Os arquivos em `coverage/` não são versionados (ver `.gitignore`). Este documento é o registro permanente do relatório.

### Equivalente manual (opcional)

Com [`lcov`](https://github.com/linux-test-project/lcov) instalado (`brew install lcov`):

```bash
flutter test --coverage
lcov --extract coverage/lcov.info \
  '*/lib/app/core/domain/*' \
  '*/lib/app/features/*/domain/*' \
  '*/lib/app/presentation/*/view_model/*' \
  -o coverage/domain_viewmodel.info
lcov --summary coverage/domain_viewmodel.info
```

## Última medição registrada

| Campo | Valor |
|-------|--------|
| Data de referência | 2026-10-27 (`dart run tool/coverage.dart`) |
| Linhas cobertas (LH / LF) | **208 / 258** |
| Cobertura (linhas) | **80,6%** |
| Meta do enunciado | ≥ 70% |
| Resultado | **Atingida** |

Regenerar com `dart run tool/coverage.dart` sempre que a suíte ou o código de domínio/ViewModel mudar de forma relevante.

## Pirâmide relacionada

Além da cobertura filtrada:

- Unitários: domínio, Cubits, repositórios/mappers, rede (retry, etc.)
- Widgets: estados de loading / vazio / erro nas telas principais
- Integração: fluxo dashboard → extrato → detalhe (`test/integration/`)

Detalhes de arquitetura: [ADRs](README.md).
