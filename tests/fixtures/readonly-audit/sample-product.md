# Fixture Atlas

> Documento 2.1.0 | Estado: partial | Atualizado: 2026-01-02
> Método: fixture-1 | Baselines: repo-a@abc123

## Start Here
Produto fictício para validar recuperação com evidência.

## At a Glance
Fixture Atlas contém cliente e pacote compartilhado. [E-001]

## Índice técnico de tags
| Conceito | Chave | Ocorrências | Perfil/estado |
|---|---|---|---|
| Pacote sintético | package:sample-kit | O-001 | exploratory: declared/resolved; uso do consumidor estático em `repo-a@abc123` |

## Registro técnico e ocorrências
- [T-001] Package `sample-kit`, ecossistema fictício; versão declarada 1.0 e resolvida 1.0.0. [E-003]
- [O-001] T-001; repo-a@abc123; `packages/client/src/client.ts`; sistema `client`; contexto `runtime`; origem `own`; estado `observed_use`; atualidade `current`; não prova exercício/runtime. [E-004]

## Roster de contribuidores
Cobertura parcial: somente os créditos e diffs sintéticos enumerados foram examinados; não representa roster total.
- [P-001] group: equipe sintética observada em [E-002]; identidade individual não resolvida.
- [K-001] contribuição `shared` na integração do pacote no cliente, intervalo do snapshot sintético; fonte [E-002]; atribuição individual desconhecida.

## Study Map
- Contribuição: seção Papel, equipe e contribuições.
- Arquitetura: seção Sistemas e arquitetura.
- Release: seção Timeline e releases.

## Prontidão editorial do projeto
not_applicable: fixture não define um brief ou um plano de portfólio real.

## Revisão opcional da superfície do portfólio
not_applicable: nenhum site/protótipo foi incluído nesta fixture.

## Baseline e preservação
Snapshot sintético `repo-a@abc123`; fixture não corresponde a repositório real. [E-001]

## Identidade e contexto
Fixture Atlas foi identificado no inventário sintético. [E-001]

## Papel, equipe e contribuições
A alteração do pacote foi compartilhada; autoria individual não foi verificada. [E-002] [E-003]

## Sistemas e arquitetura
O cliente referencia o pacote local e possui configuração para consumir um serviço HTTP. Isto é uma observação estática, não prova execução. [E-004]

## Decisões e trade-offs
Não observado na fixture.

## Timeline e releases
A tag sintética `v1` existe, mas não há vínculo entre o artefato e um destino publicado. [E-005]

## Projeção pública e claims
Sem claims autorizadas para publicação.

## Evidências e índice
- [E-001] Inventário sintético do produto e baseline `repo-a@abc123`.
- [E-006] Manifest e lock fictícios de `sample-kit`, usados somente para declarar/resolver a dependência.
- [E-002] Diff sintético no repositório do pacote.
- [E-003] Referência do produto ao pacote na versão sintética.
- [E-004] Código/configuração estática do cliente e endpoint configurado.
- [E-005] Tag sintética sem binário ou destino correlacionado.

## Cobertura e estado das etapas
| Domínio | Estado | Motivo |
|---|---|---|
| B2 performance | not_measured | Nenhuma medição fornecida. |
| Release pública | unresolved | Artefato não correlacionado ao destino. |

## Questões, conflitos e bloqueios
- [Q-001] Qual versão foi entregue publicamente? `unresolved`; procurar artefato correlacionado.
- [Q-002] A aplicação mantém 60 FPS em dispositivos móveis? `not_measured`; não há medição.

## Apêndices
### A1 — Forense
### B1 — Produção e arquitetura
### B2 — Runtime estático
### B3 — Release e procedência
### B4 — Publicação e créditos
### Reconciliação de fontes

## Histórico de verificação
- 2026-01-02: fixture sintética criada para contrato de recuperação.
