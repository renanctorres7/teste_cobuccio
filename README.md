# teste_cobuccio

Aplicativo Flutter de extrato e gestão financeira (desafio técnico). Consome a [API CoinGecko](https://www.coingecko.com/en/api) e mapeia preços/histórico de mercado para o domínio financeiro do app (saldo, entradas, saídas e status).

## Pré-requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) **3.47.6** (canal `stable`)
- Dart SDK compatível (null safety)
- Android SDK (para APK) ou Xcode (iOS, opcional)

Confirme a versão:

```bash
flutter --version
```

## Configuração de ambiente

Segredos e base URL não ficam no código. Use `--dart-define-from-file`:

```bash
cp env.example.json env.json
```

Edite `env.json` se necessário:

```json
{
  "COINGECKO_API_KEY": "",
  "COINGECKO_BASE_URL": "https://api.coingecko.com/api/v3"
}
```

- `env.json` está no `.gitignore`
- `env.example.json` é o template versionado
- chave opcional: se preenchida, é enviada como `x-cg-demo-api-key` (plano Demo da CoinGecko)

## Como rodar

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

Para usar o exemplo sem chave:

```bash
flutter run --dart-define-from-file=env.example.json
```

## Análise e testes

```bash
flutter analyze
flutter test
```

### Cobertura (domínio + ViewModel)

```bash
dart run tool/coverage.dart
```

Roda os testes com cobertura, filtra domínio + ViewModel (≥ 70%) e grava `coverage/domain_viewmodel.info` (gitignored). Detalhe do relatório: [`docs/cobertura.md`](docs/cobertura.md).

Última medição local registrada: **80,6%** (208/258 linhas).

## APK release (ofuscado)

```bash
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define-from-file=env.json
```

| Artefato | Caminho |
|----------|---------|
| APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Debug info (não versionar) | `build/debug-info/` |

O APK de QA está em [GitHub Release v1.0.0](https://github.com/renanctorres7/teste_cobuccio/releases/tag/v1.0.0) (não é commitado na branch).

## CI

Pipeline em [`.github/workflows/ci.yml`](.github/workflows/ci.yml): `analyze`, `test` e build APK debug com `env.example.json`, usando Flutter **3.47.6**.

## Estrutura de pastas

```
lib/
  main.dart
  app/
    app_widget.dart
    core/           # tema, router, DI, rede, erros, widgets, Money
    features/       # dashboard, transactions, transaction_detail
      */domain/     # entidades, use cases, contratos de repositório
      */data/       # datasources, cache, services
      */infra/      # implementações, mappers, models
    presentation/   # Views + ViewModels (Cubits)
docs/               # ADRs e decisões de arquitetura
```

Documentação de arquitetura: [`docs/`](docs/).

## Mapeamento CoinGecko → domínio financeiro

A CoinGecko não entrega extrato bancário. O app adapta endpoints de mercado para entidades financeiras (`CoinMarketMapper`):

| Fonte CoinGecko | Domínio do app |
|-----------------|----------------|
| `GET /coins/{id}/market_chart` (série de preços) | Lista de `TransactionEntity` |
| Variação positiva entre pontos consecutivos | `TransactionTypeEnum.income` (“Valorização …”) |
| Variação negativa | `TransactionTypeEnum.expense` (“Desvalorização …”) |
| `\|Δpreço\| × 100` arredondado | `Money` em centavos |
| Timestamp do ponto (ms) | `occurredAt` em UTC |
| `GET /simple/price` (preço atual × holding 1) | Saldo disponível (`Money`) |
| Hash do id da transação | Status determinístico (completed/pending/failed/refunded) para filtros na UI |

Uma única fonte de verdade (`FinancialSnapshotProvider`) alimenta dashboard, extrato e detalhe, com cache local, deduplicação de requests e retry em HTTP 429.

## Documentação

- [ADR 0001 — Camadas MVVM e fluxo de dados](docs/adr-0001-camadas-mvvm.md)
- [ADR 0002 — Estado com Cubit/Bloc](docs/adr-0002-estado-cubit.md)
- [ADR 0003 — Cache, offline, 429 e erros](docs/adr-0003-cache-offline-erros.md)
- [ADR 0004 — Trade-offs e limitações](docs/adr-0004-trade-offs.md)
- [Relatório de cobertura (domínio + ViewModel)](docs/cobertura.md)
