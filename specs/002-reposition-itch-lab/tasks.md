# Tasks: Modelo de apresentação de projetos a partir de audits

**Input**: [spec revisão 2](spec.md), [plan](plan.md), research/design/data-model, contratos e quickstart desta feature.
**Prerequisites**: planejamento alinhado; seleção do audit real é dependência do piloto, sem bloquear implementação/aceitação sintética.
**Tests**: checks de contratos/fixtures são exigidos pela constituição do framework; não executar projetos-alvo nem fazer TDD de aplicação inexistente.
**Organization**: por história, com execução nova registrada em 2026-10-07. IDs T001–T073 são somente históricos; ver [migration.md](migration.md). Nenhum [X] anterior é herdado.

## Format: `[ID] [P?] [Story] Description`

Paths relativos à raiz; operações resolvem paths absolutos. `[P]` indica arquivos distintos sem dependência entre tarefas do grupo, após pré-requisitos explícitos. Runbook/perfil/fixture/teste abaixo foram entregues nesta implementação; o registro de fechamento distingue testes controlados, piloto draft e aprovação/publicação.

## Phase 1: Setup (Shared Infrastructure)

- [X] T074 Confirmar seleção/recuperação do audit real em `analysis-output/<safe-product-slug>.md`, produto/schema/baseline/IDs e origem; respeitar `produto, schema e baseline ausentes permanecem unknown e geram lacuna explícita`; registrar indisponibilidade no resultado da sessão ou no canônico existente sem criar audit fictício de produto real, usando `specs/002-reposition-itch-lab/quickstart.md` como roteiro. FR-001/025; não bloqueia fixture.
- [X] T075 Revisar integração existente em `.agents/skills/repodna-audit/references/publication-b4.md` e `specs/001-readonly-audit-framework/contracts/portfolio-readiness.md`, delimitar delta e referências para a 002 sem reimplementar facts/roster/tecnologias/confiança. FR-020/024.

## Phase 2: Foundational (Blocking Prerequisites)

- [X] T076 Criar estrutura de `.agents/skills/repodna-audit/references/presentation-format.md` com propósito, entradas/saídas, precondições, gates, evidência, falhas/estados e limites; impor `existe exatamente um Markdown persistente por produto, inclusive texto, rastreabilidade e histórico`, sem alvo executado/escrito ou publicação. FR-002/019/021.
- [X] T077 Documentar extensão opcional editorial 1.0 em `specs/001-readonly-audit-framework/contracts/source-of-truth-markdown.md`, preservando schema factual 2.1.0, headings/IDs existentes e migração no mesmo registro; ausência da extensão significa not_observed, sem reavaliar facts. FR-002/003/020/021.

## Phase 3: US1 — Preparar uma apresentação fiel ao audit (P1)

**Goal**: seleção e rascunho recuperáveis no canônico.
**Independent Test**: caso A/C/F do quickstart, com fonte sintética e pouca evidência; sem canal real ou mídia obrigatórios.

