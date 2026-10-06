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
# Complemento de pesquisa e decisões — US10/US11 (2026-10-05)

## Decisões

- **D1 — Uma autoridade e compatibilidade**: adicionar seções opcionais no documento canônico existente e avançar a versão do esquema nele; não gerar saídas ou serviços novos. Relatórios antigos sem essas seções continuam válidos.
- **D2 — Estado editorial explícito**: brief e decisões guardam origem/estado, e classificação do projeto fica separada de seu contexto. Sugestão automatizada não equivale a aprovação.
- **D3 — Comparação limitada**: papel editorial relativo só é comparado dentro de inventário informado e comparável; análise isolada oferece aderência e lacunas, sem ranking.
- **D4 — Evidência primeiro**: resumos/cases derivam de claims localizáveis. Histórias, mídia e pacotes são proporcionais ao papel e ao suporte existente; Featured é recomendação, Archive/Supporting não é exclusão.
- **D5 — Superfície condicional**: site/protótipo é avaliado apenas quando selecionado; escopo observado e limitações ficam explícitos. Dimensão não acessível vira `not_observed`; não há login, formulário ou mudança de estado.
- **D6 — Diagnóstico sem certificação**: escala 1–5 tem critério/observação; findings priorizados incluem impacto, esforço, risco e confiança. Não se afirma teste de usuário, conversão ou certificação sem evidência apropriada.
- **D7 — Pesquisa externa restrita**: usar apenas para questão aberta relevante, citando fonte direta e data; julgamento do analista permanece distinto.

## Racional e alternativas

As decisões derivam diretamente de FR-078–094, SC-017–027, dos contratos existentes de saída/readonly e da constituição v3.0.0. Uma seção nova no mesmo Markdown preserva navegação e compatibilidade com o objetivo da fonte de verdade única. Arquivo separado, export de Notion, implementação visual e perfil universal de portfólio contradizem a autoridade local, o limite de privacidade ou o escopo explicitado e foram descartados.

Nenhuma dependência de tecnologia ou questão factual externa está pendente para planejar este complemento. Regras de acessibilidade e benchmarks só serão pesquisados durante uma avaliação quando houver decisão concreta que dependa disso; pesquisa não bloqueia a execução genérica.

# Complemento de pesquisa e decisões — US12/US13 (2026-10-05)

## Complemento de pesquisa e decisões — US14 (2026-10-05)

### Decisões

- **D20 — Reconstrução deriva das fontes existentes**: não adicionar integração de CRM/issues/reviews/chat; usar fontes locais, fornecidas ou públicas sem autenticação e já autorizadas pelo escopo. Serviço inacessível é cobertura unavailable/not_observed.
- **D21 — Tipagem sem confundir hipótese com evidência**: cada claim material tem fonte/localização, baseline, dimensão suportada, tipo, caveat e rationale de confiança; `hypothesis` é interpretação candidata, com contraevidência/alternativas, preservando findings originais. Confiança usa `high` para suporte direto e adequado ao escopo sem contradição material; `medium` para suporte parcial/indireto ou limitado sem alternativa equivalente; `low` para suporte fraco/ambíguo ou alternativas igualmente plausíveis. Sem suporte suficiente, deixar unknown/unsupported sem nota. Rationale considera tipo/direção da fonte, corroboração, contradição e escopo, sem probabilidade percentual.
- **D22 — Atribuição multidimensional**: autoria em commit, mudança, decisão, colaboração, comportamento, validação e resultado são relações separadas. Nenhuma inferência de intenção, ownership total, qualidade ou resultado decorre automaticamente de uma delas.
- **D23 — Editorial sem ordem fixa**: a lista FR-083 é checklist de investigação. Documento pode usar prosa e ordem livres, deixar campos sem suporte em aberto e destacar de zero a três histórias curtas proporcionais à evidência.
- **D24 — Validação já observada e qualificada**: não executar nada do alvo. Artefato/configuração de teste e resultado fornecido são distintos; cada resultado limita-se ao snapshot, cenário e ambiente conhecidos.
- **D25 — Perguntas seletivas e qualidade qualitativa**: perguntar só para fatos recuperáveis cuja resposta mudaria a interpretação/atribuição/claim. Avaliar cenários e leitores representativos usando perguntas e critérios definidos previamente, sem porcentagem ou promessa de contratação inventadas.

### Racional e alternativas

As decisões decorrem de FR-114–125, SC-038–047 e princípios I, III e IV da constituição. Banco, integração privada, questionário extenso e template de case obrigatório foram descartados porque criariam novas dependências, reduziriam a flexibilidade editorial ou favoreceriam preenchimento especulativo. Não é necessária pesquisa online: não há fato técnico ou decisão de produto dependente de fonte externa.


## Decisões

