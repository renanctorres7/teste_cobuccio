# ADR 0002 — Estado com Cubit / Bloc

## Contexto

O enunciado exige gerenciamento de estado com estados imutáveis e escolha justificada (Provider, Riverpod ou Bloc).

## Decisão

Usar **flutter_bloc** com **Cubit** (sem eventos explícitos) por tela:

- `DashboardCubit` / `DashboardState`
- `TransactionsCubit` / `TransactionsState`
- `TransactionDetailCubit` / `TransactionDetailState`

Estados modelados como hierarquia selada/imutável (`Loading`, `Success`, `Failure`, e variantes de sucesso com flags como `isFromCache` e `isOffline`).

Cubits registrados como **factory** no GetIt (nova instância por tela), consumindo use cases e `NetworkInfo`.

## Por quê Cubit

- Fluxo das telas é linear (`load`, filtros, pull-to-refresh): eventos nomeados do Bloc adicionariam boilerplate sem ganho claro.
- Integra bem com testes (`bloc_test` / asserts em estados emitidos).
- Ecossistema maduro e alinhado a times Flutter plenos.


## Consequências

- UI reativa via `BlocBuilder` / `BlocListener`.
- Falhas tipadas (`Failure`) chegam à View sem exceções cruas.
- Escuta de conectividade nos Cubits atualiza banners offline sem misturar isso à View.
