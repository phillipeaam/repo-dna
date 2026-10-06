# Implementation Plan: Framework de auditoria readonly e prontidão para portfólio

**Branch**: feature/001-readonly-audit-framework | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from /specs/001-readonly-audit-framework/spec.md

**Status do planejamento**: O corpo histórico abaixo documenta a implementação-base e os complementos US8–US13. O complemento final planeja US14 (reconstrução de contribuição e narrativa técnica baseada em evidências). Requisitos atuais são governados pela spec e constituição v3.0.0.

## Complemento de design — US10/US11 (2026-10-05)

### Resumo

Estender a mesma fonte de verdade Markdown com prontidão editorial por projeto (brief contextual opcional, papel editorial separado do contexto, leitura rápida, histórias de engenharia, pacotes proporcionais de evidência e matriz de prontidão) e, somente quando solicitado, avaliar uma superfície de portfólio observável. A avaliação de site/protótipo é uma seção no mesmo arquivo do produto, sem construir/publicar o site, criar relatório paralelo ou alterar a superfície. Nenhuma identidade, claim ou decisão específica dos materiais de pesquisa vira padrão do framework.

### Contexto técnico para esta extensão

**Linguagem/versão**: Markdown de skills, runbooks, contratos e fixtures; sem nova linguagem de produção.
**Dependências**: Codex e artefatos locais existentes; navegador/acesso público somente quando a superfície for selecionada. Sem Notion, login, dependência nova ou serviço externo obrigatório.
**Persistência**: Seções no mesmo `analysis-output/<safe-product-slug>.md`; brief e estado da decisão recebem origem e status. Nenhuma segunda saída persistente.
**Validação**: Fixtures sintéticas do framework para cobertura de campos, evidência, classificação, estados `not_observed` e procedimento; nunca executar código de projeto auditado. Este plano não executa validação.
**Plataformas**: Windows, Linux e macOS sob o procedimento readonly vigente; limitações de acesso/viewport são reportadas.
**Restrições**: FR-001–077, contrato Markdown, constituição v3.0.0, FR-094; sem autenticação, ações de estado, submissão, edição ou publicação; fatos ausentes continuam desconhecidos.
**Escopo**: US10 P1 e US11 P2, mais atualização de navegação/cobertura e roteiro de validação para o mesmo relatório.

### Decisões e pesquisa

1. **Compatibilidade do relatório**: adicionar seções opcionais e versionar a estrutura do Markdown; leitores de relatórios existentes devem tolerar ausência delas. Uma auditoria sem brief ou sem superfície continua válida.
2. **Separação semântica**: guardar contexto do projeto, papel editorial, recomendação do agente e decisão humana em campos distintos. Ranking é permitido somente sobre inventário comparável explicitamente selecionado (FR-079/080).
3. **Camadas editoriais**: uma leitura rápida aponta para evidência profunda no mesmo documento. As dimensões FR-083 são prompts investigativos de ordem livre; pacote Featured é recomendação proporcional (FR-084), não gate de inclusão.
4. **Proveniência e autorização**: cada claim, ativo, recomendação profissional e observação de superfície aponta para evidência/origem, status, baseline/contexto e limites. Permissão ou aprovação não é inferida (FR-085–088).
5. **Avaliação da superfície**: usar contrato condicional independente do runbook de conteúdo. Registrar páginas, viewports e interações realmente vistas; pontuações 1–5 são julgamentos profissionais justificados, não benchmark/certificação. Cada dimensão ausente vira `not_observed` (FR-089–091).
6. **Pesquisa externa**: opcional e limitada a decisões abertas relevantes; referências com título, URL e data, separadas de julgamentos (FR-092). Não é requisito para produzir análise.
7. **Gates humanos**: conflito material ou decisão que dependa da pessoa usuária permanece pendente e é apresentada para resolução, sem tratar recomendação como aprovada (FR-093).

Não há decisão tecnológica externa pendente. O desenho usa os contratos Markdown, workflow, runbooks e vocabulário locais; nenhuma pesquisa de concorrentes ou browsing é necessária para criar a capacidade genérica.

### Checagem constitucional pós-design

**PASS**: exatamente um Markdown persistente por produto; leitura estática/readonly; nenhuma execução no alvo; alegações e notas ligadas a evidência e limite; método utilizável sem Notion; recomendações permanecem distintas de decisões humanas; cobertura e limitações visíveis. Não muda host enforcement nem autoriza edição/publicação do site.

