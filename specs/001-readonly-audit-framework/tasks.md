# Tasks: Framework de auditoria readonly e Project Source of Truth

**Input**: Design documents in `/specs/001-readonly-audit-framework/`

**Prerequisites**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Incluídas tarefas de aceitação porque a especificação define testes independentes e cenários observáveis por história. Não executar build/testes/código do repositório-alvo.

**Organization**: Tarefas agrupadas pelas quatorze histórias da especificação e precedidas pelos gates compartilhados de governança e vocabulário; US12/US13 estão nas Phases 24–27 e US14 na Phase 28. A validação humana SC-025 permanece a última tarefa, após o registro dos demais incrementos.

**Revisão de decisão 2026-10-04**: Phase 16 atualiza o contrato de host readonly. T001–T074 preservam o registro da decisão original (gate obrigatório); para o comportamento vigente, Phase 16 e os artefatos atualizados prevalecem: enforcement não comprovado gera aviso, não bloqueio, e a preservação não pode ser chamada de garantida.

## Phase 1: Setup e gate de governança

**Purpose**: Atualizar a autoridade do projeto antes de iniciar implementação incompatível e fixar áreas locais ignoradas.

- [x] T001 Atualizar `.specify/memory/constitution.md` para v2.0.0, preservando evidência, genericidade e privacidade e substituindo as obrigações incompatíveis de CLI/relatórios pela skill, pelo limite readonly e pelo Markdown canônico; manter sem inventar a data original de ratificação.
- [x] T002 Consolidar em `.gitignore` as entradas exatas para `target-repos/` e `analysis-output/`, verificando também regras que possam re-incluir conteúdo privado por negação.

**Gate**: T001 está concluída; a revisão da constituição v2.0.0 acompanha as demais mudanças antes de qualquer implementação do runtime.

## Phase 2: Foundational (pré-requisitos compartilhados)

**Purpose**: Estabelecer vocabulário de evidência e contrato Markdown usado por todas as histórias.

- [x] T003 [P] Definir estados de cobertura, evidência, confiança, finding, autoria, tecnologia, runtime, release, claim, publicação, questão e etapa em `.agents/skills/repodna-audit/references/evidence-vocabulary.md`, alinhados a `data-model.md`.
- [x] T004 Definir o esqueleto e as invariantes mínimas de um registro Markdown por produto em `.agents/skills/repodna-audit/references/consolidation.md`, incluindo slug, identificadores estáveis, referências recuperáveis, baseline, cobertura e histórico.
- [x] T005 Criar fixtures locais seguras, documentar o harness de aceitação e manter em `tests/fixtures/readonly-audit/README.md` a matriz autoritativa de perfis (sistema operacional + ambiente de execução), estado suportado/não suportado e evidência da fronteira readonly; não incluir conteúdo de repositórios privados nem executar arquivos das fixtures.

**Checkpoint**: Constituição v2.0.0, diretórios privados ignorados e contratos base revisados; nenhuma auditoria de alvo começa antes do gate readonly da US1.

---

## Phase 3: User Story 1 - Auditar um alvo sem modificá-lo (Priority: P1) 🎯 MVP

**Goal**: Selecionar um alvo sem ambiguidade, bloquear quando a sessão não comprovar limite de leitura, registrar baseline e produzir resultado externo sem alterar o alvo.

**Independent Test**: Usar fixtures com arquivos rastreados, modificados, ignorados e não rastreados; comparar baseline e estado final incluindo conteúdo. Casos com symlinks, Git externo ou falta de isolamento devem bloquear antes da inspeção extensa. Deve existir apenas o Markdown em `analysis-output/`.

### Acceptance tasks

- [x] T006 [P] [US1] Criar cenários de aceitação para baseline limpa, mudanças preexistentes e arquivos ignored/untracked em `tests/readonly_audit_boundary_test.sh`.
- [x] T007 [P] [US1] Criar cenários de aceitação para symlink/junction, submódulo, Git externo e tentativa controlada de escrita negada no alvo/Git enquanto a saída permanece gravável; usar a matriz autoritativa de T005 e executar a prova em cada perfil suportado; perfis sem prova válida ficam não suportados e bloqueiam antes de leitura substantiva em `tests/readonly_audit_scope_test.sh`.

### Implementation tasks

- [x] T008 [US1] Integrar o preflight à política efetiva do host para permitir leitura e negar escrita no alvo/Git, mantendo `analysis-output/` gravável separadamente; verificar caminhos reais e bloquear se o alvo estiver sob uma raiz gravável ou a capacidade não for comprovável; instrução em skill, `.gitignore`, hash e status não contam como enforcement em `.agents/skills/repodna-audit/SKILL.md`.
- [x] T009 [US1] Documentar a configuração de host necessária para tornar alvo e Git readonly com saída separada gravável, além da preparação, identidade, refs, HEAD/branch, estado tracked/untracked/ignored e alterações preexistentes em `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T010 [US1] Definir captura e cobertura da baseline, limites da comparação de conteúdo/estado e efeitos de mudanças concorrentes em `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T011 [US1] Implementar bloqueios e estados parcial/blocked com motivo, ação necessária e checkpoint recuperável em `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T012 [US1] Integrar a declaração de preservação e as limitações de cobertura ao registro inicial em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T013 [US1] Conectar os cenários readonly ao runner atual sem executar artefatos do alvo em `tests/run.sh`.

**Checkpoint**: Uma auditoria inicial distingue estado preexistente, não executa conteúdo do alvo, bloqueia quando o host não garante readonly e grava resultados somente fora dele.

---

## Phase 4: User Story 2 - Seguir um método completo com um agente (Priority: P1)

**Goal**: Dar um ponto de entrada para conduzir a auditoria em fases reproduzíveis, com aplicabilidade, pré-condições, evidências, falhas e conclusão declaradas.

**Independent Test**: Seguir a skill em um projeto pequeno e em um projeto com histórico/produção extensos; cada domínio aparece como coberto, parcial, não observado, não aplicável, indisponível ou não verificado, com checkpoints para retomada.

### Acceptance tasks

- [x] T014 [US2] Criar cenários de aceitação de sequência, aplicabilidade, falha parcial e retomada em `tests/audit_workflow_contract_test.sh`; documentar protocolo de primeiro uso com o limite de cinco minutos em `specs/001-readonly-audit-framework/quickstart.md`.

### Implementation tasks

- [x] T015 [US2] Implementar a skill principal como único ponto de entrada, com objetivo, entradas, gates, ordem de fases e referências em `.agents/skills/repodna-audit/SKILL.md`.
- [x] T016 [US2] Definir sequência, pré-condições, estados, combinação de etapas, checkpoint e retomada em `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T017 [P] [US2] Definir investigação forense A1 de identidade, timeline, sistemas e contribuição em `.agents/skills/repodna-audit/references/forensic-a1.md`.
- [x] T018 [P] [US2] Definir B1 para arquitetura, configuração ativa, build/release, conteúdo/assets, dependências, tooling, testes existentes e observabilidade em `.agents/skills/repodna-audit/references/production-b1.md`.
- [x] T019 [P] [US2] Definir B2 como análise estática de runtime, confiabilidade e performance; para cada medição existente registrar procedência, snapshot, cenário, ambiente, ferramenta, unidade, método e limitações, aceitar comparação antes/depois somente sob condições comparáveis e, sem medição, propor perguntas e plano futuro sem executar o alvo em `.agents/skills/repodna-audit/references/runtime-b2.md`.
- [x] T020 [P] [US2] Definir B3 para procedência de release/artefato e força de cada relação temporal em `.agents/skills/repodna-audit/references/provenance-b3.md`.
- [x] T021 [P] [US2] Definir B4 para publicação, claims, texto, links, mídia, créditos e permissões em `.agents/skills/repodna-audit/references/publication-b4.md`.
- [x] T022 [US2] Declarar instalação, uso local, limites readonly, início da skill e substituição da experiência CLI antiga em `README.md`.
- [x] T023 [US2] Mapear requisitos e cenários da especificação às fases e critérios de conclusão em `.agents/skills/repodna-audit/references/workflow.md`.

