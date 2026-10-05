# Implementation Plan: Framework de auditoria readonly e prontidão para portfólio

**Branch**: feature/001-readonly-audit-framework | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from /specs/001-readonly-audit-framework/spec.md

**Status do planejamento**: O corpo histórico abaixo documenta a implementação-base e os complementos US8–US11. Esta atualização planeja US12–US13 (tags técnicas, consultas qualificadas e contribuição individual). Requisitos atuais são governados pela spec e constituição v3.0.0.

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
3. **Camadas editoriais**: uma leitura rápida aponta para evidência profunda no mesmo documento. Storytelling segue os campos FR-083 quando há suporte; pacote Featured é recomendação proporcional (FR-084), não gate de inclusão.
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
- A constituição v2.0.0 atualiza o contrato do produto para skills, fluxo readonly e Markdown canônico; mantê-la no mesmo conjunto revisável da implementação. A data de ratificação original continua TODO até que haja evidência.
- Nenhuma confirmação humana, licença, autoria, liderança, publicação ou métrica pode ser inventada a partir de sinais estáticos.

**Scale/Scope**: Primeiro ciclo suporta vários alvos explicitamente agrupados em um produto, ou um único repositório; publica um arquivo Markdown por produto. Monorepos são um alvo com sistemas/domínios internos. Serviços/repositórios distintos permanecem ligados somente quando essa relação é indicada ou demonstrada.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Gate após a emenda constitucional

| Princípio/contrato 2.0.0 | Resultado | Tratamento neste plano |
|---|---|---|
| I. Evidence-Based Analysis | PASS | Preservar distinção fato/inferência, evidência/limite e desconhecido; não elevar análise estática a prova de runtime. |
| II. Generic Core and Additive Methods | PASS | Preservar base genérica; especializações aditivas não substituem evidência comum. |
| III. Read-Only Procedure and Privacy by Default | PASS WITH DISCLOSED LIMITATION | Proibir escrita/execução intencional pelo agente; host enforcement recomendado, ausência gera aviso e proíbe claims de preservação garantida. |
| IV. Versioned Markdown Source of Truth | PASS | Entregar um Markdown local versionado por produto sem relatórios ou anexos alternativos. |
| V. Modular, Agent-Guided Method | PASS | Usar skill principal, runbooks focados, contratos por etapa e fixtures controladas. |
| Product and Technology Constraints | PASS | O produto é local e Codex-guided; Bash/Python são ferramentas opcionais somente se respeitarem os contratos. |
| Development Workflow | PASS WITH MIGRATION | Atualizar documentação, CI e retenção legada para refletir a experiência de skill/Markdown. |

**Estado do gate**: A constituição v3.0.0 substituiu o bloqueio por aviso e preservação observada quando enforcement não foi comprovado. A data original de ratificação permanece TODO até confirmação.

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
- .specify/memory/constitution.md: proposed v2.0.0 before implementation
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
