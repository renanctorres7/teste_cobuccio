# ADR 0004 — Trade-offs e limitações conhecidas

## Contexto

O desafio usa CoinGecko free tier e pede transparência sobre trade-offs e limitações.

## Trade-offs aceitos

| Escolha | Ganho | Custo |
|---------|-------|-------|
| Mapear preços → extrato sintético | Domínio financeiro completo sem backend próprio | Transações não são bancárias reais; status é determinístico por hash |
| SharedPreferences para cache | Simples, suficiente para chart/preço | Sem criptografia; volume limitado; inadequado para dados sensíveis reais |
| Release assinado com keystore debug (dev) | APK instalável para QA sem setup de keystore | Não é assinatura de produção |
| Cubit + GetIt | Clareza e testabilidade | Duas libs de “wiring” em vez de um único framework (ex.: Riverpod) |
| CI só com APK debug | Pipeline rápido e estável | Release ofuscado gerado localmente e publicado em GitHub Release |

## Limitações

1. **CoinGecko free tier** — Rate limit agressivo (429). Mitigado com retry/backoff, cache e dedupe; ainda assim bursts podem falhar após esgotar retentativas.
2. **Conectividade ≠ internet** — `connectivity_plus` indica interface de rede ativa, não reachability real do host. Um Wi‑Fi captive portal pode aparecer como “online” e ainda assim falhar na API (cai no fallback de cache/erro).
3. **Holding fictício (1 unidade)** — Saldo = preço atual × 1; não modela carteira multi-ativo.
4. **Sem certificate pinning / biometria / Sentry** — Diferenciais opcionais; ficam como evolução.
5. **Ofuscação** — `--obfuscate` + `split-debug-info` no build release; símbolos em `build/debug-info/` **não** são versionados (necessários só para desofuscar stack traces).

## Evolução sugerida (pós-desafio)

- Backend próprio de extrato (ou BFF) em vez de heurística de mercado.
- Keystore de release e Play App Signing.
- Cache com TTL explícito e invalidação.
- Pinning e observabilidade se for para produção.