**Checkpoint**: O agente percorre método genérico, registra aplicabilidade e limites e não omite domínios obrigatórios silenciosamente.

---

## Phase 5: User Story 3 - Entender o projeto por uma fonte de verdade única (Priority: P1)

**Goal**: Produzir um documento Markdown humano, pesquisável e consolidado, único para cada produto.

**Independent Test**: Entregar somente o Markdown em `analysis-output/` a um agente de IA e fazer perguntas predefinidas sobre identidade, contribuições, arquitetura, release e limites; respostas factuais citam evidências e dados sem suporte permanecem desconhecidos. Confirmar que não há relatório, anexo ou formato alternativo persistente.

### Acceptance tasks

- [x] T024 [US3] Definir perguntas/respostas esperadas com evidências em `tests/fixtures/readonly-audit/ai-retrieval-cases.md`, documentar avaliação manual de recuperação por agente em `specs/001-readonly-audit-framework/quickstart.md` e validar estrutura/saída única em `tests/canonical_markdown_contract_test.sh`.

### Implementation tasks

- [x] T025 [US3] Especificar estrutura inicial, resumo, Start Here, mapa de estudo, arquitetura, sistemas e timeline em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T026 [US3] Especificar índices de evidências, findings, cobertura, perguntas, conflitos, apêndices e referências recuperáveis no mesmo arquivo em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T027 [US3] Definir criação/atualização de `analysis-output/<safe-product-slug>.md`, colisões, um arquivo por produto e proibição de HTML, JSON/CSV, ZIP, Notion ou anexos em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T028 [US3] Definir organização navegável por pessoa e recuperável por agente, com headings estáveis e apresentação explícita de evidência, inferência, relatos, confiança e limitações em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T029 [US3] Implementar validação de cobertura do contrato e saída única no harness em `tests/canonical_markdown_contract_test.sh`.
- [x] T030 [US3] Conectar a validação canônica ao runner existente em `tests/run.sh`.

**Checkpoint**: Cada produto tem uma autoridade Markdown local única e todos os dados necessários ao leitor estão nela.

---

## Phase 6: User Story 4 - Separar implementação, autoria, release e resultados (Priority: P1)

**Goal**: Sustentar conclusões técnicas e pessoais com evidências sem misturar implementação, atribuição, release, medição ou impacto.

**Independent Test**: Analisar trabalho compartilhado, feature planejada sem código, tag sem binário correlacionado e alegação de desempenho sem medição; nenhuma conclusão deve exceder a força da evidência.

### Acceptance tasks

- [x] T031 [P] [US4] Criar fixtures de contribuição compartilhada, identidade ambígua, planejamento sem código, release sem binário, medições com e sem procedência/comparabilidade, distinção entre tamanho de build e memória em runtime, Editor e plataforma alvo, demo e teste, configuração e resultado observado em `tests/evidence_separation_test.sh`.

### Implementation tasks

- [x] T032 [P] [US4] Definir como identidade, alias, diff e contribuição por sistema sustentam estados de autoria e limites de wording em `.agents/skills/repodna-audit/references/forensic-a1.md`.
- [x] T033 [US4] Separar fato estático, risco estático, medição e não medido; distinguir tamanho de arquivo/build/download de memória em runtime, Editor de plataforma alvo, demo de teste e configuração de resultado observado; sem medição, registrar perguntas e plano futuro sem executar aplicação/build/testes/profiling no alvo em `.agents/skills/repodna-audit/references/runtime-b2.md`.
- [x] T034 [US4] Definir sistema/feature, dependências, implementação, baseline e estados de contribuição na matriz em `.agents/skills/repodna-audit/references/forensic-a1.md`.
- [x] T035 [US4] Definir cronologia do produto, contribuição, emprego/manutenção e publicação como dimensões independentes em `.agents/skills/repodna-audit/references/forensic-a1.md`.
- [x] T036 [US4] Definir cadeia de release entre evento, ref/commit, binário, versão e destino, com confiança por relação, em `.agents/skills/repodna-audit/references/provenance-b3.md`.
- [x] T037 [US4] Definir modelos de história de engenharia e talking points que mantenham lacunas ou relatos pessoais identificados em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T038 [US4] Conectar casos de separação de evidência ao runner em `tests/run.sh`.

**Checkpoint**: Claims técnicas e pessoais mantêm linhagem evidencial, estado e limitações sem extrapolar proxies.

---

## Phase 7: User Story 5 - Consolidar contexto e limites de publicação (Priority: P2)

**Goal**: Reconciliar fontes somente para leitura e declarar o que pode ser divulgado, com créditos, condições e bloqueios por tipo de conteúdo.

**Independent Test**: Fornecer notas conflitantes e mídia com origem conhecida, mas permissão de republicação desconhecida; registrar conflito e impedir conclusão permissiva por ausência de dados.

### Acceptance tasks

- [x] T039 [P] [US5] Criar fixtures de fontes conflitantes e itens de reconciliação classificados como incorporado, contexto retido, projeto distinto, histórico/superado ou irrelevante, com justificativas; incluir mídia sem licença/crédito e permissões independentes para link, embed, cópia, crop, download/rehosting e alteração de áudio em `tests/publication_readiness_test.sh`.

### Implementation tasks

- [x] T040 [US5] Definir hierarquia da fonte por tipo de claim, citação, conflito, atualização e limite temporal, além das categorias de reconciliação com critérios de decisão em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T041 [US5] Definir procedência, creator, crédito, licença e permissão para texto/mídia e avaliar separadamente link, embed, cópia, crop, download/rehosting e alteração de áudio; publicação existente não autoriza outra ação e permissão sem evidência fica desconhecida em `.agents/skills/repodna-audit/references/publication-b4.md`.
- [x] T042 [US5] Definir estados de claim e prontidão editorial/publicação, incluindo bloqueios independentes e não bloqueios em `.agents/skills/repodna-audit/references/publication-b4.md`.
- [x] T043 [US5] Documentar reconciliação de fontes externas somente para leitura, classificando cada informação relevante como incorporada, contexto retido, projeto distinto, histórico/superado ou irrelevante, com fonte e justificativa; não editar, comentar, excluir ou exportar conteúdo externo em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T044 [US5] Integrar cenários de prontidão e privacidade ao runner em `tests/run.sh`.

**Checkpoint**: Conflitos permanecem visíveis e permissões desconhecidas nunca viram autorização implícita.

---

## Phase 8: User Story 6 - Documentar produtos com vários repositórios e tecnologias (Priority: P2)

**Goal**: Manter rastreabilidade por repositório e oferecer profundidade específica de tecnologia sem quebrar o método genérico.

**Independent Test**: Auditar cliente, serviço e pacote explicitamente relacionados, mais um produto sucessor separado; manter cada evidência ligada ao repositório e baseline corretos.

### Acceptance tasks

- [x] T045 [P] [US6] Criar fixtures de produto multi-repo, sucessor, stack desconhecida, domínios não aplicáveis e contribuição compartilhada rastreada por pacote→versão→produto consumidor→release; confirmar que evidências em vários repositórios não duplicam a contribuição consolidada em `tests/multirepo_audit_test.sh`.

### Implementation tasks

