# Implementation Plan: Modelo de apresentação de projetos a partir de audits

**Branch**: `feature/002-reposition-itch-lab` | **Date**: 2026-10-06 | **Spec**: [spec.md](spec.md)

**Input**: Revisão 5 da feature 002; [migração](migration.md) preserva correspondência e evolução do método, sem contexto particular obrigatório.

## Summary

Estender a etapa editorial da skill RepoDNA para consumir o Markdown canônico existente, selecionar conteúdo por público/idioma e manter representações por canal dentro desse mesmo arquivo. A extensão compartilha claims, evidências, contribuições e tecnologias da 001. Um método/modelo genérico compartilhado e a skill repodna-itch-format com seu perfil itch.io orientam a composição; um cenário fictício sem HTML comprova a adaptação. Não há gerador, catálogo ou sistema de publicação.

## Technical Context

**Language/Version**: Markdown UTF-8; contrato factual 2.1.0 existente, extensão editorial opcional 1.0. Python 3.11+ e Bash apenas para verificações controladas do framework, nunca para executar alvos.

**Primary Dependencies**: Skills `.agents/skills/repodna-audit/SKILL.md` e `.agents/skills/repodna-itch-format/SKILL.md`, runbooks B4/consolidação, contratos da feature 001 e documentação oficial itch.io. Nenhum pacote/serviço/credencial novo.

**Storage**: Um relatório Markdown por produto: audit externo existente escolhido pelo usuário ou `analysis-output/<safe-product-slug>.md` por padrão. Derivados privados solicitados em `private-context/presentation-applications/<slug>/`, sem relatório próprio. Seleção, texto público, metadados sugeridos, mídia, rastreabilidade e decisões ficam em subseções do canônico. Pesquisa privada opcional em `private-context/`, ignorada e excluída da distribuição.

**Testing**: Cenários sintéticos do framework; checks de rastreabilidade, saída única, privacidade, adaptação e transições; revisão guiada qualitativa. Não rodar suites/builds de alvos. Não alegar avaliação humana sem observações registradas.

**Target Platform**: Agente local em Windows/Linux/macOS; destinatário editorial itch.io e cenário fictício de texto simples. Loja real adicional depende de pesquisa futura.

**Project Type**: Extensão de método e contratos, sem aplicação executável.

**Performance Goals**: Integridade e leitura guiada SC-001–015; sem SLA, métrica comercial ou ganho de compreensão presumido.

**Constraints**: Procedimento estático, privacidade, ausência de publicação/execução, Markdown único, fonte local autoritativa, identidade visual não universal, contexto particular opcional.

**Scale/Scope**: Um audit por produto; representações múltiplas no mesmo registro; MVP com dois canais; seis histórias e revisão de documentação neutra. Perfil/catálogo pessoal e redesenho de jogo excluídos.

## Constitution Check

*Gate de desenho, antes e depois das fases 0/1; não significa aceitação da implementação.*

| Princípio vigente | Antes | Depois | Evidência/limite |
|---|---|---|---|
| I. Evidence-Based Analysis | Pass | Pass | Source contract preserva natureza/limites; nenhum dado novo inferido para completar página |
| II. Generic Core and Additive Methods | Pass | Pass | Núcleo editorial sem stack; canal itch é aditivo, cenário fictício sem estética imposta |
| III. Read-Only Procedure and Privacy by Default | Pass | Pass | Só canônico fora do alvo é atualizado; nenhum alvo executado; acervo privado e fixtures fictícias |
| IV. Versioned Markdown Source of Truth | Pass | Pass | Uma saída por produto; extensão opcional versionada e histórico no mesmo registro |
| V. Modular, Agent-Guided Method | Pass | Pass | Runbook/perfil/modelo neutro com gates, fixtures controladas e cobertura visível; verificações registradas |

Constituição 4.0.0: emenda explícita IV permite destino existente e derivados privados solicitados; fatos e no-target-execution permanecem. Limitação do host é declarada pelo fluxo de audit existente; a preparação editorial não amplia sua garantia.

## Project Structure

### Documentation (this feature)

```text
specs/002-reposition-itch-lab/
  spec.md
  plan.md
  research.md
  design.md
  data-model.md
  quickstart.md
  migration.md
  contracts/
    editorial-source.md
    public-presentation.md
    editorial-review.md
  checklists/requirements.md
  tasks.md
```

### Source Code (repository root)

Locais de implementação entregues:

```text
.agents/skills/repodna-audit/
  SKILL.md                             # entrada existente a estender
  references/
    presentation-format.md             # runbook genérico novo
    workflow.md                         # integrar capacidade no fluxo existente
    publication-b4.md                   # regras factuais existentes
    consolidation.md                   # integração no canônico existente
.agents/skills/repodna-itch-format/
  SKILL.md                             # composição a partir de audit existente
  references/channel-itch.md           # perfil específico do canal
specs/001-readonly-audit-framework/contracts/
  source-of-truth-markdown.md           # extensão opcional, sem alterar facts
tests/fixtures/readonly-audit/presentation-model/
  README.md                            # cenários fictícios
  sample-product.md                    # um produto fictício, um canônico
tests/publication_format_contract_test.sh
tests/run.sh                           # integrar apenas checks de framework
tests/local_method_test.sh             # distinguir citações oficiais de dependência de método
README.md                              # orientar capacidade e limites
```

