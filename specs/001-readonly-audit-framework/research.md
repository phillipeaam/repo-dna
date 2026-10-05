# Research: Framework de auditoria readonly

**Feature**: [spec.md](spec.md)
**Date**: 2026-10-04
**Scope**: Resolver decisões de produto e arquitetura necessárias ao plano. Pesquisa feita no repositório e nas fontes Notion indicadas; nenhuma página Notion foi alterada.

## Decisions

### Complemento 2026-10-04: privacidade e método local

**Decision**: Preservar procedência original em `private-context/`, local e ignorado. Generalizar os documentos públicos sem eliminar os ensinamentos. O conjunto local aprovado é a autoridade do método e nenhuma página original é pré-requisito.

**Rationale**: Títulos, IDs, links, nomes e históricos particulares não são necessários para executar o método e não receberam autorização de publicação. Preservar a procedência local permite conferir a extração sem expor os casos.

**Alternatives considered**: Versionar inventário privado foi rejeitado pela divulgação desnecessária; apagar toda a pesquisa foi rejeitado por perder procedência; consultar fontes originais a cada auditoria foi rejeitado por impedir independência local. Não há decisão em aberto.

**Validation**: Guard de documentos atuais e blobs preparados para commit; casos sintéticos de índice antigo e valores privados; mapa de temas locais e referências da skill. Limites: padrões não reconhecem toda informação confidencial e nenhuma limpeza atual elimina exposição em commits passados.

### 1. Skill do Codex é a experiência principal

**Decision**: Um ponto de entrada .agents/skills/repodna-audit/SKILL.md orquestra runbooks de preparação, A1, B1–B4, reconciliação, consolidação e revisão em references/. Fases de aprofundamento podem ser executadas isoladamente, mas somente a skill principal fecha auditoria e consolida o arquivo.

**Rationale**: O projeto já tem integração do Spec Kit para Codex em .agents/skills; a especificação exige fluxo de agente e gates definidos. Separar critérios por fase evita um prompt único extenso e mantém um início reconhecível.

**Alternatives considered**:
- Manter repodna analyze como experiência central: rejeitada porque o usuário solicitou abandonar o produto independente atual.
- Uma skill monolítica sem runbooks: rejeitada por tornar regras de autoria, runtime e publicação difíceis de revisar sem repetição.
- Um novo servidor de agente ou app de desktop: fora de escopo, exige integração/instalação adicional que esta necessidade não requer.

### 2. O único produto da auditoria é um Markdown local

**Decision**: Escrever/atualizar exatamente analysis-output/<safe-product-slug>.md por produto. Consolidação, evidências, índices, claims, referências, estado das etapas, perguntas e apêndices ficam no mesmo arquivo. Não produzir dashboards, HTML, JSON/CSV de relatório, pacotes ZIP, documentos auxiliares por sistema ou Notion exports. Coletores podem usar valores em memória ou scratch descartável externo, se necessário.

**Rationale**: A decisão do usuário de 2026-10-04 exige centralizar tudo num Markdown e remover outras formas. Relatórios legados derivam de múltiplos geradores no caminho padrão.

**Alternatives considered**:
- Markdown + HTML ou relatórios separados: explicitamente removidos pelo usuário.
- Escrever em Notion: as páginas da pesquisa são somente leitura e o usuário decidiu centralização local.
- Entregar canonical JSON ao lado de Markdown: criaria uma segunda representação persistente, proibida pela decisão.

**Consequence**: JSON interno não pode ser chamado de canonical report na nova experiência; ou é memória temporária/transporte validado, ou deixa de ser produzido nesse fluxo.

### 3. Um produto pode agrupar repositórios explicitamente

**Decision**: Um diretório sob target-repos/ representa um repositório. O usuário inicia indicando um repositório ou relaciona vários como componentes do mesmo produto. A skill não funde produtos automaticamente por organização/nome. Cada produto produz um slug Markdown; colisões e associação incerta são resolvidas antes de consolidar.

**Rationale**: Os cases incluem produto, pacote/cliente/serviço em outros repositórios e também sucessores que devem permanecer separados. Não existe atualmente um manifesto de auditoria multi-repo no repo.

**Alternatives considered**:
- Requerer manifesto/config extra em cada diretório: acrescenta configuração ao gesto simples de colocar a cópia do repo.
- Agrupar automaticamente todos os alvos por organização/nome: arrisca misturar produtos distintos e autoria.

### 4. Readonly procedural agora; enforcement do host como evolução futura

**Decision (revisada em 2026-10-04)**: A skill delimita caminhos reais, recusa execução e escrita intencional no alvo, e usa leitores estáticos. Quando a sessão tem escrita ou a política é desconhecida, avisa o usuário e pode prosseguir; o resultado descreve a preservação como não verificada/observada, sem alegar proteção do host. Uma fixture controlada pode elevar a confiança no futuro, mas não é pré-requisito do fluxo atual.