- [X] T078 [US1] Implementar leitura/qualificação de source reference em `.agents/skills/repodna-audit/references/presentation-format.md`, com produto/schema/baseline/estado, origem secundária, conflito e fonte inacessível; reutilizar migração/IDs da 001 e `cada afirmação material tem referência recuperável à fonte no mesmo canônico`. FR-001/003/025/026.
- [X] T079 [US1] Implementar seleção no mesmo runbook `.agents/skills/repodna-audit/references/presentation-format.md` com itens escolhidos/omitidos, rationale/gaps e orientações de voz/referências do autor com origem/estado; aplicar `público, canal, idioma e finalidade têm origem/estado confirmed, provisional ou unknown`; proposta sem brief permanece provisional. FR-004/026.
- [X] T080 [US1] Implementar composição proporcional no runbook `.agents/skills/repodna-audit/references/presentation-format.md` para identidade/premissa, experiência/acesso/contexto/créditos/limites, conteúdo técnico opcional e jogador versus avaliador profissional; preservar voz do autor, distinguir regras de canal/recomendações/escolhas criativas conforme D09–D10 de research, sem estética/headings/história/métrica/mídia obrigatórios. FR-005/006/007.
- [X] T081 [US1] Implementar no mesmo runbook `.agents/skills/repodna-audit/references/presentation-format.md` wording para individual/shared/integrated/unknown, relatos/conflitos e resultado externo limitado; crédito não prova exclusividade, stack coletiva não prova experiência e not_measured não prova impacto. FR-008/009.
- [X] T082 [US1] Criar `tests/fixtures/readonly-audit/presentation-model/sample-product.md` como canônico único de produto fictício, com facts/IDs da 001, fonte primária/secundária, poucos dados, autoria compartilhada/desconhecida, resultado sem medição e seleção genérica; todos os valores particulares excluídos. FR-001–009/022/026; SC-001/003/004.
- [X] T083 [US1] Conferir no mesmo `tests/fixtures/readonly-audit/presentation-model/sample-product.md` as rotas e omissões dos casos A/C/F; documentar observações/gaps sem inventar prova nem declarar pesquisa humana. FR-003/026; SC-001/003/004/010. Depende de T078–T082.

## Phase 4: US2 — Adaptar os mesmos fatos ao destino (P1)

**Goal**: perfil itch.io e alternativa fictícia em texto simples.
**Independent Test**: caso B, duas representações coerentes dos mesmos facts; nenhuma compatibilidade com segunda loja real alegada.

- [X] T084 [US2] Criar `.agents/skills/repodna-audit/references/channel-itch.md` com capacidades/fontes/data oficiais, descrição/metadados/mídia/UI nativa, plataformas/idiomas sustentados e limites não documentados como unknown; seguir `canal real tem fonte e data; canal fictício tem declaração explícita e não alega compatibilidade real`. FR-010/011/013.
- [X] T085 [P] [US2] Acrescentar em `.agents/skills/repodna-audit/references/presentation-format.md` o perfil fictício: texto simples, nome/resumo essenciais, sem mídia incorporada/UI nativa/HTML/CSS, demais dimensões opcionais, sem limite numérico presumido e sem alegação de loja real. FR-010/012/013. Depende de T080; independente de T084.
- [X] T086 [US2] Acrescentar ao runbook `.agents/skills/repodna-audit/references/presentation-format.md` mapeamento por canal de descrição/metadados/mídia/ações, omissões e fallback, bloqueando campo essencial ausente ou claim cuja ressalva não cabe. FR-010–013/026. Depende de T084/T085.
- [X] T087 [US2] Delimitar texto público e matriz interna em `.agents/skills/repodna-audit/references/presentation-format.md`; aplicar `texto público não contém IDs internos, segredos ou marcadores de trabalho e preserva ressalvas essenciais`, com rotas factual e dependências fora do bloco público no mesmo canônico. FR-003/014/021.
- [X] T088 [US2] Inserir no `tests/fixtures/readonly-audit/presentation-model/sample-product.md` as duas representações dos mesmos facts, uma itch.io e outra fictícia texto simples, com orientações fictícias de voz e adaptação deliberada por público; incluir caso de campo obrigatório ausente/ressalva que não cabe sem preencher dado fictício como fato. FR-004/006/010–014/026; SC-002/010.
- [X] T089 [US2] Conferir coerência factual, informações omitidas, ressalvas e preservação/adaptação justificada da voz entre as representações em `tests/fixtures/readonly-audit/presentation-model/sample-product.md`; registrar resultado do caso B e lacunas, sem publicação/renderização/compatibilidade presumidas. FR-004/006/012/013/014; SC-002/010. Depende de T088.

## Phase 5: US3 — Revisar e atualizar sem perder procedência (P2)

**Goal**: decisões, freshness e prontidão por dimensão preservados no registro.
**Independent Test**: casos D/E, mídia bloqueada com texto seguro e alteração de baseline após aceitação.