**Structure Decision**: Reutilizar a estrutura da skill e os contratos da 001; não criar `content/`, `editorial/`, `preview/`, backend ou banco. Migrações de material fora de escopo preservam originais/procedência antes da retirada e mantêm trabalho não relacionado. Contextos particulares não são dependência da estrutura pública.

## Phase 0 — Research

[research.md](research.md) resolve fonte única, delta da 001, capacidades itch.io, fallback de texto e privacidade. Pesquisa em fontes primárias em 2026-10-06 inclui Steamworks como apoio editorial comparativo, IGDA para créditos e sinopse GDC 2010 como contexto histórico; D09–D10 delimitam aplicação e preservação de voz. Nenhum adaptador real adicional ou limite numérico universal de descrição inferido. Uma pesquisa delegada somente leitura foi usada para o perfil do canal. Sem dúvida de arquitetura obrigatória em aberto.

## Phase 1 — Design & Contracts

[design.md](design.md) define fluxo e divisão de responsabilidades; [data-model.md](data-model.md) define referências e dimensões de estado, sem reimplementar entidades factuais. Contratos tratam entrada, representação e revisão. [quickstart.md](quickstart.md) define cenários de aceitação, incluindo ausência de fonte real; não apresenta testes futuros como executados.

Compatibilidade: preservar schema factual 2.1.0 e headings existentes. Acrescentar subseções opcionais em `Projeção pública e claims`, identificadas pela versão editorial 1.0. Documentos sem extensão continuam legíveis e não são considerados avaliados editorialmente; alteração material/versão futura registra migração no mesmo canônico. Não mudar o schema factual apenas para justificar nova ficha.

## Dependencies & Implementation Sequence

1. Selecionar/importar audit original para piloto real, com identidade/versão/baseline/IDs. Registrar indisponibilidade sem bloquear desenvolvimento sintético.
2. Construir runbook e rota de evidência reutilizando contratos existentes (US1).
3. Adicionar perfil itch.io e representação fictícia em texto simples dos mesmos fatos (US2).
4. Implementar revisão, invalidação e prontidão por dimensão no canônico (US3).
5. Integrar instruções, fixtures/validações, privacidade e orientação pública (US4).

MVP: US1 + US2. US1 é verificável em isolamento com seleção e rascunho genérico. US3 exige essas representações; US4 integra o método. Piloto real não bloqueia fixtures; exige audit original selecionado. Seleção/importação foi verificada na implementação inicial com origem, IDs e baseline preservados; seu contexto particular não é dependência do método e não foi reaberto nesta revisão.

## Risks and Open Dependencies

| Condição | Tratamento |
|---|---|
| Audit real indisponível | Primeira tarefa registra seleção/recuperação; usar fixture, sem claim real |
| Registro legado sem ID/schema | Migração pelo contrato da 001; manter rota e lacunas, sem fato inventado |
| Campo de canal exige fato ausente | Bloquear campo/representação afetado, não o método inteiro |
| Limite do destino muda | Revalidar perfil e representações dependentes; registrar fonte/data |
| Baseline/confiança divergem | Marcar stale, preservar versão anterior e não publicar |
| Aplicação visual solicitada | Salvar derivados privados com origem/versão; não gerar relatórios nem publicar |

Emenda constitucional IV 4.0.0 aplicada antes da consolidação; sem violação residual. A mudança de localização/derivados é a exceção explícita à revisão anterior.

## Implementation Verification — 2026-10-07

- Runbook/perfil integrados à skill, workflow, B4 e consolidação; extensão opcional 1.0 no contrato 2.1.0, sem novos IDs factuais ou fonte paralela.
- Suíte `bash tests/run.sh --framework`: **17/17 checks passaram**, exclusivamente sobre fixtures/controlado. Novo contrato valida rotas, canais, voz, caveats, decisões/freshness e permissões, rejeitando 15 mutações negativas. Argumento fora da fixture foi recusado antes de leitura.
- Links locais dos documentos alterados e guard de contexto público passaram. O check do método local aceita somente as três citações oficiais no perfil itch, sem dependência remota das instruções.
- Migração histórica: preservação/retirada conferidas no recorte registrado e trabalho não relacionado mantido. Inventário privado não entrou em testes/fixtures; não foi reinspecionado nesta revisão.
- Preparação editorial inicial: consumo de fonte única e duas variantes draft com rotas/lacunas verificados. Escolhas e decisões particulares pertencem ao respectivo relatório, sem fonte real obrigatória para validar o método.
- Revisão guiada realizada pelo agente, sem estudo humano, tempo medido, renderização da loja ou resultado comercial. O probe de host da suíte permanece unsupported/unverified; isto não certifica proteção preventiva do alvo. Nenhum alvo foi inspecionado/executado nesta implementação.
- Hooks before/after_implement: `.specify/extensions.yml` ausente; nenhum hook aplicável. Convergência será executada após esta implementação.

## Revisão 3 — implementação da consolidação