- [x] T046 [US6] Definir relação explícita produto/repositório, papel, slug, repo/baseline e linhagem de pacote/feature compartilhado até seu consumo e release; atribuir identidade comum à contribuição e contabilizá-la uma vez na consolidação em `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T047 [US6] Definir adaptação de jogos com avaliação condicional de rendering, scenes/prefabs, assets, UI, áudio, física e runtime/editor em `.agents/skills/repodna-audit/references/production-b1.md`.
- [x] T048 [US6] Definir adaptação de apps/serviços para cliente/servidor, contratos, dados, integrações e deployment em `.agents/skills/repodna-audit/references/production-b1.md`.
- [x] T049 [US6] Definir distinção de tecnologia instalada, uso possível, uso observado e configuração ativa em `.agents/skills/repodna-audit/references/evidence-vocabulary.md`.
- [x] T050 [US6] Documentar o inventário de capacidades legadas mantidas, descartadas ou substituídas e sua compatibilidade readonly em `specs/001-readonly-audit-framework/methodology.md`.
- [x] T051 [US6] Integrar cenários multi-repo e especializações sem execução de código-alvo ao runner em `tests/run.sh`.

**Checkpoint**: Produtos não são fundidos automaticamente e evidências especializadas continuam ligadas à base genérica.

---

## Phase 9: User Story 7 - Reutilizar e atualizar a análise com controle (Priority: P2)

**Goal**: Incorporar evidência legada compatível, retomar auditorias e atualizar o registro sem perder história ou reutilizar conclusões obsoletas.

**Independent Test**: Importar evidência legada compatível, alterar baseline e reabrir a auditoria; decisões afetadas são invalidadas e os checkpoints superados permanecem rastreáveis no mesmo Markdown.

### Acceptance tasks

- [x] T052 [P] [US7] Criar fixtures de evidência legado compatível/incompatível, mudança de baseline e checkpoint interrompido em `tests/audit_resume_migration_test.sh`.

### Implementation tasks

- [x] T053 [US7] Definir seleção e migração de evidências legadas com semântica e versão preservadas em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T054 [US7] Definir atualização de baseline, findings afetados, decisões alteradas, checkpoints superados e marcação stale em `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T055 [US7] Definir retomada após interrupção, versão de método, estado de etapas e reconfirmação de baseline em `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T056 [US7] Definir preservação do estado atual e histórico do registro durante novas sessões sem gerar segundo arquivo de relatório em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T057 [US7] Integrar casos de migração e retomada ao runner em `tests/run.sh`.

**Checkpoint**: Conclusões antigas são reutilizadas somente quando a baseline continua válida; o arquivo canônico preserva a evolução.

---

## Phase 10: Polish e revisão transversal

**Purpose**: Fechar rastreabilidade, transição e validação documental do framework inteiro.

- [x] T058 [P] Atualizar `README.md` e `CONTRIBUTING.md` para refletir a experiência de skill, privacidade dos diretórios locais e retirada dos formatos legados.
- [x] T059 Revisar `.github/workflows/quality-tests-and-fixtures.yml` para executar apenas verificações aplicáveis ao novo framework, executar a prova de fronteira readonly em cada perfil listado como suportado na matriz de T007 e impedir publicação acidental de alvos/saídas privadas.
- [x] T060 Revisar `dna-analysis.sh`, `src/pipeline/` e `renderers/` para remover do caminho suportado a geração de múltiplas saídas; excluir código legado somente quando o inventário de T050 confirmar que não há capacidade reutilizada.
- [x] T061 Revisar a correspondência dos requisitos FR-001–FR-070 e critérios SC-001–SC-013 em `specs/001-readonly-audit-framework/tasks.md`, acrescentando tarefas se algum requisito não tiver cobertura.
- [x] T062 Validar cenários de `specs/001-readonly-audit-framework/quickstart.md` com fixtures locais; registrar limitações de plataforma e confirmar ausência de execução dos alvos.
- [x] T063 Fazer revisão final de segurança, privacidade, documentação, gitignore e contrato de saída única em `specs/001-readonly-audit-framework/tasks.md`.

---

## Complemento de execução: US8 e US9 (2026-10-04)

T001–T063 preservam o histórico concluído. Executar o complemento abaixo em
ordem, sem gerar outra spec, trocar branch ou substituir tarefas já concluídas.

## Phase 11: Setup e preservação da procedência

- [x] T064 Preservar os originais de `methodology.md` e `source-inventory.md` em `private-context/research/`; excluir `/private-context/` em `.gitignore`; conferir histórico dos caminhos afetados sem reescrevê-lo.

## Phase 12: US8 — framework compartilhável sem contexto privado

**Independent test**: índices e arquivos com metadados fictícios são bloqueados; limpar somente o working tree não libera o índice; valores privados não aparecem no diagnóstico.

- [x] T065 [US8] Criar e executar cenários sintéticos de privacidade em `tests/public_context_test.sh` antes do guard, cobrindo working tree, índice antigo, termos opcionais e caminhos privados rastreados.
- [x] T066 [US8] Implementar `scripts/check-public-context.py` para verificar arquivos atuais e blobs do índice, `private-context/known-sensitive-terms.txt` opcional, padrões genéricos e diagnóstico sem valores privados.
- [x] T067 [US8] Generalizar `specs/001-readonly-audit-framework/methodology.md`, remover metadados privados do inventário público e substituir exemplos pessoais em `docs/windows-support.md`, `docs/author-aliases.md`, `src/core/arguments.sh`, `tests/arguments_test.sh`, `tests/windows_compatibility_test.sh` e `tests/author_alias_validation_test.sh`; preservar identidade pública de copyright.
- [x] T068 [US8] Atualizar apenas versões sanitizadas dos caminhos deste complemento no índice e validar `scripts/check-public-context.py`; registrar exposição histórica caso identificada, sem reescrever commits.

## Phase 13: US9 — autoridade local e método autossuficiente

**Independent test**: nenhuma referência obrigatória precisa de fonte original; todos os temas incorporados são recuperáveis no checkout sem acesso a serviço externo.

- [x] T069 [US9] Criar e executar `tests/local_method_test.sh` para validar referências locais obrigatórias e cobertura temática, sem acessar fontes externas nem executar alvos.
- [x] T070 [US9] Construir mapa público de temas em `specs/001-readonly-audit-framework/source-inventory.md` e explicitar autoridade local em `.agents/skills/repodna-audit/SKILL.md`, `references/workflow.md` e nos documentos de pesquisa/spec afetados.
- [x] T071 [US9] Documentar `contracts/privacy-local-authority.md`, validar entidades em `data-model.md` e cenários em `quickstart.md`; ligar o contrato em `contracts/input-output.md` e exigir exclusão privada em `tests/private_paths_test.sh`.

## Phase 14: Polish do complemento

- [x] T072 Integrar os guards em `tests/run.sh`, `.github/workflows/quality-tests-and-fixtures.yml`, `.github/workflows/release.yml` e `scripts/package-release.sh`, revisando também a árvore da tag antes de distribuir; atualizar `README.md` e `CONTRIBUTING.md` com autoridade local, área privada e limites da revisão automática.
- [x] T073 Executar suite de contratos e revisão final de privacidade, cobertura e referências; registrar resultados e limites neste `specs/001-readonly-audit-framework/tasks.md`.

**Dependencies**: T064 → T065 → T066 → T067 → T068; T069 → T070 → T071 após T064; T072 → T073 após ambas as histórias. Como exemplos independentes, T065 e T069 podem ser escritos em paralelo por arquivos distintos. O MVP deste complemento é US8; concluir US9 antes de entregar a autoridade local. Sem agentes delegados ou pesquisas externas necessárias.

**Traceability**: FR-071/073/077 e SC-014 → T065–T068/T072–T073; FR-072/074 e SC-016 → T064/T067/T070–T073; FR-075/076 e SC-015 → T069–T073. Todas as tarefas possuem ID, checkbox e caminho; fases de histórias usam [US8]/[US9].

## Phase 15: Convergence

- [x] T074 Ampliar `scripts/check-public-context.py` e `tests/public_context_test.sh` para detectar caminhos pessoais em todo arquivo textual verificável, não só `.md`, `.txt` e `.rst`; cobrir ao menos `.py`, `.sh` e `.json` com exemplos fictícios e preservar a omissão de valores nos diagnósticos (FR-071, FR-073, SC-014; partial).

## Phase 16: Uso procedural sem enforcement obrigatório

**Purpose**: Permitir iniciar auditorias estáticas no host atual sem confundir instruções de não escrita com garantia de isolamento.

- [x] T075 Atualizar a decisão vigente na mesma `spec.md`, revisar FR-005/006/008 e SC-013, preservar a decisão anterior como histórico, e emendar a constituição para v3.0.0 com aviso e preservação qualificada.
- [x] T076 Alterar `.agents/skills/repodna-audit/SKILL.md` e `references/workflow.md` para permitir perfis `unverified` com aviso, bloquear somente seleção/escopo/saída ambíguos ou inseguros, e manter proibição de escrita/execução intencional.
- [x] T077 Harmonizar contrato readonly, contrato Markdown, matriz de host, guia rápido, README, modelo, método, research, source inventory e checklists; separar `verified` (enforcement + comparação) de `observed_unchanged` (comparação sem enforcement).
- [x] T078 Registrar os limites aceitos: ferramenta ou host ainda pode gravar incidentalmente; `.gitignore`, instruções e comparação não evitam isso, e tal risco permanece explícito até futura evolução de enforcement.

**Estado atual**: Auditorias em `target-repos/` podem começar mesmo com a matriz `unverified`. A primeira resposta da skill deve avisar sobre o risco e confirmar a seleção do alvo; o documento final separa enforcement, preservação observada e cobertura incompleta.

## Dependencies & Execution Order

### Phase Dependencies

- **Setup e governança (Phase 1)**: nenhuma dependência externa; T001 é gate obrigatório para toda mudança de implementação.
- **Foundational (Phase 2)**: depende de Phase 1; contrato de evidência e Markdown bloqueia o início das histórias.
- **US1 (Phase 3)**: depende de Foundation; fecha a preservação e o modo fail-closed antes de auditorias substantivas.
- **US2 (Phase 4)**: depende de US1; constrói o método completo sobre o limite readonly.
- **US3 (Phase 5)**: depende da estrutura base em Foundation e da escrita externa estabelecida em US1; define o documento completo.
- **US4 (Phase 6)**: depende do vocabulário comum e dos runbooks A1/B2/B3 da US2.
- **US5 (Phase 7)**: depende do contrato canônico US3 e da evidência tipada US4.
- **US6 (Phase 8)**: depende do fluxo US2 e do rastreio de evidências US4.
- **US7 (Phase 9)**: depende dos contratos de saída US3 e checkpoints US2.
- **Polish (Phase 10)**: depende das histórias incluídas na entrega.

### User Story Dependencies

- **US1 (P1)**: após Foundation; MVP inicial seguro.
- **US2 (P1)**: após US1; framework completo depende do guard readonly.
- **US3 (P1)**: pode iniciar após Foundation/US1 e evolui o Markdown mínimo da US1.
- **US4 (P1)**: após US2; usa runbooks e vocabulário compartilhados.
- **US5 (P2)**: após US3 e US4.
- **US6 (P2)**: após US2 e US4.
- **US7 (P2)**: após US2 e US3.

Stories P2 podem ser paralelizadas depois de concluir suas dependências; P1 tem dependências deliberadas para manter os contratos coerentes.

## Parallel Opportunities

- **Foundation**: T003 pode ser escrito em paralelo com T004, pois são arquivos distintos; T005 é independente após T002.
- **US1**: T006 e T007 podem ser criadas em paralelo; as tarefas de contrato/readme aguardam esses cenários.
- **US2**: T017–T021 são runbooks em arquivos distintos e podem ser divididos após T015/T016 fixarem a sequência e o vocabulário.
- **US3**: T024 e a estrutura de consolidação podem ser trabalhadas em arquivos separados após Foundation.
- **US4**: T032, T033 e T036 podem ocorrer em paralelo depois da US2.
- **US5**: T041 e T042 compartilham o mesmo arquivo e devem ser executadas pela mesma pessoa/ordem; T039 pode ser paralela.
- **US6**: T047 e T048 compartilham o runbook B1 e devem ser consolidadas na mesma edição; T045 é paralela.
- **US7**: T054 e T055 compartilham workflow e devem ser agrupadas; T052 é paralela.
- **Polish**: T058 e T059 podem ocorrer em paralelo depois das histórias; T061–T063 dependem de todas as mudanças.

## Parallel Example: User Story 2

Depois que T015 e T016 definirem o ponto de entrada e o fluxo, delegar os runbooks em arquivos distintos:

```text
Task: T017 forensic-a1.md
Task: T018 production-b1.md
Task: T019 runtime-b2.md
Task: T020 provenance-b3.md
Task: T021 publication-b4.md
```

## Implementation Strategy

### MVP First (US1)

1. Confirmar T001 e concluir T002–T005: diretórios privados, vocabulário e contratos compartilhados.
2. Concluir US1: seleção segura, bloqueios readonly, baseline, verificação de preservação e registro Markdown inicial.
3. **Gate do MVP**: revisar os cenários independentes da US1; nenhum alvo é analisado se o host não garantir o limite readonly.
4. Continuar com US2 e US3 para entregar o método completo e o Markdown navegável; US4–US7 acrescentam profundidade e evolução controlada.

### Incremental Delivery

1. Phase 1–2 estabelece governança, isolamento e contratos.
2. US1 entrega auditoria local segura e parcial.
3. US2 torna a metodologia repetível com agente.
4. US3 consolida a source of truth única.
5. US4–US7 acrescentam profundidade de evidência, publicação, multi-repo e atualização.
6. Polish confirma migração, distribuição e cobertura dos requisitos.

## Requirements Traceability

| Requisitos | Histórias/tarefas |
|---|---|
| FR-001–012 | US1: T006–T013; Setup: T002 |
| FR-013–021 | US2: T014–T023 |
| FR-022–032 | US4: T031–T037; US2: T017 |
| FR-033–041 | US2: T018–T019; US4: T033; US6: T047–T049 |
| FR-042–046 | US4: T036; US2: T020 |
| FR-047–054 | US5: T039–T044; US2: T021 |
| FR-055–058 | US3: T024–T030; Foundation: T004 |
| FR-059–061 | US5: T040, T043; US6: T046 |
| FR-062–063 | US4: T037; US3: T026 |
| FR-064–066 | US7: T052–T057 |
| FR-067–070 | US3: T027–T030; US2: T022–T023; US6: T050; Polish: T058–T063 |
| FR-071–077 | US8/US9: T064–T074; Polish: T072–T074 |
| SC-001 | US1: T006–T013; US2: T014–T023; US4: T031–T038 |
| SC-002 | US1: T006–T013; US3: T024–T030; Polish: T059, T063 |
| SC-003 | US2: T014–T023; US4: T031–T038; US6: T045–T051 |
| SC-004 | US3: T024–T030; US4: T031–T038; US5: T039–T044; US6: T045–T051 |
| SC-005 | US4: T031–T038; US5: T039–T044 |
| SC-006 | US3: T024–T030; US4: T037; Polish: T062 |
| SC-007 | US1: T012; US3: T024–T030; US6: T045–T046; US7: T056 |
| SC-008 | US2: T015–T023; US3: T024–T030; US6: T047–T051 |
| SC-009 | US1: T010–T011; US7: T052–T057 |
| SC-010 | US5: T039–T044 |
| SC-011 | US2: T014, T022; Polish: T062 |
| SC-012 | US6: T050; Polish: T060–T063 |
| SC-013 | Foundation: T005; US1: T007–T008, T013; Polish: T059 |
| SC-014–016 | US8/US9: T064–T074 |

## Notes

- As tarefas pendentes usam checkbox desmarcado; T001 está concluída porque a emenda v2.0.0 foi aplicada e validada. IDs são sequenciais e todas as tarefas têm caminho exato; [P] aparece apenas quando há arquivos independentes.
- [USn] liga tarefas à história da especificação; Setup, Foundation e Polish não recebem essa marca.
- Nenhuma tarefa exige executar código, build ou testes do alvo de auditoria. A matriz Codex permanece sem perfis suportados; os contratos multiplataforma de CI não substituem prova das permissões efetivas do host.
- Os cenários de teste usam fixtures próprias do framework e podem ler/validar suas cópias locais.
- O checklist de requisitos em `checklists/audit.md` permanece uma revisão humana de qualidade; não representa conclusão de implementação.


## Validação do complemento — 2026-10-04

- Specify atualizou a mesma spec com US8/US9, FR-071–077 e SC-014–016. Clarify encontrou zero ambiguidades críticas; nenhuma pergunta nova foi necessária. Checklist de qualidade: 16/16, sem mudanças de estado; checklist de auditoria: 24/24, preservado.
- Plan e Tasks acrescentaram o complemento sem apagar T001–T063. Analyze foi somente leitura e não identificou conflito constitucional ou decisão pendente neste complemento; cobertura planejada de requisitos preservada.
- Implement concluiu T064–T073. `bash tests/run.sh --framework`: 11 testes passaram, mais o guard de arquivos atuais/índice. Os casos comprovaram bloqueio de índice antigo e snapshot de distribuição, área privada rastreada e diagnósticos sem valores privados.
- O mapa público preserva os 14 temas metodológicos; as referências obrigatórias resolvem localmente sem consulta às fontes originais. Isso demonstra cobertura/instruções locais, não cópia integral das páginas ou suporte do host para auditorias reais.
- Originais de pesquisa e exemplos antigos foram preservados somente na área privada ignorada. Nenhum conteúdo de `private-context/`, `target-repos/` ou `analysis-output/` está rastreado. Nenhuma fonte externa foi alterada e nenhum repositório-alvo foi executado.
- As fontes privadas incorporadas nesta feature não tinham commits identificados nos caminhos de inventário/método. Exemplos pessoais da documentação e dos testes antigos já existem no histórico do projeto; a limpeza atual não elimina essa exposição. Histórico não foi reescrito.
- Revisão automática cobre padrões de metadados e termos privados conhecidos; revisão humana de informações desconhecidas e binários continua necessária. Histórico: a matriz Codex era unverified e bloqueava; Phase 16 remove esse bloqueio, mantendo aviso e preservação observacional.
- Converge identificou uma limitação: caminhos pessoais eram verificados apenas em Markdown/texto simples. T074 removeu a restrição por extensão e acrescentou casos em `.py`, `.sh` e `.json`; os 11 contratos, a prova de redaction e o guard final de working tree/índice passaram em 2026-10-04.

## Fases planejadas — extensão US10/US11 (2026-10-05)

As fases abaixo complementam esta mesma feature e preservam T001–T078 como histórico concluído. T079 em diante está pendente. Nenhuma tarefa autoriza execução ou alteração do repositório/superfície auditados. Os cenários usam somente fixtures do framework.

### Phase 17: Fundação editorial compartilhada

**Purpose**: Definir vocabulário e contrato opcional comum a conteúdo editorial e avaliação de superfície no documento canônico.

- [x] T079 Atualizar `specs/001-readonly-audit-framework/data-model.md` com brief, contexto e papel editorial, história, pacote/ativo, registro profissional, observação e finding de superfície e suas validações.
- [x] T080 [P] Criar `specs/001-readonly-audit-framework/contracts/portfolio-readiness.md` com entradas opcionais, estados, seção editorial, seção de superfície e limites readonly.
- [x] T081 Atualizar `specs/001-readonly-audit-framework/contracts/source-of-truth-markdown.md` e `specs/001-readonly-audit-framework/contracts/input-output.md` para incorporar as seções opcionais mantendo um único Markdown por produto e compatibilidade com registros sem elas.
- [x] T082 Atualizar `specs/001-readonly-audit-framework/research.md` com decisões D1–D7 de compatibilidade, provenance, comparação, diagnóstico e inspeção condicional.

**Checkpoint**: Termos, compatibilidade e contrato do único arquivo canônico definidos sem transformar recomendação em fato/decisão.

### Phase 18: User Story 10 - Preparar conteúdo de projeto para decisão editorial (Priority: P1)

**Goal**: Tornar contribuição, adequação ao portfólio e gaps encontráveis e sustentados por evidência sem inventar copy ou excluir projetos.

**Independent Test**: Usar fixtures fictícias com e sem brief, inventário comparável e não comparável, contexto profissional/independente/técnico/arquivo, contribuição individual/equipe, claims sem suporte e permissões distintas. Verificar referências, unknowns, decisão vs sugestão e pacotes proporcionais.

#### Acceptance tasks

- [x] T083 [P] [US10] Criar cenários sintéticos para origem/estado de brief, classificação sem exclusão, ausência de ranking global, atribuição claim-evidência e pacote Featured vs Archive, incluindo pacote Featured com seleção de 4–7 itens visuais significativos ou lacunas explícitas de mídia/permissão, em `tests/fixtures/readonly-audit/portfolio-readiness/README.md`.
- [x] T084 [P] [US10] Definir verificações de contrato dos cenários US10 para quick scan, lacunas de história, permissão, afirmações profissionais e critérios mensuráveis de SC-025: leitor não familiarizado localiza produto/contexto e contribuição em até 60 segundos e alcança uma rota de evidência aprofundada em cerca de 5–10 minutos, em `tests/portfolio_readiness_contract_test.sh`.

#### Implementation tasks

- [x] T085 [US10] Integrar brief, contexto e papel editorial com origem, status, racional e comparação condicionada a inventário explícito em `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T086 [US10] Definir quick scan, navegação à evidência profunda e estrutura proporcional da história de engenharia em `.agents/skills/repodna-audit/references/forensic-a1.md`.
- [x] T087 [US10] Atualizar pacote de claims, mídia, evidência demonstrada, permissão e prontidão proporcional por papel em `.agents/skills/repodna-audit/references/publication-b4.md`; para Featured, registrar metas desejáveis de imagem/clipe principal, vídeo curto, 2–4 clipes/GIFs de sistemas, 3–6 screenshots, role/team/duration/platform/tech, 3–5 contribuições, 1–3 desafios, trade-offs, resultado/estado, links e confidencialidade, distinguindo inventário disponível dos 4–7 elementos significativos realmente selecionados.
- [x] T088 [US10] Incorporar papéis, cases, pacotes e matriz independente de readiness no esqueleto canônico, sem tornar Featured gate, em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T089 [P] [US10] Atualizar estados/vocabulário para origem do brief, papel editorial, sugestão/decisão humana, ativo e prontidão em `.agents/skills/repodna-audit/references/evidence-vocabulary.md`.
- [x] T090 [US10] Atualizar a seção editorial, linhagem profissional/recomendações e regras de não duplicação no `specs/001-readonly-audit-framework/methodology.md`.
- [x] T091 [P] [US10] Incluir cenários editoriais, leitura rápida e limites de comparação no `specs/001-readonly-audit-framework/quickstart.md`, registrando no roteiro SC-025 a medição de até 60 segundos para achar contexto/contribuição e o percurso de 5–10 minutos até evidência aprofundada.