### Estrutura de implementação desta extensão

- `.agents/skills/repodna-audit/SKILL.md` e `references/workflow.md`: entrada condicional, sequência, dependências locais e checkpoints de US10/US11.
- `references/consolidation.md`, `references/publication-b4.md`, `references/evidence-vocabulary.md`: seções no Markdown único e regras editoriais/claims/ativos.
- novo `references/portfolio-surface-review.md`: escopo, método, rubrica, evidência e limites da revisão visual/interativa readonly.
- `specs/001-readonly-audit-framework/contracts/source-of-truth-markdown.md`, `contracts/input-output.md` e novo `contracts/portfolio-readiness.md`: contrato de dados e resultado.
- `data-model.md`, `methodology.md`, `source-inventory.md`, `quickstart.md`: entidades, cobertura local e validação planejada.
- `tests/fixtures/readonly-audit/` e `tests/`: casos fictícios/contratuais; sem páginas ou dados pessoais reais.

**Estratégia**: primeiro firmar termos compartilhados e seção opcional do relatório; entregar US10 como incremento P1; depois US11 com runbook condicional; finalizar rastreabilidade, início rápido e fixtures. A atualização não reabre fases anteriores concluídas nem implementa o site.

## Complemento de design — US12/US13 (2026-10-05)

### Resumo

Estender a mesma fonte canônica para responder que tecnologia, framework, package, padrão, prática, ferramenta, técnica de IA e codec foram encontrados; em que sistema e contexto aparecem; que evidência permite qualificá-los; e quais contribuições de cada pessoa estão ligadas a essas ocorrências. O índice de tags será uma projeção legível de registros e ocorrências no Markdown atual, não um catálogo, relatório ou serviço separado.

### Contexto técnico para esta extensão

**Linguagem/versão**: documentos Markdown locais e instruções/fixtures já existentes; sem linguagem de produção ou dependência nova.
**Dependências**: leitura estática de fontes locais, histórico Git já acessível e contexto fornecido voluntariamente. Fontes externas e parsers existentes são opcionais; ausência de rede não bloqueia a execução.
**Persistência**: o relatório canônico existente passa a schema `2.1.0`, por adição de seções e campos compatíveis, no mesmo `analysis-output/<safe-product-slug>.md`. Nenhum arquivo secundário por tecnologia/pessoa é entregue.
**Validação**: fixtures sintéticas para dependências declaradas/resolvidas/disponíveis/usadas/configuradas, padrões falso positivo e demonstrado, sinais de assistência IA e integração de produto, codec versus contêiner, aliases, contribuições não técnicas, consulta individual e migração. A extensão não executa o alvo.
**Plataformas**: Windows, Linux e macOS sob o procedimento estático/readonly já governado.
**Restrições**: FR-001–113, constituição v3.0.0 e contratos atuais; método local e único Markdown permanecem autoridade. Sem Notion, catálogo online obrigatório, instalação, build, execução, heurística de autoria, detecção IA por estilo ou transferência de dados privados à documentação do framework.
**Escopo**: US12 (P1) e US13 (P1), acrescidas de navegação, cobertura, migração de schema e fixtures do mesmo contrato.

### Decisões de design e pesquisa