- [X] T090 [US3] Implementar no runbook `.agents/skills/repodna-audit/references/presentation-format.md` registro/seleção de mídia com claim demonstrada, origem/era/atribuição; aplicar `mídia conserva permissão por link, embed, cópia/crop, rehosting e áudio, com desconhecidos explícitos`, sem republicar assets. FR-015.
- [X] T091 [US3] Implementar decisões no mesmo runbook `.agents/skills/repodna-audit/references/presentation-format.md` com versão anterior/responsável/data/escopo/motivo e referência à decisão humana explícita para accepted; aplicar `decision é draft/accepted/corrected/rejected; freshness é current/stale`; sugestão do agente fica draft, corrigido espera aceitação, rejeitado não é pronto; confiança factual permanece independente. FR-016/018.
- [X] T092 [US3] Implementar dependências/retomada no runbook `.agents/skills/repodna-audit/references/presentation-format.md`; aplicar `alteração material de baseline, evidência, seleção ou redação marca dependências stale e invalida aprovação afetada`, preservando decisão histórica e exigindo revalidação antes de nova aceitação. FR-017.
- [X] T093 [US3] Integrar prontidão em `.agents/skills/repodna-audit/references/publication-b4.md` por referência ao novo runbook, com `readiness reutiliza complete, complete_with_conditions, incomplete_blocking, incomplete_nonblocking ou optional por dimensão`; distinguir texto, ownership, resultados, mídia/permissões, runtime e estado público. FR-009/015/018/026.
- [X] T094 [US3] Acrescentar histórico/decisão/retomada e mídia permission_unknown em `tests/fixtures/readonly-audit/presentation-model/sample-product.md`, mantendo versão anterior e afirmações sem resultado/runtime inventados; cenário stale não pronto e texto independente não bloqueado. FR-015–018/026; SC-005/006.
- [X] T095 [US3] Executar revisão guiada dos casos D/E no registro `tests/fixtures/readonly-audit/presentation-model/sample-product.md`, anotar observações de público/canal/estado/gap/rota de evidência e limites; diferenciar revisão do agente de observação humana real. FR-016–018/026; SC-005/006/010. Depende de T094.

## Phase 6: US4 — Reutilizar o método com privacidade (P2)

**Goal**: capacidade acessível pelo método local com exemplos fictícios e sem acervo privado.
**Independent Test**: caso G e inventário de preservação H; método utilizável sem conta externa/dados particulares.

- [X] T096 [US4] Integrar a capacidade em `.agents/skills/repodna-audit/SKILL.md`, referências de `workflow.md` e `consolidation.md`, preservando preflight/estados da 001 e subseções de seleção/representações no canônico; sem execução/exportação, método não depende de fontes privadas. FR-019/020/021. Depende de US1–US3.
- [X] T097 [P] [US4] Criar `tests/fixtures/readonly-audit/presentation-model/README.md` com casos A–H, setup sintético, perguntas/expected outcomes SC-001–010 e boundaries; nunca copiar material do acervo privado/targets para fixtures. FR-022/026. Depende de T094; independente de T096.
- [X] T098 [US4] Rever `specs/002-reposition-itch-lab/migration.md` e inventário de migração privado selecionado pelo operador como entrada opcional local, confirmar originais/preservação individual e ausência de referências ativas ao acervo retirado; se acervo ausente, validar regra pela correspondência generalizada sem fingir nova conferência de hashes. FR-023/024; SC-008/009.
- [X] T099 [US4] Criar `tests/publication_format_contract_test.sh` com checks de rotas/limites, dois canais, pouca evidência, atribuição, resultado, mídia, decisão/stale, privacidade e canônico único; receber apenas fixture controlada e recusar targets/outputs reais, sem executar conteúdo de fixture. FR-001–026; SC-001–007/009. Depende de T082/T088/T094/T097.

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T100 Integrar o check novo a `tests/run.sh` no fluxo de framework com isolamento sintético e atualizar `README.md` sobre uso do modelo, limites e fonte única, sem apresentar catálogo/preview/publicação como capacidades. FR-019–022. Depende de T096/T099.
- [X] T101 Executar check de apresentação e checks pertinentes de canônico/B4/privacidade conforme `tests/run.sh` e `scripts/check-public-context.py`, revisar referências locais alteradas e registrar resultados na seção de verificação de `tests/fixtures/readonly-audit/presentation-model/sample-product.md`/documentação da fixture, com limites da revisão binária/humana; não inspecionar targets reais. FR-019/021/022/026; SC-001–007/009.
- [X] T102 Revisar documentação/fixture e registrar avaliação guiada SC-010 em `tests/fixtures/readonly-audit/presentation-model/sample-product.md`, incluindo origem das orientações de voz e como foram preservadas/adaptadas; preparar piloto real só se T074 selecionou audit original, mantendo suas representações em `analysis-output/<safe-product-slug>.md`, ou registrar dependência aberta sem inventar resultado. FR-004/006/025/026; SC-010. Depende de T101.
- [X] T103 Atualizar estados e correspondência final em `specs/002-reposition-itch-lab/quickstart.md`, `plan.md` e `tasks.md`, separando método validado/piloto pendente, histórico da migração e implementação efetiva, sem herdar [X] antigos ou alegar aprovação/publicação. FR-023–026; SC-008/010. Depende de T098/T101/T102.