**Checkpoint**: Brief ausente não bloqueia; projeto sem comparáveis não recebe ranking; claims e mídia permanecem qualificadas e arquivo/supporting continuam documentáveis.

### Phase 19: User Story 11 - Revisar superfície de portfólio selecionada (Priority: P2)

**Goal**: Avaliar a experiência observável do site/protótipo de forma localizada, priorizada, condicional e readonly.

**Independent Test**: Com fixture contratual e observações sintéticas, verificar cobertura de dimensões com finding fundamentado ou `not_observed`, escopo de viewport/interação, placar explicado, percurso e prioridades. Repetir com superfície indisponível. Não visitar ou alterar um site real como parte do teste.

#### Acceptance tasks

- [x] T092 [P] [US11] Criar fixture sintética de observações disponíveis e indisponíveis, incluindo páginas/viewports/interações e findings priorizados em `tests/fixtures/readonly-audit/portfolio-surface/README.md`.
- [x] T093 [P] [US11] Definir checagem contratual para dimensões observadas/`not_observed`, notas fundamentadas, prioridade/esforço/risco e integridade readonly em `tests/portfolio_surface_contract_test.sh`.

#### Implementation tasks

- [x] T094 [US11] Criar runbook condicional para posicionamento, arquitetura, descoberta, cases, visual, mobile, acessibilidade/interação, conversão e manutenção, incluindo método de observação e falhas em `.agents/skills/repodna-audit/references/portfolio-surface-review.md`.
- [x] T095 [US11] Integrar escopo explícito, acesso público somente leitura, carregamento local seguro de referência visual e gates de confirmação humana para conflito em `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T096 [US11] Definir campos de sumário, percurso do visitante, notas 1–5, finding P0–P3, esforço/risco/confiança e plano por fases no contrato `specs/001-readonly-audit-framework/contracts/portfolio-readiness.md`.
- [x] T097 [US11] Integrar uma seção condicional de superfície ao registro canônico, com fonte/localização/viewport e `not_observed`, em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T098 [US11] Atualizar `specs/001-readonly-audit-framework/methodology.md` e `source-inventory.md` para mapear o método generalizado e suas instruções locais sem depender do Notion.
- [x] T099 [P] [US11] Documentar cenários de avaliação disponível/indisponível e inspeção sem mudança de estado em `specs/001-readonly-audit-framework/quickstart.md`.

**Checkpoint**: Superfície não selecionada não ativa o runbook; dimensões sem observação ficam explícitas; nada é autenticado, submetido, alterado ou publicado.

### Phase 20: Polish e cobertura cruzada US10/US11

**Purpose**: Ligar a navegação da skill, fixtures, critérios e requisitos atualizados mantendo escopo e saída canônicos.

- [x] T100 Atualizar o ponto de entrada e o índice de referências de `.agents/skills/repodna-audit/SKILL.md` para oferecer prontidão editorial e revisão de superfície somente sob as condições das US10/US11.
- [x] T101 Atualizar a matriz de cenários e roteiro de uso em `specs/001-readonly-audit-framework/quickstart.md`, `specs/001-readonly-audit-framework/methodology.md` e `specs/001-readonly-audit-framework/source-inventory.md` para cobrir FR-078–094 e SC-017–027.
- [x] T102 Atualizar `tests/run.sh` para executar os contratos editoriais/de superfície apenas com fixtures do framework e nunca executar conteúdo de alvo selecionado.
- [x] T103 Atualizar a seção Requirements Traceability em `specs/001-readonly-audit-framework/tasks.md` para mapear FR-078–094 e SC-017–027 a T079–T102.
- [x] T104 Revisar referências locais, compatibilidade do Markdown antigo, privacidade e uso de uma única saída; registrar gaps restantes nos artefatos da feature, sem executar alvo em `specs/001-readonly-audit-framework/quickstart.md`.

## Dependências e ordem da extensão

- Phase 17 precede ambas as histórias porque estabelece contrato e vocabulário compartilhados.
- US10 (P1) pode prosseguir após Phase 17 e fornece o método de conteúdo que a superfície da US11 referencia.
- US11 (P2) depende do contrato da Phase 17; para integrar conteúdo/cases de maneira coerente, conclui-se após US10. T092/T093 são fixtures independentes da escrita do runbook, após o contrato.
- Phase 20 depende das duas histórias.

## Oportunidades paralelas

- T080 pode ser feito em paralelo com T079 depois de estabilizar a linguagem; T081/T082 tratam arquivos diferentes.
- Na US10, T083/T084 e T089/T091 podem ocorrer em paralelo; T086 e T087 são arquivos diferentes após T085 fixar vocabulário; T088 integra ambos.
- Na US11, T092/T093 podem ocorrer em paralelo; T094 pode ser elaborado em paralelo aos fixtures; T096 e T097 dependem da rubrica e do template concordarem.
- T100/T101/T102 tratam arquivos distintos e podem ocorrer em paralelo depois dos contratos; T103/T104 fecham rastreabilidade e revisão.

## Estratégia incremental do complemento

1. Fechar contrato e vocabulário compartilhados (Phase 17).
2. Entregar US10 como primeiro incremento utilizável para auditorias de conteúdo.
3. Acrescentar US11 de forma opt-in sem condicionar a auditoria de repositório.
4. Fechar cobertura, referências locais, privacidade e validação com fixtures fictícias.

## Rastreabilidade adicional

| Requisitos | Histórias/tarefas |
|---|---|
| FR-078–080 | US10: T083–T085, T089 |
| FR-081–083 | US10: T084, T086, T088 |
| FR-084–086 | US10: T083–T089 |
| FR-087–088 | US10: T085–T090 |
| FR-089–091 | US11: T092–T097, T106 |
| FR-092–093 | US11: T094–T096; Polish: T100–T104 |
| FR-094 | US10/US11: T084, T087, T093–T097; Polish: T102, T104 |
| SC-017–021 | US10: T083–T091; Polish: T103–T104 |
| SC-022–023, SC-027 | US11: T092–T099, T106; Polish: T102–T104 |
| SC-024 | US10: T083–T091; Polish: T100–T104 |
| SC-025 | US10: T084, T086, T091; Polish: T104 |
| SC-026 | US10: T083, T087, T088; Polish: T104 |

## Phase 21: Convergence

**Purpose**: Fechar gaps residuais identificados ao comparar a implementação atual com a spec, o plano e a constituição.

- [X] T106 Completar a matriz sintética de `tests/fixtures/readonly-audit/portfolio-surface/README.md` com finding fundamentado ou `not_observed` para cada dimensão/subdimensão de FR-089 (posicionamento; narrativa/arquitetura; descoberta; cases/evidência; visual/legibilidade; mobile/tablet; todos os aspectos de acessibilidade/interação; contato/conversão; manutenção/consistência; mídia indisponível e performance observável) e reforçar `tests/portfolio_surface_contract_test.sh` para verificar cobertura integral da matriz per FR-089 / SC-027 (partial).

## Phase 22: Validação final

**Checkpoint reservado**: A validação originalmente numerada T105 continua pendente e foi posicionada como a última tarefa na Phase 30, depois de todos os incrementos e registros.

## Phase 23: Convergence

- [X] T107 Completar o procedimento e o esqueleto canônico para orientar a avaliação por dimensão de FR-089, incluindo falha/indisponibilidade de mídia e sinais de performance somente quando já observáveis sem execução, e garantir os campos de resumo executivo, arquitetura/direção recomendada e gaps de conteúdo/evidência de FR-090; ampliar `tests/portfolio_surface_contract_test.sh` para validar o runbook e a saída canônica per FR-089–090 / SC-022 / SC-027 (partial).

## Phase 24: Contratos e vocabulário compartilhados para US12/US13

**Purpose**: Fixar a serialização de registros técnicos, ocorrências, pessoas e contribuições antes de implementar descoberta ou consultas, mantendo o único Markdown como autoridade.

- [x] T108 [P] Atualizar `tests/fixtures/readonly-audit/README.md` com a matriz de casos sintéticos para tecnologias, padrões, IA, codecs, migração, contribuidores e privacidade conforme SC-028–037.
- [x] T109 [P] Definir cenários independentes de contrato e invariantes de schema para tags, ocorrências, roster e vínculos de experiência em `tests/technical_tags_contract_test.sh`.
- [x] T110 Atualizar o contrato canônico em `specs/001-readonly-audit-framework/contracts/source-of-truth-markdown.md` e `specs/001-readonly-audit-framework/contracts/input-output.md` para `T-###`, `O-###`, `P-###`, `K-###`, índice, roster, qualificadores e compatibilidade 2.1.0.
- [x] T111 Atualizar `specs/001-readonly-audit-framework/data-model.md` e `.agents/skills/repodna-audit/references/evidence-vocabulary.md` com facetas/chaves/aliases, estados independentes, atualidade, relações package, tipos de identidade/contribuição e invariantes das FR-095–113.