1. **Facetas locais**: usar chave `faceta:slug`, rótulo e aliases opcionais no vocabulário local versionado. PURL/SBOM, SKOS/RDF e catálogos externos informam conceitos possíveis; nenhum formato ou serviço externo passa a ser requisito.
2. **IDs/relação**: `T-###` identifica registro técnico, `O-###` ocorrência localizada, `P-###` identidade e `K-###` contribuição; todos ligam-se aos `E-###`, `F-###`, `Q-###`, sistemas e baselines atuais. Índice e corpo do mesmo Markdown derivam desses registros.
3. **Eixos independentes**: classificação atual preserva `installed`, `possible_use`, `observed_use`, `active_configuration`, condicionada a evidência própria. Declaração em manifest, versão resolvida em lock, pacote disponível, fluxo consumidor e configuração selecionada não são sinônimos; relação de dependência, versão, origem, contexto, temporalidade e exercício são campos separados.
4. **Relevância**: inventário mantém candidatos/dependências; destaque editorial justifica papel técnico observado. Popularidade e listas de vagas não provam uso, qualidade, relevância ou domínio individual.
5. **Padrões**: nomear padrão conhecido somente com relação/comportamento, participantes e escopo; classe, pasta e prosa são pistas. Distinguir estrutura observada, declaração, inferência limitada, integração de terceiro e implementação própria.
6. **IA**: classificar separadamente assistência de desenvolvimento, integração do produto, técnica e provedor/modelo. Presença de instruções é sinal de preparação, não prova de atividade; declaração e registro de tarefa correlacionado têm forças distintas. Nunca inferir IA por estilo ou fração de linhas.
7. **Mídia**: identificar separadamente contêiner/formato e codec; extensão sozinha não confirma codec. Sem metadados estáticos disponíveis, marcar desconhecido; não executar FFprobe ou binário do alvo.
8. **Créditos**: lista informa fontes e cobertura, usa IDs estáveis e reconhece trabalho além de commits. Author, committer, coautor, CODEOWNERS, equipe, bot/IA e criadores de assets de terceiros permanecem categorias distintas. Aliases só se unem com evidência; trabalho relatado mantém `personal_account`.
9. **Atribuição individual**: tags técnicas do projeto não são herdadas por uma pessoa. Ligação pessoa → contribuição → ocorrência/sistema precisa de prova própria; período observado não equivale a duração de emprego. Identidade/divulgação desconhecida limita a projeção pública.
10. **Consultas**: o perfil padrão retorna `observed_use` atual, não stale e referenciado; perfil de configuração ativa, experiência individual sustentada, exploratório, histórico e assistência IA preservam qualificador/escopo/baseline/evidência.
11. **Compatibilidade**: schema `2.1.0` é aditivo; relatórios 2.0.0 continuam legíveis e são migrados no mesmo arquivo ao atualizar. Ausência de nova seção em documento legado significa cobertura ainda não migrada, não ausência de tecnologia ou pessoa.
12. **Sequência**: firmar modelo e contrato canônico, implementar descoberta/indexação da US12, estender créditos e vínculo individual da US13, integrar quickstart/migração e validar os cenários com dados fictícios. Nenhuma validação humana SC-025/T105 é antecipada.

### Checagem constitucional pós-design

**PASS**: fontes locais e não confiáveis são lidas sem execução; não há dependência externa; facts, inferências e relatos mantêm seus tipos; toda ocorrência preserva prova e limites; a ligação pessoal é conservadora; exemplos e fixtures são sintéticos; o único Markdown é a autoridade e migração mantém seu histórico. Nenhuma mudança ao alvo auditado ou à política de enforcement é permitida.

### Estrutura de implementação desta extensão

- `specs/001-readonly-audit-framework/data-model.md`: vocabulário, registros técnicos/ocorrências, pessoas e vínculos.
- `contracts/source-of-truth-markdown.md` e `contracts/input-output.md`: headings, schema `2.1.0`, campos mínimos, consultas qualificadas e fontes estáticas permitidas.
- `.agents/skills/repodna-audit/references/evidence-vocabulary.md`, `forensic-a1.md`, `production-b1.md`, `workflow.md`, `consolidation.md` e novos/atualizados runbooks necessários: descoberta e regras de atribuição.
- `.agents/skills/repodna-audit/SKILL.md`: índice e navegação da skill principal.
- `specs/001-readonly-audit-framework/research.md` e `quickstart.md`: decisões locais e cenários sintéticos verificáveis.
- `tests/fixtures/readonly-audit/`, testes de contrato existentes e scripts públicos: casos sem identidades reais, com guard de privacidade preservado.

**Estratégia incremental**: contratos e IDs compartilhados primeiro; US12 produz índice e registros tecnológicos com uso/contexto rastreáveis; US13 acrescenta lista de contribuidores e vínculos técnicos individuais; migração/consulta offline e fixtures fecham integração. SC-025/T105 permanece bloqueado para a validação humana final anteriormente combinada.

## Summary

Entregar um fluxo de auditoria local guiado por uma skill principal do Codex, com processos reutilizáveis para preparação, A1, B1–B4, reconciliação, consolidação e revisão. O resultado persistente será exatamente um Markdown por produto em analysis-output/<slug>.md, com conclusões, evidências, índice, histórico e apêndices no mesmo arquivo.