## Dependencies & Execution Order

T074 é primeira dependência do piloto real; se unavailable, manter esse ramo pendente e prosseguir no sintético. T075 → T076 → T077 → US1 (T078–T083) → US2 (T084–T089) → US3 (T090–T095) → US4 (T096–T099) → acabamento (T100–T103). Revalidação de statements deve preceder aprovação; nunca usar resultado de uma tarefa como autorização para publicar.

Cada história tem teste independente acima, usando pré-requisitos comuns. T099 valida contrato completo após as histórias; não substitui revisão guiada e não certifica facts/permissões de produto real.

## Parallel Execution Examples

- Após T083: T084 escreve perfil itch e T085 escreve definição fictícia em arquivo distinto; T086 depende de ambos.
- Após T095: T096 integra método enquanto T097 documenta fixture; arquivos distintos, T099 aguarda T097.
- Outras tarefas que escrevem o mesmo runbook/fixture devem ser sequenciais; marcação P não autoriza concorrência em arquivo compartilhado.

## Implementation Strategy

US1 entrega seleção/rascunho genérico rastreável. US1 + US2 é o MVP de forma reutilizável por dois canais. US3 acrescenta manutenção segura; US4 integra método/validação/privacidade. Escolha do audit real não bloqueia desenvolvimento sintético, mas bloqueia conclusão do piloto real. Implementação concluída em 2026-10-07: método e fixtures disponíveis, piloto editorial importado/preparado; nenhum envio, publicação ou execução do alvo.

## Coverage and Completion

| Requisito revisão 2 | Tarefas |
|---|---|
| FR-001 | T074/T078/T082 |
| FR-002 | T076/T077 |
| FR-003 | T077/T078/T083/T087 |
| FR-004 | T079 |
| FR-005 | T080 |
| FR-006 | T080 |
| FR-007 | T080/T081 |
| FR-008 | T081/T082 |
| FR-009 | T081/T093 |
| FR-010 | T084/T085/T086 |
| FR-011 | T084/T086 |
| FR-012 | T085/T086/T089 |
| FR-013 | T084/T085/T088/T089 |
| FR-014 | T087/T088/T089 |
| FR-015 | T090/T093/T094 |
| FR-016 | T091/T095 |
| FR-017 | T092/T094/T095 |
| FR-018 | T091/T093/T095 |
| FR-019 | T076/T096/T100/T101 |
| FR-020 | T075/T077/T096 |
| FR-021 | T076/T077/T087/T096/T101 |
| FR-022 | T082/T097/T099/T101 |
| FR-023 | T098/T103 |
| FR-024 | T075/T098/T103 |
| FR-025 | T074/T078/T102/T103 |
| FR-026 | T078/T079/T083/T086/T094/T095/T097/T101/T102/T103 |