**Rationale**: target-repos/ é ignorado pelo Git, mas continua dentro do checkout; .gitignore não limita permissão. O CLI atual usa cd "$REPO_ROOT", resolve o output padrão sob esse root e cria várias pastas/arquivos ali. Não é um caminho seguro de coleta.

**Trade-off aceito nesta fase**: procedimento e comparação não são enforcement; um bug, ferramenta incidental ou comportamento do host ainda pode gravar no alvo. Essa possibilidade deve ser avisada e nunca ocultada como garantia.

**Alternatives considered**:
- Bloquear até existir enforcement: mais seguro preventivamente, mas impede o uso inicial no host atual; adiado para evolução futura.
- Fazer só git status no fim: ignora alterações untracked/ignored ou conteúdo alterado; por isso o workflow compara conteúdo e estado dentro da cobertura declarada.
- Marcar arquivos read-only e continuar com a mesma identidade/sandbox: atributo é reconfigurável e não equivale a isolamento do processo.
- Executar builds/testes do alvo: contradiz o escopo estático; resultados dinâmicos não pertencem ao fluxo padrão.

**Condition**: Marcar o perfil de host como `enforced` somente após prova controlada. Enquanto isso, permitir uso procedural com aviso e preservar a distinção entre intenção do agente, estado observado e prevenção efetiva.

### 5. Reusar análise legada seletivamente

**Decision**: Inspecionar coletores e reaproveitar detecção, Git, grafos, dependências, privacidade, secrets e adaptadores que possam consumir o alvo sem executar seus programas nem gerar outputs nele. Não chamar dna-analysis.sh nem o pipeline atual de entrega. Remover do caminho principal os documentos que anunciam HTML/JSON/CSV/archives como produto.

**Rationale**: Os coletores genéricos e adaptadores contêm análise útil, mas src/pipeline/context.sh cria uma árvore de relatórios e muda para o repositório; o pipeline atual escreve arquivos sob esse root. Renderers hoje exigem JSON persistido e produzem múltiplos relatórios separados.

**Alternatives considered**:
- Copiar todo RepoDNA para um novo analisador: duplica lógica e aumenta risco de inconsistência.
- Usar CLI e apagar resultados após geração: ainda escreve no alvo e pode falhar entre geração e limpeza.
- Manter dashboards opcionais: contraria o foco e cria dívida de produto/formato.

**Boundary**: Reaproveitar sinais/métricas úteis não torna o formato legado nem as interpretações automáticas uma autoridade para claims qualitativas.

### 6. Constituição v2.0.0 atualizada antes da implementação

**Decision**: A constituição foi atualizada explicitamente para v2.0.0 antes da implementação de runtime. I–III preservam evidência, núcleo genérico e privacidade com limite readonly. IV define o Markdown canônico versionado. V governa skills/processos modulares e validáveis. Product and Technology Constraints e Development Workflow agora refletem Codex, entradas/saídas locais e privacidade.

**Rationale**: A constituição v1.0.0 conflitou com o produto solicitado. A atualização major explicita o novo contrato antes de implementar runtime e conserva evidência, genericidade, privacidade e critérios de revisão. O gate readonly de host continua obrigatório.

**Alternatives considered**:
- Tratar a spec como exceção permanente: deixaria duas autoridades em conflito.
- Adiar emenda após implementar: violaria o gate de governança do repositório.
- Manter o CLI legado como runtime permanente: não implementa a decisão do usuário.

**Version note**: A v2.0.0 registra a mudança incompatível de produto, princípios alterados, justificativa, impacto e migração. A data original de ratificação continua explicitamente TODO; não foi inventada.

## Existing project evidence

- .agents/skills/speckit-* são comandos Codex em Markdown; Spec Kit já opera com .specify/feature.json, convenções de specs e workflow SDD.
- .specify/integrations/codex.manifest.json e .specify/workflows/speckit/workflow.yml descrevem a integração existente.
- README.md anuncia análise Bash/Python que grava relatórios timestamped sob o repo analisado, vários formatos e caminhos.
- src/pipeline/context.sh resolve output padrão como $REPO_ROOT/$REPORT_NAME, faz cd "$REPO_ROOT", cria diretórios e registra log dentro da saída.
- src/pipeline/structured-reports.sh cria vários arquivos, inclusive links de navegação para JSON/HTML/Notion/LLM/SBOM/onboarding.
- src/pipeline/security-archive.sh e renderers dependem de JSON persistido e geração múltipla; reuso exige separar coleta da entrega.
- docs/evidence-classification.md separa fact, inference e not_observed, incluindo não observado diferente de zero.
- docs/author-system-ownership.md descreve proxies quantitativos; atividade será sinal investigativo, não score de autoria.
- docs/architecture.md especifica direção de dependência e separação collector/renderer; coletar esses fatos não exige preservar renderers.
- A skill local speckit-plan prevê agentes de pesquisa. Nesta sessão, a política de colaboração proíbe delegação salvo pedido explícito; pesquisa foi feita diretamente no workspace.