Os repositórios serão selecionados em target-repos/. A análise será exclusivamente estática: nenhum fluxo desta feature inicia ou orquestra execução de código, scripts, builds, testes, hooks, plugins, macros, código de editor ou profiling do alvo. Validação dinâmica fica fora do framework e pertence a processo externo independente. O agente segue um procedimento de não escrita; enforcement do host é recomendado, mas a falta dele gera aviso e limitação de preservação, não bloqueio. O plano também não chamará o CLI legado como está: seu pipeline entra no repositório e cria resultados ali. Capacidades úteis dos coletores existentes serão reaproveitadas seletivamente, após expor interfaces que não escrevam no alvo nem entreguem outros relatórios. A constituição foi atualizada para v3.0.0 para refletir o fluxo procedural e a limitação explícita de preservação.

## Technical Context

**Language/Version**: Markdown de skills, runbooks e contrato de saída; Bash 4.3+ e Python 3.11+ são capacidades opcionais de coletores locais confiáveis já existentes, não linguagem obrigatória do fluxo principal.

**Primary Dependencies**: Codex agent skill discovery em .agents/skills/; Git para leituras de histórico; acesso a arquivos somente leitura; ferramentas locais atuais somente por interfaces auditadas. Nenhum serviço externo é requisito.

**Storage**: Entradas em target-repos/<nome-do-repositorio>/; uma entrega persistente por produto em analysis-output/<slug-do-produto>.md. Estado intermediário é descartável, fora do alvo e nunca entregue como arquivo paralelo.

**Testing**: Validação documental e de contrato para as skills/Markdown, cenários de aceitação com fixtures incluindo alterações preexistentes e arquivos ignorados, verificação do alvo antes/depois e confirmação de um único arquivo Markdown final. As tarefas definirão os comandos existentes que ainda se aplicam; este planejamento não executa testes.

**Target Platform**: Fluxo local no Codex em Windows/Git Bash, Linux ou macOS. O agente atua por procedimento estático e não escrita intencional; quando o host não garante a fronteira, o fluxo avisa e marca preservação como não verificada/observada.

**Project Type**: Framework local de auditoria conduzido por agente, integrado ao Codex e ao Spec Kit do repositório.

**Performance Goals**: Não há SLA. O método prioriza cobertura informada, retomada e preservação; limites de escala e cobertura por projeto serão observados e reportados sem abandonar silenciosamente etapas.

**Constraints**:
- Ler o alvo como dado não confiável; nunca executar seus scripts, build, testes, hooks, plugins, macros ou código de editor.
- Manter o produto estritamente estático: validação dinâmica/profiling não pode ser iniciada nem orquestrada pelo framework, mesmo quando solicitada; processos externos independentes estão fora do escopo e dos entregáveis.
- Verificar caminho real, Git externo, submódulos, symlinks/junctions e colisões de slug.
- Antes da leitura substantiva, registrar política de escrita conhecida e alertar se o alvo/Git intersectar raiz gravável ou a política for desconhecida; não bloquear somente por essa razão. Manter `analysis-output/` fora do alvo e tratar comparação final como observação, não enforcement.
- git status sozinho não comprova preservação; comparar conteúdo e estado observável dos arquivos dentro do escopo.
- Gravar somente a entrega Markdown em analysis-output/; temporários de execução devem ficar fora dos alvos e ser removidos.
- Não emitir HTML, relatórios JSON/CSV, pacotes ZIP, anexos por sistema, export para Notion ou publicação externa.
- Não usar dna-analysis.sh nem src/pipeline/context.sh inalterados: a pipeline atual resolve OUTPUT_DIR para dentro de REPO_ROOT, muda o diretório de trabalho e cria estrutura/arquivos de relatório.
- A constituição vigente v3.0.0 governa skills, análise estática procedural, privacidade e Markdown canônico; sua data de ratificação original não foi estabelecida nos registros disponíveis e permanece desconhecida.
- Nenhuma confirmação humana, licença, autoria, liderança, publicação ou métrica pode ser inventada a partir de sinais estáticos.