SC-001→T083/T099/T101; SC-002→T088/T089/T099; SC-003/004→T082/T083/T099; SC-005/006→T094/T095/T099; SC-007→T099/T101; SC-008→T098/T103; SC-009→T097/T099/T101; SC-010→T083/T089/T095/T102/T103.

30 tarefas novas: setup 2, foundation 2, US1 6, US2 6, US3 6, US4 4, acabamento 4. Todas concluídas com evidência desta execução; a preservação/reescrita anterior continua histórica em migration.md e não foi herdada como aceitação operacional.

## Implementation closeout — 2026-10-07

T074–T075: seleção/importação e preservação de identidade/schema/baseline/IDs verificadas; resultados particulares permanecem no contexto privado; delta B4/001 reutilizado. T076–T081: runbook com gates, fonte/seleção, composição, voz e limites; contrato opcional 1.0 sobre facts 2.1.0. T082–T083: fixture canônica fictícia e revisão A/C/F. T084–T089: perfil itch datado, cenário fictício, duas variantes/rotas e revisão de coerência/voz. T090–T095: permissões por ação, decisões, invalidade de stale, prontidão e revisão D/E. T096–T099: integração à skill/workflow/consolidação, casos A–H, preservação conferida e teste de contrato.

T100–T103: runner/README integrados; 17 checks de framework passaram, novo contrato rejeitou 14 mutações e argumento fora da fixture, links e guard público passaram. Conferência histórica de migração: preservação e retirada verificadas no recorte registrado, com trabalho não relacionado mantido; detalhes do acervo permanecem privados. Revisão guiada pelo agente em fixture/piloto, sem alegar estudo humano ou medição temporal. Método implementado e piloto preparado como draft; confirmação do autor, permissões e publicação não são conclusão de implementação nem exigência de executar o alvo.

O check local_method foi adaptado para permitir somente as três citações oficiais do perfil itch como evidência de canal; instruções continuam locais/offline. Antes/depois de implement, extensions.yml ausente; nenhum hook. Não houve commit, alteração de página externa, execução de alvo ou cópia de material privado para testes.

## Phase 8: Convergence

- [X] T104 Validar que a referência humana de accepted resolve a uma decisão explícita no histórico da fixture em `tests/publication_format_contract_test.sh`, com mutação negativa de referência inexistente, sem ler fontes privadas ou targets, per FR-016 / US3/AC1 / T099 (partial, MEDIUM, F1).
- [X] T105 Atualizar metadados e frase de estado pendente em `specs/002-reposition-itch-lab/spec.md` para refletir execução já concluída, preservando requisitos, critérios, origem/histórico e drafts não aprovados, per T103 / plan: Implementation Verification (partial, LOW, F2).

Correção implementada em 2026-10-07: T104 verifica referência no histórico e que ela indica aceitação explícita, rejeitando referência inexistente; T105 atualiza apenas metadados/estado da spec, sem mudar requisitos. Suíte reexecutada: 17/17 checks passaram, 15 mutações negativas rejeitadas. Hooks before/after_implement ausentes nesta passagem. Total: 32 tarefas concluídas (30 originais e 2 corretivas), aguardando nova convergência.

## Phase 9: Consolidação e reuso — revisão 3

- [X] T106 Atualizar spec, plano, contratos e constituição IV para destino canônico existente e derivados privados solicitados, per FR-021/027 e SC-007/011.
- [X] T107 Criar modelo neutro com matriz de finalidade/origem/uso/omissão/cuidados e esqueleto preenchível; integrar ao runbook e canal, per FR-028 / US5/AC3 / SC-012.
- [X] T108 Salvar HTML/CSS finais e decisões de aplicação no espaço privado, preservando texto validado e distinguindo a fonte escolhida no tema do tamanho definido no CSS, per FR-029/030 / US5/AC2.
- [X] T109 Consolidar acréscimos/histórico/versão atual no relatório original escolhido, conferir preservação antes de remover a cópia redundante e atualizar referências, per FR-027 / US5/AC1 / SC-011.
- [X] T110 Atualizar método, contratos, desenho, retomada e README para o fluxo vigente, mantendo origem dos estados históricos e dados privados fora de exemplos/testes, per FR-021/028/029.
- [X] T111 Executar checks pertinentes do framework, revisão de links/coerência e converge sem novos testes da página, per FR-030 / SC-011/012.


