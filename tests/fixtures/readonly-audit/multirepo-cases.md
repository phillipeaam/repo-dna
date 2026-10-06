# Casos sintéticos multi-repositório

| Produto | Repositório | Papel | Baseline | Relação |
|---|---|---|---|---|
| Atlas | `atlas-client` | cliente | `client@c1` | produto principal |
| Atlas | `atlas-shared` | pacote compartilhado | `shared@p1` | versão `1.2.0` consumida por Atlas |
| Atlas | `atlas-service` | serviço | `service@s1` | serviço explicitamente confirmado pelo usuário |
| Atlas Next | `atlas-next` | sucessor | `next@n1` | produto separado; não fundir automaticamente |
| Unknown Stack | `opaque-repo` | desconhecido | `opaque@o1` | stack não identificada; manter análise genérica |

Contribuição `F-010` no pacote `atlas-shared` recebe uma identidade estável; evidências de package/ref, versão `1.2.0`, consumidores e releases são ligadas individualmente. No registro Atlas, a contribuição consolidada é contada uma vez mesmo que dois consumidores referenciem o mesmo pacote. O registro Atlas Next continua distinto. Domínio sem suporte na stack desconhecida recebe `not_applicable` ou `not_observed` com justificativa, sem listas inventadas.