**Scale/Scope**: Primeiro ciclo suporta vários alvos explicitamente agrupados em um produto, ou um único repositório; publica um arquivo Markdown por produto. Monorepos são um alvo com sistemas/domínios internos. Serviços/repositórios distintos permanecem ligados somente quando essa relação é indicada ou demonstrada.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Gate após a emenda constitucional

| Princípio/contrato v3.0.0 | Resultado | Tratamento neste plano |
|---|---|---|
| I. Evidence-Based Analysis | PASS | Preservar distinção fato/inferência, evidência/limite e desconhecido; não elevar análise estática a prova de runtime. |
| II. Generic Core and Additive Methods | PASS | Preservar base genérica; especializações aditivas não substituem evidência comum. |
| III. Read-Only Procedure and Privacy by Default | PASS WITH DISCLOSED LIMITATION | Proibir escrita/execução intencional pelo agente; host enforcement recomendado, ausência gera aviso e proíbe claims de preservação garantida. |
| IV. Versioned Markdown Source of Truth | PASS | Entregar um Markdown local versionado por produto sem relatórios ou anexos alternativos. |
| V. Modular, Agent-Guided Method | PASS | Usar skill principal, runbooks focados, contratos por etapa e fixtures controladas. |
| Product and Technology Constraints | PASS | O produto é local e Codex-guided; Bash/Python são ferramentas opcionais somente se respeitarem os contratos. |
| Development Workflow | PASS WITH MIGRATION | Atualizar documentação, CI e retenção legada para refletir a experiência de skill/Markdown. |

**Estado do gate**: A constituição v3.0.0 substituiu o bloqueio por aviso e preservação observada quando enforcement não foi comprovado. A data original de ratificação não foi estabelecida nos registros disponíveis e permanece desconhecida, conforme indicado na constituição.

### Gate após design

**PASS WITH PROCEDURAL READONLY LIMITATION**: o desenho está alinhado à constituição v3.0.0. O agente não escreve intencionalmente e não executa o alvo. Ausência de host enforcement é registrada e reduz a confiança em preservação, sem impedir análise estática.

## Project Structure

### Documentation (this feature)

- specs/001-readonly-audit-framework/plan.md
- specs/001-readonly-audit-framework/research.md
- specs/001-readonly-audit-framework/data-model.md
- specs/001-readonly-audit-framework/quickstart.md
- specs/001-readonly-audit-framework/contracts/input-output.md
- specs/001-readonly-audit-framework/contracts/readonly-boundary.md
- specs/001-readonly-audit-framework/contracts/source-of-truth-markdown.md
- specs/001-readonly-audit-framework/methodology.md
- specs/001-readonly-audit-framework/source-inventory.md
- specs/001-readonly-audit-framework/checklists/requirements.md

### Product structure after implementation

- .agents/skills/repodna-audit/SKILL.md: entry point, orchestration, safety and gates
- .agents/skills/repodna-audit/references/workflow.md: phase order, checkpoints and resume behavior
- .agents/skills/repodna-audit/references/forensic-a1.md: repository, timeline, ownership and system analysis
- .agents/skills/repodna-audit/references/production-b1.md: configuration, build, content and architecture
- .agents/skills/repodna-audit/references/runtime-b2.md: static runtime, reliability and performance evidence
- .agents/skills/repodna-audit/references/provenance-b3.md: release and artifact chain
- .agents/skills/repodna-audit/references/publication-b4.md: credits, claims and media readiness
- .agents/skills/repodna-audit/references/consolidation.md: canonical Markdown, reconciliation and review
- .agents/skills/repodna-audit/references/evidence-vocabulary.md: shared states, confidence and references
- target-repos/: ignored selected local inputs
- analysis-output/: ignored; exactly one <slug>.md per product
- README.md: new Codex skill quickstart and replacement for legacy report tour
- .specify/memory/constitution.md: autoridade vigente v3.0.0
- tests/ and .github/workflows/: retain/adapt only checks relevant to delivered skills

**Structure Decision**: Uma skill audit principal mantém um ponto de entrada claro e carrega runbooks de referência focados por etapa. Isso permite reusar análises profundas sem repetir o método e permite auditorias parciais sem criar várias saídas. Skills e runbooks são instruções do produto; cada auditoria de projeto ainda entrega um único Markdown. Coletores existentes permanecem somente quando conseguem ler o alvo sem executar código e sem gravar nele; renderers que produzem muitos arquivos saem do caminho padrão. Não haverá um segundo aplicativo de relatório, suíte de exports ou integração Notion.