- **D8 — Vocabulário local de tags**: usar facetas, chaves estáveis, rótulos e aliases versionados no método local. Catálogos, PURL, SKOS e SBOM ajudam a estruturar ou desambiguar dados quando disponíveis, mas não viram autoridade online nem formato obrigatório.
- **D9 — Registros conectados**: identificar conceitos técnicos como `T-###`, ocorrências como `O-###`, pessoas/identidades como `P-###` e contribuições como `K-###`; relacioná-los a sistemas, repositórios/baselines e evidências existentes. IDs são locais ao documento canônico e não criam novos entregáveis.
- **D10 — Estados não colapsados**: preservar os quatro estados de tecnologia atuais e definir critério por ocorrência. Manifest, lock, inventário de pacotes, arquivos disponíveis, uso consumidor e seleção de configuração são sinais separados; relação do package, versão, contexto e origem são dimensões adicionais.
- **D11 — Descoberta estática**: manifests, locks, código, configurações, conteúdo serializado, metadata disponível e fontes Git locais dão candidatos. Confirmação requer consumo/finalidade/localização no sistema. Não instalar parser, dependência, registry ou ferramenta no alvo; nada de build/execução.
- **D12 — Reconhecimento de padrões com prova estrutural**: registrar participantes, relação, comportamento, motivo/escopo e evidências. Nome em classe, pasta, pacote ou README não basta. Se o rótulo do padrão não for sustentável, relatar estrutura em palavras comuns ou inferência limitada.
- **D13 — Sinais de IA em dimensões separadas**: assistência no processo, integração ao produto, técnica implementada e provedor/modelo são registros diferentes. Arquivos de instrução/configuração não provam uso em uma tarefa; declaração em commit também não prova autoria ou percentual gerado.
- **D14 — Codec não é extensão**: reconhecer formato/contêiner e codec separadamente por metadata/configuração de stream existente; extensão isolada não estabelece codec. Codex permanece na faceta de ferramenta de agente.
- **D15 — Lista de contribuidores limitada por cobertura**: combinar fontes Git e créditos/relatos autorizados, comunicar escopo/completude e aceitar contribuições não codificadas. Não derivar autoria a partir de CODEOWNERS, top contributors ou contagem isolada; alias ambíguo não se funde.
- **D16 — Vínculo pessoal sustentado**: cada pessoa relacionada a tecnologia precisa de contribuição e evidência ligando-a à ocorrência/sistema. Tags do produto não são herdadas por participantes. Cargo, emprego e período observável permanecem distinções existentes.
- **D17 — Perfis de consulta explícitos**: por padrão, uso demonstrado retorna ocorrências atuais, não stale, com `observed_use`; filtros para config ativa, experiência pessoal, exploratório, histórico e IA mantêm qualificadores e fontes.
- **D18 — Migração aditiva**: novos relatórios usam schema `2.1.0`; relatórios `2.0.0` permanecem legíveis e recebem as seções no mesmo arquivo ao serem atualizados. Heading ausente no legado não equivale a `not_observed` nem a `not_applicable`.
- **D19 — Pesquisa externa informativa**: fontes online consultadas ajudam a conceber o método; explicações externas de uma tecnologia não comprovam uso no alvo. A autoridade normativa permanece local e a execução é offline.

## Racional e alternativas

Estas decisões incorporam [research-tags-and-contributors.md](research-tags-and-contributors.md) e FR-095–113/SC-028–037. A relação `tag → registro → ocorrência → sistema/baseline → evidência` permite consultar tecnologia sem apagar qualificadores. O vínculo separado pessoa → contribuição → ocorrência impede converter stack coletiva em experiência individual. Um catálogo externo, detector instalado, saída SBOM, analytics de popularidade, coleta de prompts ou classificação por estilo aumentariam dependências ou produziriam alegações fora da evidência disponível e não foram escolhidos.

Não há escolha de linguagem ou plataforma de implementação pendente: trata-se de extensão documental do framework e dos seus validadores de contrato. O detalhamento de tarefas estabelecerá a sequência por arquivos. Não foi necessária decisão adicional do usuário na clarificação; configuração versus atividade de IA e pessoa versus stack do produto já têm defaults normativos nesta spec.

## Decisão de clarificação — procedência e adequação por fonte (2026-10-06)

### Decisão D26

Para cada afirmação material, registrar procedência e adequação de cada fonte para a dimensão afirmada, separadas da confiança atribuída à claim. Metadados incluem origem/autoria quando conhecida, datas disponíveis, baseline/snapshot/versão, localização recuperável, natureza direta/secundária/relato, atualidade e independência/corroboração quando disponível. Valores que não puderem ser recuperados permanecem `unknown`. Não haverá hierarquia universal de fontes, score de confiabilidade da fonte, hash obrigatório ou cópia preservada obrigatória.

### Racional e alternativas

A decisão permite que pessoas e agentes confiram as fontes e entendam os limites de cada conclusão. Uma fonte pode ser adequada para uma dimensão (por exemplo, código para mecanismo presente ou relato atribuído para memória pessoal) e inadequada para outra; seu contexto não substitui a avaliação da claim. Corroboração considera se fontes são realmente independentes ou derivam da mesma origem.

Alternativas consideradas: (B) exigir hash/trilha de preservação, rejeitada por adicionar custo e não ser aplicável a todos os tipos de fonte; (C) manter apenas metadados/confiança atuais, rejeitada por deixar implícita a proveniência e adequação contextual. Uma classificação universal em que tipos de fonte sempre superam outros também foi rejeitada; autoridade é relativa à pergunta, baseline e dimensão. Hash de release/binário continua podendo ser registrado quando disponível e relevante, sem obrigação geral.

### Limites e arquivos a alinhar

Não é necessária pesquisa online nem nova decisão tecnológica. Procedência não é certificado de autenticidade: origem, autoria, data e independência só são afirmadas quando sustentadas, e o framework registra desconhecidos. Privacidade vigente continua prevalecendo; dados pessoais ou metadados privados desnecessários não são reproduzidos no documento canônico. O desenho aditivo permanece no Markdown 2.1.0 e será alinhado em `data-model.md`, contratos, metodologia, runbook de reconstrução, vocabulário, consolidação, skill, quickstart e fixtures/validador sintéticos.