**Checkpoint**: Contratos definem a forma dos registros e a evidência mínima; nenhuma taxonomia externa ou saída persistente paralela se torna necessária.

## Phase 25: User Story 12 - Consultar tecnologias e padrões com evidências (Priority: P1)

**Goal**: Identificar tecnologias, dependências, padrões, IA e codecs por ocorrências localizadas, distinguindo declaração, disponibilidade, uso, configuração, origem e atualidade.

**Independent Test**: Executar os cenários controlados da fixture de tecnologias contra os contratos de aceitação. Percorrer aliases, dependências, padrões, sinais de IA e mídia até ocorrência, sistema, baseline e evidência; confirmar que estados incertos ou históricos não viram uso atual. Nenhum artefato do alvo é executado.

### Acceptance tasks

- [x] T112 [P] [US12] Criar matriz sintética de manifests/locks, pacote transitivo, consumidor por contexto, disponibilidade, versões, alias, origem, remoção e evidência stale em `tests/fixtures/readonly-audit/technology-tags/README.md`.
- [x] T113 [US12] Criar casos sintéticos positivos e negativos para participantes/comportamento de padrões, sinais de assistência e integração de IA, contêiner/formato versus codec em `tests/fixtures/readonly-audit/technology-tags/README.md`.
- [x] T114 [P] [US12] Implementar as verificações da fixture para SC-028–032, incluindo resolução de alias sem fusão, e rastreio índice→T→O→sistema/baseline/evidência em `tests/technical_tags_contract_test.sh`.