## Complemento: US8 e US9 — privacidade e autoridade local

**Date**: 2026-10-04. Complementa esta feature; não cria branch, spec ou autoridade paralela.

### Decisões e estrutura

- `private-context/research/`: cópias locais opcionais da procedência original antes da sanitização. Ignorar toda a raiz; nenhuma referência obrigatória do método aponta para ela. Não é saída de auditoria.
- `source-inventory.md`: substituir o inventário identificável por mapa público de temas e aprendizados locais. Preservar a versão original somente na área privada.
- `methodology.md`: manter as regras aprofundadas e generalizar os exemplos; a autoridade do método é local, sem links privados, nomes de casos ou datas particulares.
- `contracts/privacy-local-authority.md`: contrato de publicação do framework, separando instruções do método de evidências opcionais de um alvo.
- `scripts/check-public-context.py`: verificação de nomes de caminhos privados rastreados, links de páginas pessoais e caminhos de usuários nos documentos. Examinar blobs do índice e arquivos atuais, incluindo não rastreados não ignorados; `--ref` revisa a árvore exata destinada à distribuição. Diagnósticos mostram arquivo/regra, nunca o valor encontrado. Termos privados conhecidos podem ser fornecidos por `private-context/known-sensitive-terms.txt`, opcional e não distribuído; padrões genéricos e revisão humana continuam necessários sem essa lista.
- `tests/public_context_test.sh`: fixture sintética demonstra bloqueio de metadados privados, índice antigo mesmo com working tree limpo, área privada ignorada e diagnóstico sem vazamento.
- `tests/local_method_test.sh`: validar referências locais da skill e mapa de cobertura; original indisponível não exige conector ou credenciais. Não declara auditoria real validada nem altera a matriz readonly.
- README, CONTRIBUTING, documentação antiga e CI: instruir autoridade local, privacidade e executar os guards; não distribuir área privada. Arquivos já preparados para commit serão atualizados somente nos caminhos sanitizados/alterados neste complemento. Sem commit, push ou reescrita de histórico.

### Constituição e sequência

Princípios I/II preservam a semântica ao generalizar exemplos; III exige procedimento sem escrita intencional e transparência sobre enforcement; IV mantém um único entregável por auditoria; V mantém runbooks locais. A revisão 3.0.0 da constituição formaliza a mudança; prova de host é melhoria futura, não pré-requisito.

Ordem: preservar procedência e configurar exclusão → testar casos sintéticos de privacidade → sanitizar conteúdo e índice → validar mapa local completo → revisar distribuição/documentação → executar guards e suite. Python 3.11+ é dependência de desenvolvimento dos guards, não requisito de conexão externa ou pacote instalado no alvo. Nenhuma pesquisa externa ou decisão de tecnologia está pendente.

### Validação e limites

O guard automatiza padrões conhecidos, não certifica ausência universal de dados confidenciais. Revisão semântica humana é exigida antes de compartilhar. Verificar histórico dos caminhos afetados sem reescrevê-lo; se houver exposição passada, informar separadamente. A generalização preserva todos os temas do método incorporado, sem alegar copiar integralmente fontes originais.

## Complexity Tracking

| Violação | Necessidade | Alternativa simples rejeitada porque |
|---|---|---|
| Migração constitucional v2.0.0 | O produto muda de CLI/relatórios para skill readonly e Markdown canônico, alterando contratos obrigatórios. | Manter os contratos v1.0.0 deixaria o produto novo em violação permanente da governança. |
| Runbooks por etapa | A auditoria exige regras distintas de autoria, produção, runtime, release e publicação. | Um prompt longo e indiferenciado é difícil de revisar e fácil de executar parcialmente; uma única skill continua sendo o ponto de entrada. |
| Enforcement de escrita do host | gitignore e texto de skill não impedem escrita no filesystem. | Nesta fase, não bloqueará o fluxo: o método declara o risco, não promete garantia e mantém prova de host como evolução futura. |

## Complemento de design — US14: reconstrução de contribuição e narrativa técnica (2026-10-05)

### Objetivo e decisões