Revisão 3 implementada em 2026-10-07: T106–111 concluídas. Constituição 4.0.0, fonte única existente, modelo neutro e derivados privados vinculados; conteúdo original/IDs e extensão histórica conferidos antes da retirada da cópia. Versão e escolhas registradas no contexto de aplicação; recomendações não confirmadas permanecem provisional. Nenhum dado real acrescentado aos exemplos/testes, nenhum alvo/site executado ou alterado, nenhum commit/staging alterado. Suíte 17/17 passou; após limpeza das instruções, os quatro checks afetados passaram novamente com 15 mutações negativas; links em 28 documentos e guard público passaram. Validação da página fornecida pelo usuário não foi repetida. Hooks ausentes. Total: 38 tarefas concluídas; iniciar converge sobre estado atual.

## Phase 10: Skill independente itch.io — revisão 4

- [X] T112 Atualizar feature 002, plano/checklist e governança para entradas separadas, per FR-031–035 / US6 / SC-013–014.
- [X] T113 Criar `.agents/skills/repodna-itch-format/SKILL.md` com resolução de entrada, composição interna e entrega/registro, per FR-031–033 / US6/AC1–4.
- [X] T114 Mover perfil para `.agents/skills/repodna-itch-format/references/channel-itch.md`, atualizar callers/checks e remover original redundante, per FR-034 / SC-014.
- [X] T115 Atualizar handoff audit, contratos/desenho/README e exemplos de chamadas sem execução automática, per FR-034 / US6/AC5.
- [X] T116 Revisar os quatro contextos de entrada e entrega com fixture fictícia, sem executar a skill sobre dados reais; conferir hashes de preservação, per FR-035 / SC-013–014.
- [X] T117 Executar quick_validate, checks pertinentes, links/privacidade e converge, per FR-031–035 / SC-013–014.


Revisão 4 implementada: T112–117 concluídas, total de 44 tarefas. quick_validate oficial e suíte 17/17 passaram; 15 casos negativos, links em 29 documentos, fonte de canal única e preservação por hashes conferidos. Revisão guiada dos quatro contextos em fixture está documentada como manual do agente, não teste independente de execução. Nenhum dado real alterado ou usado para composição. Hooks ausentes; iniciar convergência sobre implementação atual.


## Phase 11: Documentação compartilhável neutra — revisão 5

- [X] T118 Identificar referências particulares no README, skills, documentos da feature, contratos e exemplos/testes; atualizar escopo FR-036–038/SC-015 sem alterar dados privados, per FR-022/036 / US4/AC5.
- [X] T119 Generalizar descrições de acervo/piloto e decisões particulares, preservando IDs, correspondência de migração, resultados e limites das verificações, per FR-037 / SC-015.
- [X] T120 Neutralizar exemplos e instruções das skills/referências sem estética, idioma ou ordem obrigatórios; manter arquitetura e fontes legítimas, per FR-006/034/036.
- [X] T121 Validar skills alteradas, checks afetados, links, ausência dos termos particulares identificados e staging; concluir converge com alcance/limites explícitos, per FR-038 / SC-015.


Revisão 5 implementada: T118–121 concluídas, total de 48 tarefas. Contexto particular generalizado, IDs e referências preservados, arquitetura inalterada. Dois validadores oficiais, 17/17 checks, 15 casos negativos e links em 28 documentos passaram; busca delimitada em 145 arquivos não encontrou os marcadores identificados. Revisão manual/busca têm alcance declarado, sem garantia absoluta de privacidade. Materiais privados/externos não foram alterados nem usados para composição; staging preservado; sem commit/publicação. Hooks before/after_implement ausentes. Iniciar converge do estado atual.