### Implementation tasks

- [x] T115 [P] [US12] Definir descoberta estática local, fontes/limites e classificação de linguagem, engine, framework, package, ferramenta, serviço, plataforma e contexto em `.agents/skills/repodna-audit/references/production-b1.md`.
- [x] T116 [P] [US12] Documentar requisitos de prova para nomear padrões, participantes, relações, escopo, autoria própria e integração de terceiro em `.agents/skills/repodna-audit/references/forensic-a1.md`.
- [x] T117 [US12] Definir sinais separados de assistência de desenvolvimento, integração/IA do produto, técnica, provedor/modelo e codec/contêiner, sem execução ou inferência por estilo, em `.agents/skills/repodna-audit/references/production-b1.md`.
- [x] T118 [US12] Incorporar descoberta, registro e consulta de `T-###`/`O-###`, resolução de aliases, estado/contexto/origem/atualidade e retorno de evidência no fluxo de `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T119 [US12] Atualizar o esqueleto de consolidação com índice de tags ligado a registros técnicos e ocorrências, e regra de destaque técnico sem duplicar inventário, em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T120 [US12] Atualizar navegação e referências locais da skill para a consulta de tecnologia/padrões e filtros qualificados em `.agents/skills/repodna-audit/SKILL.md`.
- [x] T121 [P] [US12] Adicionar no `specs/001-readonly-audit-framework/quickstart.md` os cenários de aceitação e consultas reproduzíveis de SC-028–032 usando exclusivamente dados sintéticos.

**Checkpoint**: US12 permite responder onde e em que condição cada conceito aparece; manifesto isolado, nome de padrão, instrução de IA, extensão ou contêiner não sustentam conclusões mais fortes.

## Phase 26: User Story 13 - Identificar quem contribuiu e o alcance de sua experiência (Priority: P1)

**Goal**: Registrar contribuidores e trabalho codificado ou não técnico com cobertura explícita, ligando experiência individual somente a contribuições e ocorrências sustentadas.

**Independent Test**: Usar fixture sintética para autores, aliases ambíguos, CODEOWNERS, grupos, bots/agentes, mídia de terceiros, trabalho não técnico, histórico incompleto e relato atribuído. Consultar roster e experiência individual; confirmar fontes, cobertura parcial e ausência de herança automática da stack.

### Acceptance tasks

- [x] T122 [P] [US13] Criar fixture sintética de identidade/alias, tipos de contribuição, histórico limitado, autoria compartilhada, CODEOWNERS, bot/IA, terceiros e relato em `tests/fixtures/readonly-audit/contributors/README.md`.
- [x] T123 [P] [US13] Implementar verificações de SC-033–034 e privacidade SC-037 para roster/cobertura, reconciliação conservadora, trabalho não técnico e vínculo P→K→T/O em `tests/contributor_attribution_contract_test.sh`.

### Implementation tasks

- [x] T124 [P] [US13] Documentar fontes, escopo, completude e limites para commits, coautoria, grupos, bot/IA, CODEOWNERS, assets e contribuições fora do Git em `.agents/skills/repodna-audit/references/forensic-a1.md`.
- [x] T125 [US13] Definir reconciliação de identidades e criação de `P-###`/`K-###`, estados individual/compartilhado/relatado/desconhecido, divulgação e tratamento de conflito no fluxo de `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T126 [US13] Atualizar o registro canônico com roster escopado e vínculos pessoa→contribuição→tecnologia/ocorrência sustentados, sem herança de tags ou dupla contagem, em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T127 [US13] Adicionar ao `specs/001-readonly-audit-framework/quickstart.md` cenários de consulta individual, cobertura parcial e contribuições não técnicas para SC-033–034.
- [x] T128 [P] [US13] Atualizar índice e navegação da skill para roster e experiência individual com limites explícitos em `.agents/skills/repodna-audit/SKILL.md`.