Adicionar ao método de auditoria a reconstrução de contribuição, decisões e raciocínio de projetos antigos a partir de fontes autorizadas, dentro do mesmo Markdown 2.1.0. A reconstrução pode ser parcial quando a memória ou fontes forem limitadas; desconhecido não é convertido em ausência, e a evidência sempre precede a redação.

1. **Autoridade e fontes**: usar o repositório/baseline local, histórico Git local, documentos/logs fornecidos pelo usuário e fontes públicas sem autenticação explicitamente selecionadas. Não adicionar integração ou acesso a conta privada. Issues, reviews e releases só são fontes quando materializadas localmente, fornecidas ou publicamente legíveis.
2. **Modelo de alegação**: cada claim de reconstrução referencia evidências recuperáveis e seu escopo; registra relação de suporte, tipo, caveat, confiança qualitativa justificada e estado de revisão. `hypothesis` é uma classificação de trabalho, não evidência e não substitui `fact`, `inference`, relato, conflito ou unknown. `high`/`medium`/`low` usam critérios compartilhados de direção/tipo de fonte, corroboração, contradição e escopo; ausência de suporte fica sem nota.
3. **Papéis independentes**: autoria registrada, mudança/contribuição, comportamento técnico, decisão/intenção relatada, colaboração, validação e efeito são relações distintas. Não inferir decisão, colaboração ou propriedade integral apenas de commit/roster/sistema.
4. **Narrativa editorial**: os itens de FR-083 tornam-se perguntas/dimensões de investigação, não sequência fixa, headings mandatórios ou preenchimento simétrico. Prosa pode variar; selecionar zero a três destaques concisos, conforme evidência e relevância, todos como drafts revisáveis.
5. **Consequência e validação**: explicar efeitos diretos observáveis separadamente de benefícios hipotéticos. Distinguir teste presente/configurado, resultado existente, revisão, experimento e release; qualquer resultado fica limitado a snapshot, cenário e ambiente. Não executar o alvo.
6. **Memória e perguntas**: reconstruir candidatos com evidência, alternativas/contraevidência, confiança e limitações. Perguntar à pessoa somente quando a resposta puder mudar materialmente atribuição, interpretação ou redação segura; lacuna irrecuperável não bloqueia o restante.
7. **Avaliação de qualidade**: validar com projetos/fixtures representativos, perguntas predefinidas e perfis de revisão; capturar observações e gaps qualitativos. Não inventar score percentual, taxa de sucesso ou promessa de contratação sem baseline empírico aprovado.
8. **Evolução do contrato**: manter schema 2.1.0 e expandir aditivamente os registros existentes de evidência/claim/contribuição; não criar artefato de saída ou identidade paralela. Alterações incompatíveis futuras exigem migração explícita no mesmo Markdown.

### Design documental

- `data-model.md`: formalizar `Engineering Reconstruction`/`Highlight`, tipo `hypothesis`, relação claim–evidência, rubrica de confiança e confidence rationale; definir campos de autoria, suporte/contraevidência, escopo e review status.
- `contracts/source-of-truth-markdown.md` e `contracts/portfolio-readiness.md`: substituir a sequência narrativa fixa por dimensões opcionais e ordem livre; exigir rastreabilidade, caveats e status de draft.
- `methodology.md` e runbooks locais de evidência/consolidação: descrever reconstrução, matriz de força por tipo de fonte, limites de inferência e perguntas de alto valor.
- `quickstart.md` e `tests/fixtures/readonly-audit/`: acrescentar cenários sintéticos para memória limitada, conflito, autoria coletiva, benefício plausível sem medição, teste sem resultado, fonte privada indisponível, prosa fora da ordem antiga, zero destaques e revisão de draft.
- `spec.md` e checklist: US14, FR-114–125 e SC-038–047 são autoridade do escopo; SC-046 usa observação qualitativa e perguntas/critérios prévios, e SC-047 verifica calibração justificada da confiança.

### Estratégia de implementação

Primeiro ajustar modelo e contrato de claim/evidência; depois atualizar regras de investigação e síntese editorial; em seguida produzir fixtures e validação de contrato; por fim atualizar índice/navegação e critérios de aceitação. US14 pode ser entregue como processo documental e de validação independente da avaliação opcional da superfície (US11), mas reutiliza entidades da US13 (pessoas/contribuições) e bases comuns A1/claim. Nenhum teste será executado contra `target-repos/`.