Fluxo: audit existente → seleção editorial → texto para o canal → aplicação visual → registro da versão validada. A importação inicial descrita acima é histórica. Quando solicitada, a consolidação mantém o audit original escolhido, sem reinvestigação. Arquivos particulares permanecem fora da distribuição.

Touch-points: constituição IV/constraints; spec/plan/tasks e contratos/editorial-source/public-presentation; runbook presentation-format, channel-itch e integração skill/workflow/consolidation; novo `references/presentation-template.md` com matriz de blocos e esqueleto; README; testes de contrato existentes. Compatibilidade: schema factual 2.1.0 e extensão 1.0 permanecem; registro aditivo de aplicação/decisões, histórico antigo não ganha aprovação. Etapas T106–111 implementam FR-027–030/SC-011–012; não refazer checks da página validados pelo usuário.


## Verificação da revisão 3 — 2026-10-07

T106–111 concluídas: emenda IV aplicada, preservação de corpo/IDs/história editorial e retirada segura de cópia verificadas. Registros de texto/derivados e decisões mantidos no contexto privado; modelo neutro público com oito responsabilidades de blocos/esqueleto, sem dados reais. 17/17 checks passaram; quatro checks pertinentes reexecutados após limpeza de redação e 15 casos negativos rejeitados. Links em 28 documentos e guard público passaram. Sem commit, mudança de staging, publicação, execução de alvo ou novos testes da página. Publicação e limites factuais conservam seus estados independentes.

## Revisão 4 — entrada editorial independente

Fluxo: $repodna-audit → relatório único → $repodna-itch-format → representação e derivados solicitados. Criar `.agents/skills/repodna-itch-format/SKILL.md`; mover `channel-itch.md` para suas references, sem stub duplicado. Método/modelo genéricos permanecem nas referências compartilhadas existentes. Atualizar todos os callers/links e checks de método para o novo caminho. Não iniciar audit ou apresentação automaticamente; política de descoberta normal da skill não implica encadeamento automático pelo audit.

Entradas: caminho explícito prevalece; sem caminho usar contexto inequívoco; ambiguidades/inacessibilidade pedem só identificação; insuficiência bloqueia partes dependentes. Entrega segue idioma/formato e estado, com rastreabilidade no relatório original. Derivados aceitos anteriores preservados por versão antes de nova redação.

Governança 4.1.0 alinha Development Workflow à skill adicional; schema factual 2.1.0/editorial 1.0 e no-target-execution permanecem. Touch-points: skill nova/perfil movido; skill audit/workflow; links de método/contratos/README; spec/plan/tasks/design/data-model/research/quickstart; testes local_method/publication_format e fixture README. Verificações: quick_validate do skill-creator, revisão guiada em fixture, suíte controlada, links/privacidade e hashes reais somente para preservação (sem consumir seus fatos). T112–117; sem página, publicação, commit ou staging.


## Verificação da revisão 4 — 2026-10-07
+
+T112–117 implementadas. Skill nova e perfil de canal movido; rota do audit indica comando sem composição automática. Shared runbook/modelo mantidos uma vez, com referências locais atualizadas. quick_validate oficial passou usando dependência temporária, 17/17 checks controlados passaram, 15 mutações negativas rejeitadas, links em 29 documentos resolvem. Revisão manual dos quatro contextos e entrega proporcional registrada na fixture README, sem alegar execução independente da skill ou recepção humana. Hashes do relatório/HTML/CSS real de preservação idênticos; staging não alterado; sem commit, alvo, site ou aplicação real nesta tarefa. Hooks before/after_specify/implement ausentes.


## Revisão 5 — neutralidade documental

T118–121 revisam README, skills/referências, feature 002, contratos e exemplos/testes compartilháveis. Remover nomes, URLs/caminhos reais e decisões particulares; preservar ferramentas/canais/fontes profissionais, caminhos do framework e cenários fictícios. Detalhes de acervos e aplicações pertencem aos registros privados, que não são escritos nem reabertos para composição. Histórico de FR/SC/T e resultados técnicos continua recuperável. Nenhuma nova arquitetura, artefato de aplicação, investigação ou política de idioma/visual é introduzida. Verificações: validadores das skills alteradas, checks pertinentes controlados, links, busca delimitada dos termos identificados e staging. Busca textual não garante privacidade absoluta.


## Verificação da revisão 5 — 2026-10-07

Neutralização em 11 documentos: duas skills/modelo genérico, artefatos da feature e guia de fixture. Referências de acervo, configuração visual e contexto de aplicação foram generalizadas; IDs e resultados técnicos preservados. Dois validadores oficiais passaram; suíte 17/17 passou com 15 mutações negativas. Busca delimitada em 145 fontes/exemplos compartilháveis não encontrou os marcadores particulares identificados; links em 28 documentos resolvem. A busca/revisão não é garantia absoluta contra dados privados desconhecidos. Nomes do framework/ferramentas/canais/fontes e cenários explicitamente fictícios permanecem legítimos. Nenhum relatório real, derivado validado, arquivo externo ou área privada escrito; staging idêntico ao início. Hooks ausentes; sem commit/publicação.