**Checkpoint**: A lista declara quem foi identificado dentro de quais fontes/limites; experiência individual só é projetada quando o vínculo de evidência existir.

## Phase 27: Integração, migração e cobertura final US12/US13

**Purpose**: Validar coerência do arquivo canônico, migração legada, funcionamento offline e privacidade após integrar as duas histórias.

- [x] T129 Documentar atualização 2.0.0→2.1.0, preservação de IDs/fontes/histórico e estados stale/removidos nos cenários de migração e consulta offline em `tests/fixtures/readonly-audit/technology-tags/README.md` e `specs/001-readonly-audit-framework/quickstart.md` per SC-035–036.
- [x] T130 Estender `tests/public_context_test.sh` e `tests/run.sh` para incluir conteúdo sintético de tecnologia/contribuidores e garantir que nenhum identificador privado ou saída fora do Markdown canônico seja introduzido per SC-036–037.
- [x] T131 Revisar navegação, caminhos, IDs, rastreabilidade FR-095–113/SC-028–037, compatibilidade 2.1.0 e privacidade nas instruções, contratos e fixtures em `specs/001-readonly-audit-framework/quickstart.md`; preservar T105 como validação humana pendente.

## Dependências e ordem da extensão US12/US13

- Phase 24 firma os formatos compartilhados antes da descoberta e da atribuição.
- US12 (Phase 25) depende da Phase 24 e entrega a base de tags/ocorrências. US13 (Phase 26) depende dos registros O/T da US12 para ligar experiência individual a tecnologia demonstrada.
- Phase 27 depende de US12 e US13; T129 pode ser preparado em paralelo às tarefas finais de integração, enquanto T130 depende das fixtures de ambas as histórias.
- A tarefa T105 permanece pendente para as validações finais com leitor humano depois do registro; esta extensão não a antecipa nem a conclui.

## Oportunidades paralelas da extensão

- Phase 24: T108 e T109 são arquivos distintos; T110 e T111 editam contratos/modelo diferentes e dependem da revisão conceitual compartilhada.
- US12: T112/T113 podem compor a mesma fixture pela mesma sequência; T114 depende delas. T115 e T116 tratam runbooks distintos; T121 pode avançar em arquivo independente.
- US13: T122 e T123 podem ser preparados em arquivos distintos; T124/T128 também são independentes após o contrato; T125 precede T126.
- Phase 27: T129 e a revisão inicial de T131 podem ocorrer em paralelo; T130 integra as fixtures e só deve fechar após US12/US13.

## Estratégia incremental da extensão

1. Firmar schema, identificadores, estados e cenários de aceitação (Phase 24).
2. Entregar índice técnico consultável com evidência em US12.
3. Acrescentar roster e experiência individual com ligação explícita em US13.
4. Validar migração, operação offline, rastreabilidade e privacidade (Phase 27).

