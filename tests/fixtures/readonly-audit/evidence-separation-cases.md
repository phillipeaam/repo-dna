# Casos sintéticos de separação de evidência

| Caso | Entrada | Estado/saída esperada | Inferência proibida |
|---|---|---|---|
| A1 | Dois autores com o mesmo nome e emails divergentes | Identidade `unknown`/`unverified`; pedir confirmação | Fundir aliases automaticamente |
| A2 | README planeja sync, sem implementação encontrada no escopo | `planned_only` ou `not_found_in_scope`, conforme cobertura | Declarar sistema implementado |
| B3 | Tag e data de release sem binário ou link de destino | `unresolved` para o elo sem suporte | Tratar proximidade temporal como prova do release |
| B2 | Apenas build config tem target frame rate de 60 FPS | `static_fact` sobre configuração; runtime `not_measured` | Afirmar FPS alcançado |
| B2 | Arquivo de build tem tamanho medido | Medição de tamanho do artefato com unidade | Tratar como memória em runtime |
| B2 | Benchmark tem ambiente/snapshot distintos antes e depois | Comparação não equivalente; limites explícitos | Alegar ganho/regressão comparável |
| B2 | Cena de demo e nenhum teste automatizado | Demo observada como conteúdo; teste `not_observed` | Classificar demo como teste |
| B2 | Ferramenta/profiler está configurado mas não há resultado | Configuração observada; resultado `not_measured` | Alegar gargalo/otimização verificada |
| A1 | Contribuição em pacote consumido por dois produtos | Identidade compartilhada, cada elo referenciado, contabilizada uma vez | Duplicar contribuição por consumidor |