### Checagem constitucional pós-design

**PASS**: evidência e confiança são explícitas; hipótese não substitui fonte; autoria e impacto não são superestimados; fontes privadas não viram dependência; alvo continua somente leitura; uma única página Markdown permanece canônica; lacunas, limites e revisão humana ficam visíveis. O desenvolvimento dos validadores/fixtures do framework não executa conteúdo do alvo.

### Pesquisa e questões restantes

Não há decisão factual, tecnológica ou de acesso que exija pesquisa externa ou pergunta adicional ao usuário: spec, constituição e contratos locais fixam as fronteiras. O ponto antes conflitante (ordem narrativa fixa vs. prosa flexível) foi resolvido pela decisão de que FR-083 fornece dimensões de investigação opcionais; os contratos serão alinhados. Nenhuma nova integração é necessária.

## Complemento de design — US14: procedência e adequação das fontes (2026-10-06)

### Decisão de produto

Implementar FR-127/SC-050 aditivamente ao modelo de evidência e à reconstrução US14. Cada relação fonte→claim avalia a adequação da fonte à dimensão afirmada e mantém essa avaliação separada da confiança da claim. Registrar origem/autoria conhecida, datas disponíveis, snapshot/versão, localização recuperável, natureza da fonte, atualidade e independência/corroboração quando houver suporte. Atributos ausentes ficam `unknown`; não há ranking universal, score de confiabilidade da fonte, hash ou cópia preservada obrigatórios.

### Contexto técnico e limites

- **Plataforma/stack/dependências**: extensão documental do framework e dos validadores/fixtures existentes; nenhuma nova linguagem, pacote, serviço, rede ou acesso a conta é necessário.
- **Persistência**: campos aditivos nos registros do mesmo Markdown schema 2.1.0; nenhum artefato persistente adicional.
- **Privacidade**: metadados de autor/origem só entram na saída se forem necessários e autorizados; segredos, identidade civil/contato e contexto privado desnecessário permanecem mascarados ou omitidos.
- **Validação**: casos sintéticos cobrem procedência completa/parcial, autor/data desconhecidos, fonte direta versus relato, fontes não independentes e claim para dimensão inadequada. Validador lê fixtures do framework apenas; nunca executa nem lê `target-repos/`.
- **Execução**: análise de alvo permanece estática/readonly. Proveniência registrada não certifica autenticidade nem elimina necessidade de validação externa.

### Artefatos de design

- `research.md`: D26 e alternativas; decisão incorporada.
- `data-model.md`: ampliar Fonte/evidência e Relação de suporte para procedência, atualidade, natureza, independência e adequação por dimensão, sem score universal.
- `contracts/source-of-truth-markdown.md`: definir campos requeridos ou `unknown` para fontes de claims materiais; manter confiança da claim separada.
- `methodology.md` e `.agents/skills/repodna-audit/references/engineering-reconstruction.md`: acrescentar matriz de procedência/adequação e verificação de independência/origem comum.
- `.agents/skills/repodna-audit/references/evidence-vocabulary.md` e `consolidation.md`: vocabulário/campos canônicos no mesmo Markdown; preservar minimização de dados e schema.
- `.agents/skills/repodna-audit/SKILL.md`: navegação e regra de inspeção local.
- `quickstart.md` e `tests/fixtures/readonly-audit/engineering-reconstruction/`: casos de aceitação sintéticos ligados a SC-050.
- `tests/engineering_reconstruction_contract_test.sh`: verificar campos, estados desconhecidos, adequação contextual separada de confidence, corroboração independente e ausência de ranking/hash obrigatório.

### Estratégia e gates constitucionais

Ordem: formalizar campos e semântica no modelo/contrato; atualizar vocabulário e runbook; ampliar fixtures e verificador; integrar consolidação e navegação; revisar quickstart, privacidade e rastreabilidade. Não reabrir ou renumerar tarefas concluídas de US14. As novas tarefas devem ser acrescentadas antes da T105, que continua sendo a última validação humana após todos os registros estarem prontos.

**Constitution Check: PASS** — atende princípios I/III/IV/V: fonte e adequação ficam rastreáveis e sem alegar autenticidade; o alvo não é executado; nenhum dado privado é exposto por padrão; a saída segue sendo um Markdown único; validação usa somente fixtures sintéticas controladas.