## Rastreabilidade adicional US12/US13

| Requisitos | Histórias/tarefas |
|---|---|
| FR-095–096 | US12: T109–T112, T118–T119; contrato: T110–T111 |
| FR-097–099 | US12: T112, T114–T115, T118–T121 |
| FR-100–101 | US12: T113–T116, T119, T121 |
| FR-102–105 | US12: T113–T115, T117–T121 |
| FR-106–108 | US13: T122–T126, T128 |
| FR-109–110 | US12/US13: T110–T111, T118–T119, T125–T126, T131 |
| FR-111–112 | Integração: T129–T131; US12: T118, T121 |
| FR-113 | US13: T122–T123; Integração: T130–T131 |
| SC-028–032 | US12: T112–T121 |
| SC-033–034 | US13: T122–T128 |
| SC-035–036 | Integração: T129–T131 |
| SC-037 | US13: T122–T123; Integração: T130–T131 |

## Phase 28: User Story 14 — Reconstruir contribuição e raciocínio técnico com evidências (Priority: P1)

**Goal**: Reconstruir histórias antigas a partir de fontes autorizadas com inferências qualificadas, rastreabilidade por afirmação e prosa editorial flexível, sem extrapolar autoria, motivação, validação ou resultado.

**Independent Test**: Executar o contrato sobre fixtures sintéticas cobrindo fontes convergentes/conflitantes/indisponíveis, memória limitada, autoria coletiva, benefício não medido, teste sem execução, resultado delimitado, ordem narrativa livre, zero destaques e revisão humana. A inspeção confirma os limites e rotas de evidência sem executar qualquer alvo.

### Acceptance tasks

- [x] T132 [P] [US14] Criar fixtures sintéticas com diffs/documentos convergentes e conflitantes, commit de grupo, teste configurado sem resultado, log com baseline/ambiente, fonte privada indisponível e narrativas em ordens variadas em `tests/fixtures/readonly-audit/engineering-reconstruction/README.md`.
- [x] T133 [P] [US14] Criar verificador de contrato para FR-114–125 e SC-038–045/047 cobrindo relação claim→evidência, baseline/escopo, limites, tipo de conclusão, papéis de fonte, atribuição, hipótese/alternativas, justificativa de confiança (direção da fonte, corroboração, contradições e escopo), consequência/validação, flexibilidade editorial e estado draft em `tests/engineering_reconstruction_contract_test.sh`.

### Implementation tasks

- [x] T134 [P] [US14] Estender os tipos, estados, confiança qualitativa e relações claim→evidência, incluindo `hypothesis`, `unknown`/`not_observed`, rubrica `high`/`medium`/`low` (sem nota para claim sem suporte) e draft editorial com distinção de autoria/decisão/colaboração/validação/resultado, em `.agents/skills/repodna-audit/references/evidence-vocabulary.md`.
- [x] T135 [P] [US14] Documentar para A1 o uso permitido de fontes locais/fornecidas/públicas anônimas, o que cada fonte sustenta, e os limites de autoria pessoal e intenção em `.agents/skills/repodna-audit/references/forensic-a1.md`.
- [x] T136 [P] [US14] Criar o runbook de reconstrução com rota claim→fonte→dimensão, síntese de alternativas/contraevidência, confiança e limite, perguntas seletivas e casos de memória indisponível em `.agents/skills/repodna-audit/references/engineering-reconstruction.md`.
- [x] T137 [US14] Integrar a reconstrução opcional no fluxo de auditoria, vinculando-a a A1, contribuições/tecnologias existentes e consolidação, sem adicionar acesso a serviço privado nem etapas dinâmicas, em `.agents/skills/repodna-audit/references/workflow.md`.
- [x] T138 [US14] Atualizar a consolidação para permitir de zero a três destaques em prosa e ordem livres, links por afirmação, limites, lacunas e estados draft/accepted/corrected/rejected sem apagar findings/fonte, em `.agents/skills/repodna-audit/references/consolidation.md`.
- [x] T139 [US14] Alinhar os prompts editoriais do case às dimensões opcionais, remover sequência/headings mandatórios e manter outcomes, evidência e relato pessoal qualificados em `.agents/skills/repodna-audit/references/publication-b4.md`.
- [x] T140 [P] [US14] Atualizar navegação, escopo de fontes e referência ao runbook de reconstrução na skill principal em `.agents/skills/repodna-audit/SKILL.md`.
- [x] T141 [US14] Adicionar roteiro reprodutível para reconstrução e cenários SC-038–047, incluindo zero destaques, avaliação qualitativa e exemplos para calibrar confidence rationale, em `specs/001-readonly-audit-framework/quickstart.md`.

**Checkpoint**: US14 permite sintetizar histórias parciais em ordem livre com toda afirmação material rastreável, hipótese revisável, contribuição qualificada e ausência de resultado devidamente declarada.

## Phase 29: Integração e revisão final US14

**Purpose**: Integrar validação de contrato, fixtures e proteção de privacidade após a implementação documental da US14.

- [x] T142 [US14] Integrar o contrato e as fixtures de reconstrução à execução seletiva do harness, mantendo acesso exclusivamente aos dados sintéticos do framework, em `tests/run.sh`.
- [x] T143 [US14] Incluir os campos e exemplos de reconstrução no guard de privacidade sem exibir valores encontrados em seus diagnósticos em `tests/public_context_test.sh`.
- [x] T144 [US14] Rever traceabilidade FR-114–125/SC-038–047, links, Markdown 2.1.0, fontes autorizadas, prosa flexível, compatibilidade e ausência de dados privados no roteiro de aceite em `specs/001-readonly-audit-framework/quickstart.md`.

**Dependências**: T132–133 definem os casos; T134–141 implementam vocabulário e fluxo. T137 depende de T134 e T136; T138–139 usam os tipos consolidados em T134; T142–144 fecham integração e revisão. T132, T134–136 e T140 podem avançar em paralelo por tratarem arquivos distintos; T133 pode ser preparado em paralelo à fixture, mas só é aceito após T132. T142–143 dependem de T132–141.

## Phase 30: Validação humana final

- [ ] T105 Conduzir com leitor humano sem contexto a validação cronometrada do registro canônico sintético atualizado para schema 2.1.0 em `tests/fixtures/readonly-audit/sample-product.md`; medir localização de produto/contexto e contribuição (meta ≤60 s) e percurso até evidência aprofundada (meta ~5–10 min), registrar perfil não identificável, tarefa, tempos, resultado e eventuais findings em `specs/001-readonly-audit-framework/quickstart.md` conforme SC-025, somente depois de todos os registros e incrementos estarem prontos.

## Dependências e execução incremental de US14

- US14 depende das entidades compartilhadas de evidência/contribuição consolidadas pelas fases anteriores; não depende de US11 (revisão opcional da superfície) e pode ser entregue incrementalmente após US12/US13.
- Fase 28 produz capacidade de reconstrução independentemente da avaliação de superfície. Fase 29 integra privacidade e rastreabilidade. Fase 30/T105 permanece a última validação humana, conforme decisão registrada para SC-025.
- SC-046 usa cenários representativos, perfil, perguntas e critérios qualitativos definidos previamente, sem criar taxa/limiar não aprovado. Casos de automação estática não substituem a observação humana requerida por SC-025.

## Rastreabilidade adicional US14

| Requisitos | Tarefas |
|---|---|
| FR-114–116 | T132–137; contrato T133 |
| FR-117–120 | T132, T134–138; T144 |
| FR-121–122 | T132–133, T136, T138, T141–144 |
| FR-123–124 | T133, T136, T138–141, T144 |
| FR-125 | T133, T141, T144 |
| SC-038–045 | T132–144 |
| SC-046 | T133, T141, T144 |
| SC-047 | T133–134, T141, T144 |
| SC-025 | T105 (última tarefa; executar após registro final) |
