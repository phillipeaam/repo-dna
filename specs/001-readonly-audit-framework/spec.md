# Feature Specification: Framework de auditoria readonly e Project Source of Truth

**Feature Branch**: `feature/001-readonly-audit-framework`

**Created**: 2026-10-03

**Status**: Implementado — fluxo estático procedural; proteção do host informada como limitação, não como gate de entrada

**Input**: User description: "Estudar o Notion e suas subpáginas somente para leitura, incorporar o método de avaliação ao RepoDNA e transformá-lo em um framework de skills e processos conduzidos por agente de IA. Receber repositórios em uma pasta ignorada pelo Git, analisá-los sem alterar nada e produzir uma página única de source of truth rica, completa e padronizada."

## Clarifications

### Session 2026-10-04
- Q: Qual deve ser o destino da página canônica gerada para cada projeto? Se escolher Notion, futuras análises podem criar ou atualizar páginas ali, mantendo as fontes originais somente para leitura? → A: Markdown local exclusivo em `analysis-output/`; remover HTML e Notion como destinos ou formatos de saída suportados.
- Q (decisão original, substituída pela revisão abaixo): Como comprovar que o repositório-alvo não pode ser alterado pela sessão de auditoria? → A: O host deve negar escrita no alvo e em seu Git associado, enquanto permite escrita separada em `analysis-output/`. Se não for possível comprovar essa separação antes da inspeção substantiva, o fluxo bloqueia.
- Q: Validação dinâmica pode fazer parte do fluxo quando solicitada e executada em cópia isolada? → A: Não nesta feature. O framework entregue é exclusivamente estático/readonly; qualquer validação dinâmica é um processo externo, separado e fora dos fluxos, responsabilidades e entregáveis desta feature.
- Q (revisão 2026-10-04): Auditoria deve bloquear quando o host não comprova prevenção efetiva de escrita? → A: Não por enquanto. A skill deve avisar quando a sessão puder gravar no alvo, seguir somente o procedimento estático sem escrita intencional e classificar a preservação como não verificada/observada; não pode afirmar garantia do host. A prevenção por sandbox/ACL continua recomendada para evolução futura.
- Q: Quem consulta o registro e onde Notion/Docs entram? → A: O entregável do framework permanece Markdown local; pessoas podem copiá-lo para documentos ou Notion depois, e agentes de IA podem consultá-lo. Isso não autoriza integração nem escrita externa pelo framework.
## User Scenarios & Testing *(mandatory)*

### User Story 1 - Auditar um alvo sem modificá-lo (Priority: P1)

Como responsável por um projeto, coloco uma cópia local em `target-repos/<alvo>/`, seleciono o alvo e inicio a auditoria. Recebo resultados fora dele e uma declaração verificável sobre sua preservação, inclusive quando já existiam mudanças locais.

**Why this priority**: A confiança no processo depende de preservar código, conteúdo, configurações e histórico do projeto examinado.

**Independent Test**: Auditar uma cópia com arquivos rastreados, ignorados, não rastreados e modificados; comparar o estado inicial/final e verificar a localização de todos os resultados.

**Acceptance Scenarios**:

1. **Given** um alvo válido, **When** inicio a análise, **Then** identidade, escopo, baseline e área externa de resultados são apresentados antes da coleta.
2. **Given** alterações locais preexistentes, **When** a auditoria termina, **Then** arquivos e estado Git permanecem iguais à baseline, e achados distinguem conteúdo local de conteúdo versionado.
3. **Given** uma tentativa de gravar relatórios, logs ou caches no alvo, **When** o processo avalia o destino, **Then** a escrita é recusada e a execução não recebe status de preservação verificada.
4. **Given** nenhum alvo ou vários candidatos, **When** inicio a auditoria sem seleção inequívoca, **Then** recebo orientação para selecionar um alvo; o próprio framework não é usado por engano.
5. **Given** uma sessão sem política host verificável que negue escrita no alvo, **When** inicio a auditoria, **Then** o fluxo apresenta um aviso explícito sobre escrita incidental e pode prosseguir com análise estática, registrando preservação como não verificada até a comparação final.

---

### User Story 2 - Seguir um método completo com um agente (Priority: P1)

Como usuário, aciono um processo documentado. O agente identifica o que se aplica, executa etapas com entradas e saídas definidas, registra lacunas e entrega uma análise consistente sem depender de prompts improvisados.

**Why this priority**: O produto desejado é o método reutilizável, incluindo julgamento baseado em evidência.

**Independent Test**: Aplicar o processo a um projeto pequeno e a um projeto com produção e histórico extensos; verificar etapas, contratos, motivos de ausência e gates.

**Acceptance Scenarios**:

1. **Given** um projeto pequeno, **When** o agente combina etapas, **Then** todos os resultados obrigatórios continuam cobertos e a combinação fica registrada.
2. **Given** um projeto complexo, **When** o agente executa A1 e B1–B4, **Then** cada etapa aprofunda os temas próprios e reutiliza evidências já obtidas.
3. **Given** uma área sem evidência ou sem aplicabilidade, **When** ela é avaliada, **Then** o registro distingue não aplicável, não observado, indisponível e não verificado.
4. **Given** falha ou interrupção, **When** retomo a sessão, **Then** o agente usa os checkpoints e confirma se a baseline mudou antes de continuar.

---

### User Story 3 - Entender o projeto por uma fonte de verdade única (Priority: P1)

Como pessoa ou agente de IA que consulta um projeto, uso uma página canônica por projeto/produto para compreender o projeto, recuperar contribuições, arquitetura, decisões, histórico e evidências com seus limites.

**Why this priority**: Dados isolados e relatórios dispersos não atendem ao objetivo de documentação rica e utilizável.

**Independent Test**: Entregar o único Markdown de `analysis-output/` a um agente de IA e fazer perguntas predefinidas sobre identidade, contribuições, arquitetura, release e limites. Cada resposta factual deve apontar para evidência recuperável; itens sem suporte devem ser declarados desconhecidos, sem inventar respostas. Confirmar que nenhum artefato alternativo foi entregue.

**Acceptance Scenarios**:

1. **Given** uma auditoria concluída, **When** abro o Markdown canônico, **Then** encontro Start Here, At a Glance, mapa de estudo, registro principal, estado atual, perguntas pendentes e apêndices navegáveis.
2. **Given** uma contribuição ou conclusão relevante, **When** sigo sua referência, **Then** encontro fonte, escopo, versão, força de evidência e limitações suficientes para reavaliá-la.
3. **Given** nova evidência que contradiz um checkpoint, **When** atualizo o registro, **Then** há uma resposta atual por tema e a anterior fica explicitamente superada.
4. **Given** lacunas históricas não bloqueantes, **When** encerro a análise, **Then** a página pode ficar pronta para revisão com essas lacunas documentadas.

---

### User Story 4 - Separar implementação, autoria, release e resultados (Priority: P1)

Como usuário, quero saber quais sistemas existem, quem contribuiu, o que pertence a cada versão e quais resultados são demonstrados, sem transformar atividade Git ou notas de planejamento em impacto pessoal.

**Why this priority**: A documentação alimentará decisões técnicas, onboarding, currículo, portfólio e entrevistas.

**Independent Test**: Usar um caso com trabalho compartilhado, uma feature planejada sem implementação, um tag sem binário correlacionado e uma alegação de desempenho sem medição.

**Acceptance Scenarios**:

1. **Given** código atual sem autoria recuperável, **When** o agente documenta o sistema, **Then** existência e ownership recebem avaliações independentes.
2. **Given** um tag e mídia sem correlação exata com um artefato, **When** o release é descrito, **Then** a associação fica qualificada e não vira prova de publicação de um commit exato.
3. **Given** uma melhoria técnica sem benchmark, **When** uma claim é proposta, **Then** a mudança pode ser descrita, mas ganhos quantitativos permanecem não demonstrados.
4. **Given** muito churn e poucos commits atribuídos, **When** contribuições são avaliadas, **Then** volume de atividade não determina ranking de pessoas, liderança ou ownership.

---

### User Story 5 - Consolidar contexto e limites de publicação (Priority: P2)

Como usuário, forneço documentos e referências adicionais. O processo reconcilia conflitos e diferencia documentação interna, texto público, links e mídia que dependem de procedência ou autorização.

**Why this priority**: Evidência técnica, contexto histórico e publicação são decisões diferentes.

**Independent Test**: Fornecer duas notas conflitantes e mídia com origem conhecida mas permissão não documentada.

**Acceptance Scenarios**:

1. **Given** notas antigas divergentes, **When** o agente reconcilia fontes, **Then** registra a afirmação anterior, evidência disponível, decisão e incerteza restante.
2. **Given** texto factual seguro e mídia sem procedência fechada, **When** avalia publicação, **Then** o texto e a mídia recebem estados independentes.
3. **Given** fontes relacionadas acessíveis, **When** a reconciliação termina, **Then** cada uma tem propósito e classificação registrados no Markdown canônico, sem gerar um produto paralelo ou alterar as fontes.
4. **Given** nenhum acesso a fontes externas, **When** audito localmente, **Then** a entrega local continua possível e a cobertura externa incompleta aparece explicitamente.

---

### User Story 6 - Documentar produtos com vários repositórios e tecnologias (Priority: P2)

Como usuário, seleciono repositórios que compõem o mesmo produto e informo suas relações. Recebo uma fonte de verdade que preserva limites de produto, serviço, pacote, versão e autoria.

**Why this priority**: O método precisa cobrir jogos, clientes, serviços e pacotes compartilhados sem vincular regras a projetos particulares.

**Independent Test**: Auditar um produto com cliente, serviço e pacote, além de um sucessor relacionado mas distinto.

**Acceptance Scenarios**:

1. **Given** vários repositórios do mesmo produto, **When** consolido a análise, **Then** cada evidência permanece vinculada ao repositório e snapshot de origem.
2. **Given** dois produtos da mesma empresa, **When** aparecem nas fontes, **Then** permanecem registros canônicos distintos, com relações e reutilizações explícitas.
3. **Given** uma stack sem especialização disponível, **When** inicio o processo, **Then** o núcleo genérico entrega análise com cobertura declarada.
4. **Given** um pacote instalado, **When** classifico tecnologias, **Then** presença, uso observado, integração própria e origem de terceiros permanecem distintos.

---

### User Story 7 - Reutilizar e atualizar a análise com controle (Priority: P2)

Como mantenedor, quero incorporar as capacidades úteis do RepoDNA ao novo processo, preservar a semântica das evidências e reavaliar apenas conclusões afetadas por mudanças.

**Why this priority**: O novo framework deve absorver o conhecimento existente e evoluir sem duplicar autoridades.

**Independent Test**: Importar evidência legada compatível e atualizar um registro após alteração da baseline.

**Acceptance Scenarios**:

1. **Given** resultado legado com versão conhecida, **When** incorporo seus dados, **Then** origem e significado são preservados e heurísticas não se tornam verificações.
2. **Given** um contrato incompatível, **When** tento consumir o resultado, **Then** a incompatibilidade é declarada e não há conversão silenciosa.
3. **Given** mudança de baseline, **When** retomo ou atualizo, **Then** conclusões afetadas são reavaliadas e o histórico fica separado do estado atual.

### User Story 8 - Compartilhar o framework sem expor contexto privado (Priority: P1)

Como mantenedor, quero versionar o método generalizado sem divulgar nomes de projetos de fontes privadas, títulos/IDs/links de páginas pessoais, detalhes de trabalho ou caminhos pessoais. A procedência original pode ser preservada localmente sem entrar no conteúdo compartilhável.

**Why this priority**: A pesquisa privada serve para construir um método reutilizável; sua incorporação não autoriza divulgar os casos estudados.

**Independent Test**: Revisar conteúdo de trabalho e preparado para commit, usando exemplos sintéticos de metadados privados e uma área local excluída do versionamento e da distribuição.

**Acceptance Scenarios**:

1. **Given** notas de pesquisa privada, **When** preparo o framework para compartilhar, **Then** preservo a procedência local e publico somente regras generalizadas, sem identificadores dos casos originais.
2. **Given** um arquivo já preparado para commit com informação privada, **When** limpo sua cópia de trabalho, **Then** a revisão continua bloqueando até que a versão preparada para commit também esteja limpa.
3. **Given** documentação preexistente com caminhos pessoais, **When** reviso o material compartilhável, **Then** substituo esses exemplos por identidades fictícias sem perder a orientação necessária.
4. **Given** conteúdo privado em commits anteriores, **When** a revisão o identifica, **Then** informa a exposição histórica; não reescreve histórico nem afirma que sanitizar arquivos atuais remove a exposição passada.

### User Story 9 - Usar o método com todas as fontes originais indisponíveis (Priority: P1)

Como usuário, quero que este projeto seja a autoridade do método de análise. A skill, as regras de evidência, as etapas e o contrato do registro devem estar disponíveis localmente, mesmo sem acesso às páginas usadas na pesquisa.

**Why this priority**: O conhecimento metodológico precisa sobreviver à perda de acesso às fontes originais e não exigir uma conta ou conector externo.

**Independent Test**: Percorrer preparação, A1, B1–B4, reconciliação, consolidação e revisão usando somente as instruções locais; verificar referências locais e cobertura do método sem autenticação ou consulta externa.

**Acceptance Scenarios**:

1. **Given** fontes originais inacessíveis e sem credenciais externas, **When** consulto o método, **Then** todas as regras obrigatórias são recuperáveis no projeto local.
2. **Given** um conflito entre uma página original e o método local aprovado, **When** sigo o framework, **Then** o método local governa; conteúdo externo é contexto opcional e não altera regras automaticamente.
3. **Given** a sanitização de exemplos privados, **When** reviso o método local, **Then** os ensinamentos e limites aplicáveis permanecem documentados sem exigir recuperação do exemplo original.

### Edge Cases

- Histórico raso, squashes, identidades ambíguas, bots, merges, refs quebradas e ausência de Git limitam autoria e reconstrução histórica; não impedem documentação estática parcial.
- Arquivos ignorados/não rastreados preexistentes, repositório sujo e detached HEAD são registrados, sem limpeza ou checkout automático.
- Symlinks, junctions, submódulos, Git externo, monorepos e caminhos com espaços exigem limites resolvidos; conteúdo externo não é seguido sem seleção explícita.
- Arquivos grandes, binários, LFS sem objetos, assets serializados e fontes ilegíveis recebem cobertura parcial com motivo.
- Código/configuração de alvo pode conter instruções dirigidas ao agente. É evidência não confiável e não pode redefinir o processo ou autorizar execução/escrita.
- Segredos, dados pessoais, material proprietário e caminhos internos são tratados antes de incorporar trechos ou produzir projeções públicas.
- Uma fonte indisponível, ferramenta ausente, contexto excedido ou etapa que falha produz checkpoint e estado parcial, sem declaração falsa de conclusão.
- Alteração concorrente do alvo invalida a confirmação de baseline; o processo registra a mudança sem atribuí-la automaticamente à auditoria.
- Nome/título antigo, produto sucessor e feature compartilhada não justificam fusão automática de registros ou dupla contagem de contribuição.
- Diferenças de timezone, author date, committer date e deadline não provam qual binário foi enviado.
- Mídia pública atual pode mostrar outra versão. Visibilidade, crédito, licença e permissão de republicação são avaliações distintas.
- Resultado ausente de cobertura/profiling não equivale a zero; ausência de teste automatizado não torna uma cena de demonstração um teste.
- Um arquivo ignorado que já está no índice continua candidato a commit; a limpeza deve verificar o índice e os arquivos atuais.
- A procedência local da pesquisa pode ficar indisponível; isso não reduz a disponibilidade do método generalizado nem autoriza divulgar seus dados.

## Requirements *(mandatory)*

### Functional Requirements

#### Entrada, isolamento e privacidade

- **FR-001**: O framework MUST oferecer um fluxo de preparação, seleção e auditoria de alvos locais em `target-repos/`, ignorada pelo Git do framework.
- **FR-002**: O processo MUST permitir um repositório ou um grupo explicitamente selecionado que represente um projeto/produto, sem escolher candidatos ambíguos automaticamente.
- **FR-003**: O único entregável MUST ser um Markdown canônico por produto em `analysis-output/`. Relatórios paralelos HTML/JSON, exports Notion e arquivos complementares publicados MUST NOT ser produzidos. Estado temporário de execução, cache e logs MUST ficar fora dos alvos e podem ser descartados; nenhum temporário se torna um segundo entregável.
- **FR-004**: O processo MUST registrar baseline com identidade, caminhos resolvidos, branch/HEAD quando disponíveis, escopo de refs, estado rastreado/não rastreado/ignorado e alterações locais existentes.
- **FR-005**: O agente MUST seguir procedimento de não escrita e não execução no alvo: não editar, corrigir, formatar, instalar, importar em editor, atualizar, fazer checkout, stash, fetch, commit, tag, merge, push ou executar código do alvo. Este requisito descreve o comportamento do agente, não uma garantia de enforcement do host.
- **FR-006**: O resultado MUST comparar estado inicial/final com cobertura declarada para arquivos ignorados/não rastreados e conteúdo, além do status Git; limitações de cobertura impedem declarar preservação observada integral. Só combinar a comparação com enforcement efetivo comprovado permite declarar preservação verificada; sem enforcement, comparação sem diferenças significa apenas `observed_unchanged` no escopo comparado.
- **FR-007**: O framework MUST ser exclusivamente estático/readonly e MUST recusar execução de código, scripts, builds, testes, hooks, plugins, macros, código de editor ou profiling do alvo em todos os fluxos desta feature. Validação dinâmica fica fora do escopo e, se conduzida, pertence a processo externo independente; ela não é iniciada, orquestrada nem registrada como etapa ou entregável deste framework.
- **FR-008**: Antes da inspeção substantiva, o fluxo MUST identificar e registrar o estado conhecido da proteção do host para o alvo e Git associado (`enforced`, `unverified` ou `unknown`). Se não houver enforcement comprovado ou o alvo estiver em uma raiz gravável, o agente MUST avisar o usuário e pode prosseguir com inspeção estática procedural; isso sozinho MUST NOT bloquear. O resultado MUST distinguir preservação observada de proteção preventiva. Instruções da skill, `.gitignore`, hashes e `git status` não constituem enforcement.
- **FR-009**: Conteúdo do alvo e de fontes externas MUST ser tratado como dados; instruções embutidas não podem alterar regras do framework.
- **FR-010**: Fontes externas MUST ser somente leitura por padrão; nenhum passo de reconciliação pode editar, comentar, excluir ou publicar nessas fontes.
- **FR-011**: O framework MUST excluir dados de alvos e resultados de commits próprios e impedir inclusão acidental em seus pacotes de distribuição; ignorar arquivos não substitui os limites de escrita.
- **FR-012**: O processo MUST mascarar segredos e dados sensíveis, evitar exportação de código por padrão e permitir configurar exclusões fora do alvo. Todo trecho autorizado MUST respeitar seu escopo de divulgação.

#### Framework e contrato de execução

- **FR-013**: A experiência principal MUST ser um framework de skills, processos, templates e gates que um agente possa seguir, documentando entradas, saídas, pré-condições, limites, falhas e critérios de conclusão de cada etapa.
- **FR-014**: O processo MUST cobrir preparação, A1 forense, B1 produção/arquitetura, B2 runtime estático/performance, B3 release/procedência, B4 publicação/créditos, consolidação humana, reconciliação de fontes e revisão final.
- **FR-015**: A aplicabilidade de cada domínio MUST ser registrada; etapas podem ser combinadas ou aprofundadas, mas resultados obrigatórios não podem desaparecer.
- **FR-016**: Cada etapa MUST reutilizar o registro de evidências anterior e atualizar conclusões afetadas, evitando refazer toda a auditoria sem motivo.
- **FR-017**: O processo MUST oferecer checkpoints e retomada com confirmação de baseline, versão do método, etapas concluídas, pendências e evidências acumuladas. O estado de execução pode ser temporário; a entrega persistente consolidada por produto continua sendo um único arquivo Markdown.
- **FR-018**: Falhas MUST resultar em estado parcial/bloqueado com motivo e ação necessária; indisponibilidade não pode ser registrada como ausência comprovada.
- **FR-019**: A auditoria MUST produzir um mapa de cobertura: completo, parcial, não observado, não aplicável, indisponível ou não verificado por domínio, com escopo e motivo.
- **FR-020**: O núcleo MUST ser genérico e especializações MUST acrescentar profundidade sem substituir evidência base ou forçar listas de sistemas inexistentes.
- **FR-021**: O processo MUST permanecer utilizável localmente sem Notion ou outros serviços externos. Referências externas são complementares e sua disponibilidade é declarada.

#### Evidência e auditoria forense A1

- **FR-022**: O processo MUST priorizar evidência de repositório/histórico, documentação e artefatos de release, contexto histórico e, por último, copy prévia como alvo de verificação. Prioridade MUST ser avaliada por tipo de claim; código não prova publicação ou motivação pessoal.
- **FR-023**: Cada conclusão relevante MUST ter identificador estável, tipo de evidência, referências recuperáveis, baseline/versão, escopo temporal, confiança justificada, limitações e estado de verificação.
- **FR-024**: Identificação MUST abranger produto, nomes antigos, contexto, stack, plataformas, equipe/papel quando evidenciados, janela de desenvolvimento e estado público.
- **FR-025**: Autoria MUST ser investigada por identidade, histórico e diffs relevantes por sistema; aliases ambíguos não podem ser fundidos automaticamente.
- **FR-026**: O processo MUST distinguir criação, extensão, manutenção, integração, trabalho compartilhado, origem de terceiros e ownership desconhecido.
- **FR-027**: Contagens, churn, blame e proxies de atividade MUST ser contexto investigativo; não podem produzir ranking de colaboradores, título de liderança, impacto ou autoria exclusiva.
- **FR-028**: A matriz de sistemas MUST registrar implementação, evidência, baseline, autoria e limites, distinguindo implementado, parcial, protótipo, somente planejado e não encontrado no escopo.
- **FR-029**: Arquitetura MUST refletir o alvo: composição, limites, dependências, fluxos de dados/eventos/estado, entradas, UI, persistência e serviços quando presentes.
- **FR-030**: Planejado, implementado no código, configurado, exercitado, incluído em linhagem versionada e publicado MUST ser avaliações separadas.
- **FR-031**: A timeline MUST agrupar fases significativas e separar cronologia do produto, contribuição individual, emprego, release e manutenção posterior.
- **FR-032**: Histórias de engenharia MUST usar problema, restrição, abordagem, trade-off, resultado e evidência. Motivação, resultado ou reflexão não comprovados MUST permanecer lacunas ou relato pessoal identificado.

#### Aprofundamento B1/B2

- **FR-033**: B1 MUST avaliar configuração ativa, arquitetura/compilação, pipeline de build/release, conteúdo/assets, dependências, tooling, testes/QA e observabilidade aplicáveis.
- **FR-034**: Especializações MUST verificar uso real de tecnologias e configurações, distinguindo instalada, possivelmente usada, usada e configuração ativa.
- **FR-035**: Em jogos, B1 MUST avaliar quando aplicável rendering, qualidade/player/time, cenas/prefabs, referências serializadas, importação, UI, áudio, animação/VFX, física/navegação e organização runtime/editor.
- **FR-036**: Em aplicações/serviços, B1 MUST avaliar quando aplicável cliente/servidor, serviços, configuração, contratos, serialização, dados, integrações, deployment e flags.
- **FR-037**: B2 MUST mapear execução, frequência/trigger, trabalho recorrente, lifetime, eventos, cancelamento, concorrência, carregamento, memória e confiabilidade por caminhos relevantes.
- **FR-038**: B2 MUST separar fato estático, risco estático, medição e não medido; configuração, código e instrumentos presentes não provam gargalo ou ganho.
- **FR-039**: Medições fornecidas MUST incluir procedência, snapshot, cenário, ambiente, ferramenta, unidade, método e limitações; comparação antes/depois exige condições comparáveis.
- **FR-040**: B2 MUST distinguir tamanho de arquivo/build/download de memória em runtime, Editor de plataforma alvo, demo de teste e configuração de resultado observado.
- **FR-041**: Sem medição, B2 MUST entregar perguntas e plano de verificação futura, sem executar aplicação, build, testes ou profiling no alvo.

#### Release, terceiros e publicação B3/B4

- **FR-042**: B3 MUST reconstruir a cadeia evento/deadline → fonte → artefato → destino público, qualificando separadamente cada relação.
- **FR-043**: A baseline de release MUST ser exata, fortemente suportada, intervalo limitado ou não resolvida; proximidade de datas/tag sozinha não pode provar o commit publicado.
- **FR-044**: B3 MUST comparar release original, alterações posteriores, HEAD atual e versão pública atual sem misturar suas capacidades.
- **FR-045**: Dependências compartilhadas MUST preservar a cadeia alteração do pacote → versão → consumo pelo produto → release; um patch num pacote não prova adoção pública.
- **FR-046**: O processo MUST distinguir artefato histórico recuperado de rebuild posterior e registrar tentativas razoáveis de recuperação encerradas sem inventar evidência.
- **FR-047**: B4 MUST registrar procedência, autoria de conteúdo, integração técnica, créditos, licença e permissão por asset/mídia relevante; commitar binário importado não prova sua criação.
- **FR-048**: A análise de créditos MUST incluir arquivos e UI/conteúdo de créditos disponíveis, distinguindo crédito atribuído de verificação independente ou licença.
- **FR-049**: Cada mídia candidata MUST identificar fonte, versão/era, data conhecida, claim demonstrada, limites de autoria, terceiros visíveis/audíveis, permissão, atribuição e legenda proposta.
- **FR-050**: Link, embed, cópia, crop, download/rehosting e alteração de áudio MUST ter avaliações separadas; publicação existente não implica autorização para todas essas ações.
- **FR-051**: B4 MUST separar prontidão de texto, links, mídia, áudio e claims quantitativas, com condição, evidência, ação restante e bloqueio específico.
- **FR-052**: Claims MUST ser seguras, qualificadas, internas, não sustentadas ou rejeitadas, com wording proporcional à evidência. Confirmação pessoal fica identificada e não substitui prova independente.
- **FR-053**: O processo MUST conservar uma lista explícita de claims a evitar sem nova evidência, incluindo liderança, autoria total, performance/impacto e release quando não demonstrados.
- **FR-054**: Gaps MUST ser resolvidos, parcialmente resolvidos, abertos bloqueantes/não bloqueantes ou encerrados com justificativa. Arquivamento incompleto não bloqueia texto factual que respeite seus limites.

#### Consolidação, atualização e entrega

- **FR-055**: A entrega MUST consistir em exatamente um arquivo Markdown canônico local por projeto/produto em `analysis-output/`, com status, data/baseline, Start Here, At a Glance, mapa de estudo, registro principal, projeção pública atual, questões, apêndices e índice de evidências. Headings e identificadores estáveis MUST permitir a pessoas e agentes recuperar assuntos e apontar evidências. Todos os resultados e referências necessários à leitura MUST ser consolidados nesse arquivo; nenhum relatório, export ou anexo em outro formato é entregue.
- **FR-056**: O registro principal MUST organizar verdade por assunto: produto, papel/equipe, contribuições, sistemas/arquitetura, decisões, timeline/release e evidência pública, sem impor leitura por ordem de auditoria.
- **FR-057**: Apêndices longos MUST usar hierarquia, links internos e sumário Markdown; respostas atuais e bloqueios relevantes MUST permanecer visíveis no arquivo canônico.
- **FR-058**: Papel, período, stack, contribuições, publicação, claims e perguntas MUST ter uma única resposta atual; versões anteriores ficam identificadas como históricas/superadas.
- **FR-059**: Reconciliação MUST procurar nomes/aliases nas fontes autorizadas disponíveis, ler os resultados relevantes e classificá-los como incorporado, contexto retido, projeto distinto, processo histórico/superado ou irrelevante.
- **FR-060**: Reconciliação MUST documentar conflitos, informação única incorporada e fontes retidas com propósito; pode sugerir limpeza, mas não modificar/excluir fontes.
- **FR-061**: Produtos distintos MUST manter registros separados; pacotes/features compartilhados MUST indicar linhagem e impedir dupla contagem de contribuição.
- **FR-062**: Seleção de histórias e talking points MUST priorizar evidência e relevância, sem número obrigatório de histórias ou respostas pessoais inventadas.
- **FR-063**: O processo MUST oferecer índice de evidências e histórico de verificação ligados ao registro, permitindo consultar fontes sem copiar grandes arquivos de código.
- **FR-064**: O Markdown canônico MUST preservar procedência e aderir a uma estrutura versionada. Dados intermediários usados durante a execução são internos e não são entregues como relatórios alternativos.
- **FR-065**: Dados legados aproveitados MUST conservar versões e semântica; incompatibilidades precisam de migração explícita ou recusa documentada.
- **FR-066**: Uma atualização MUST indicar baseline antiga/nova, evidências afetadas, decisões alteradas e checkpoints superados.
- **FR-067**: O Markdown canônico MUST informar cobertura, preservação do alvo, achados centrais, perguntas, bloqueios de publicação e ser o único entregável persistente da auditoria.
- **FR-068**: A revisão final MUST verificar cobertura do contrato, rastreabilidade, ausência de autoridade duplicada, limites de claims e preservação; conclusão da auditoria não equivale a aprovação humana ou publicação.
- **FR-069**: A orientação de uso MUST refletir o framework como experiência principal, declarar transição das rotinas legadas e instruir geração somente do Markdown canônico local em `analysis-output/`, sem orientar saídas dentro do alvo, HTML ou publicação em Notion.
- **FR-070**: O novo método MUST incorporar capacidades úteis existentes de inventário, Git, arquitetura, dependências, privacidade, documentação e comparação; manter uma capacidade exige evidência de utilidade e compatibilidade com os contratos acima.

#### Privacidade do framework e autoridade do método local

- **FR-071**: Conteúdo compartilhável do framework MUST excluir metadados de fontes privadas: nomes e aliases dos projetos estudados, títulos/IDs/URLs de páginas pessoais, datas privadas, detalhes particulares de trabalho e caminhos pessoais. Exemplos MUST ser genéricos ou fictícios. Identidade pública do próprio framework e de suas dependências não é metadado privado de pesquisa.
- **FR-072**: A procedência original da pesquisa MUST ser preservável em área local privada, ignorada e excluída dos conteúdos versionados e distribuídos. Essa área é entrada de pesquisa do framework, não um segundo entregável de auditoria; sua ausência MUST NOT bloquear uso do método.
- **FR-073**: A revisão de privacidade MUST considerar arquivos atuais e conteúdo preparado para commit, inclusive arquivos já rastreados. Distribuição MUST revisar também o snapshot exato a distribuir. Informação privada descoberta nessas superfícies MUST impedir aprovação da revisão até ser removida de cada versão; dados detectados MUST NOT ser reproduzidos nos diagnósticos.
- **FR-074**: A limpeza MUST preservar os ensinamentos generalizados, regras, limites, campos e critérios de evidência extraídos, mantendo rastreabilidade local por tema sem identificadores privados. A sanitização MUST NOT alegar eliminar exposição em commits passados; reescrita de histórico exige ação explicitamente autorizada à parte.
- **FR-075**: A autoridade normativa do método MUST ser o conteúdo local aprovado e versionado neste projeto: skill, runbooks e contratos. As fontes originais de pesquisa MUST NOT ser chamadas como dependência obrigatória nem tratadas como autoridade externa para atualizar o método automaticamente.
- **FR-076**: Todas as regras obrigatórias de preparação, A1, B1–B4, evidência, reconciliação, consolidação e revisão MUST estar disponíveis localmente. Consultar contexto externo de um alvo é opcional e distinto de recuperar instruções necessárias para executar o método.
- **FR-077**: A validação MUST demonstrar ausência de dependência das fontes originais e ausência de metadados privados conhecidos no conteúdo compartilhável, incluindo o índice. Verificações automáticas MUST declarar seu alcance e ser complementadas por revisão humana de informações que padrões não reconhecem.

### Key Entities *(include if feature involves data)*

- **Projeto/produto**: identidade canônica, aliases, contexto, relações com produtos distintos e sua fonte de verdade.
- **Alvo de auditoria**: repositório/cópia local selecionada, limites reais, papel no produto e configuração de escopo.
- **Baseline**: snapshot, refs, estado local, cobertura de preservação e intervalo temporal.
- **Sessão/etapa**: versão do método, entradas/saídas, cobertura, checkpoint, falhas e critérios de conclusão.
- **Fonte/evidência**: identificador, tipo, repositório/path/commit/URL quando cabíveis, data, procedência, escopo e limite de acesso/divulgação.
- **Identidade/contribuição**: aliases verificados ou candidatos, sistema, tipo de trabalho, autoria, colaboração, confiança e evidência.
- **Sistema/feature**: comportamento, arquitetura, dependências, implementação e inclusão em versões.
- **Release/artefato**: evento, deadline/timezone, snapshot ou intervalo, binário e relações de procedência.
- **Claim**: afirmação, tipo, evidências, confiança justificada, wording, restrições e estado de revisão.
- **Asset/mídia**: conteúdo, integração, criador, origem, licença/crédito, versão e ações permitidas.
- **Questão/conflito**: tema, versões concorrentes, decisão, ação/evidência restante, responsável conhecido e bloqueio.
- **Registro canônico**: arquivo Markdown local único por produto, com verdade atual, índice de evidências, apêndices e histórico de verificação.
- **Procedência privada da pesquisa**: registro local opcional de fontes originais e metadados, separado do método compartilhável.
- **Método local**: conjunto normativo aprovado de instruções, regras e contratos, com correspondência por tema e sem dependência das fontes originais.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em todas as auditorias de aceitação, nenhum conteúdo/estado de projeto do alvo é alterado; casos com verificação incompleta são explicitamente parciais.
- **SC-002**: 100% dos resultados e temporários permanecem fora dos alvos e de seus diretórios Git.
- **SC-003**: Cada domínio obrigatório tem resultado ou estado de cobertura com motivo; nenhum domínio desaparece silenciosamente.
- **SC-004**: 100% das conclusões relevantes no registro principal têm referência recuperável, escopo, estado de evidência e limitação quando aplicável.
- **SC-005**: Nos casos de aceitação com autoria ambígua, planejamento sem código, tag sem binário e desempenho não medido, nenhuma claim é promovida indevidamente.
- **SC-006**: Dado um conjunto predefinido de perguntas sobre identidade do projeto, contribuições, arquitetura, release atual/histórico e limites, um agente de IA responde com referências recuperáveis para cada afirmação factual e declara como desconhecidas as respostas sem suporte; nenhuma resposta factual fica sem evidência citada.
- **SC-007**: A entrega contém exatamente um arquivo Markdown persistente por produto em `analysis-output/`, sem relatório ou anexo alternativo, e uma resposta atual por tema de autoridade, inclusive no cenário com múltiplos repositórios.
- **SC-008**: O fluxo produz exatamente um Markdown local por projeto pequeno, jogo e aplicação/serviço, com estrutura comparável e sem exigir conexão externa ou produzir artefatos alternativos.
- **SC-009**: Uma sessão interrompida retoma sem perder evidências e detecta mudança de baseline antes de reutilizar conclusões.
- **SC-010**: A matriz de prontidão distingue texto, links e mídia em todos os casos com publicação aplicável, preservando bloqueios específicos.
- **SC-011**: Um usuário consegue preparar um alvo já disponível e identificar como iniciar o fluxo em até cinco minutos seguindo a orientação fornecida.
- **SC-012**: Toda capacidade legada incorporada possui correspondência documentada com o novo método e nenhuma heurística é apresentada como prova mais forte que a original.
- **SC-013**: A matriz identifica sistema operacional, runtime e estado da prova de prevenção de escrita. Perfis sem prova válida permanecem `unverified`/`unsupported`, geram aviso e podem executar análise estática; nenhum resultado desses perfis afirma que o host impediu escrita. Perfis com prova registrada podem declarar enforcement preventivo para o escopo efetivamente testado.

- **SC-014**: Na revisão dos arquivos atuais e preparados para commit, zero metadados privados conhecidos das fontes de pesquisa permanecem no conteúdo compartilhável; os casos sintéticos de vazamento são recusados sem reproduzir seus valores.
- **SC-015**: 100% dos domínios obrigatórios do método têm instruções e regras disponíveis por referências locais válidas, sem exigir consulta ou autenticação nas fontes originais.
- **SC-016**: A limpeza preserva 100% dos temas metodológicos incorporados, com correspondência local verificável e nenhuma área privada de pesquisa incluída no conteúdo versionado ou distribuído.

## Assumptions

- A implementação inicial do método está concluída; este complemento protege a procedência privada e explicita a autoridade local. Perfis readonly sem prova podem prosseguir com aviso e preservação limitada a observação; enforcement host é melhoria futura.
- `target-repos/` é a área sugerida de entradas privadas; permite um alvo por subpasta e vários alvos por produto. `analysis-output/` separa resultados privados. A reserva no Git não é uma proteção de filesystem.
- Alvos dentro de uma raiz gravável pelo agente, inclusive dentro do workspace, podem ser analisados após aviso; o agente não deve intencionalmente escrever, e o relatório deve explicitar que a sessão não impediu escrita incidental.
- Pessoas podem copiar o Markdown para Notion/Docs e agentes podem consultá-lo depois; o framework não cria, atualiza ou exporta esses destinos.
- A entrega única é um arquivo Markdown local em `analysis-output/`, com evidências auxiliares e links relativos quando apropriado. HTML, JSON/CSV como relatórios entregues, arquivos de evidência separados, escrita/exportação para Notion e publicação externa estão fora do escopo. Todos os dados necessários ao leitor são consolidados no Markdown.
- O usuário fornece quais identidades/pessoas investigar quando deseja atribuição pessoal. Sem essa informação, o processo documenta contribuições observáveis e dúvidas sem escolher uma pessoa.
- A baseline pode incluir mudanças locais quando expressamente registradas. Histórico versionado e conteúdo não commitado têm escopos separados.
- Fonte desconhecida e histórico incompleto são resultados válidos; o método exige declarar limites, não recuperar tudo a qualquer custo.
- Validação dinâmica está fora de todos os fluxos desta feature. Artefatos e medições existentes podem ser analisados como dados; o framework não inicia nem orquestra execução de código/build/teste/profiling, mesmo mediante solicitação. Um processo externo independente fica fora deste contrato.
- As fontes originais serviram à pesquisa inicial. O método local generalizado é a autoridade normativa; a procedência privada é opcional e os fatos particulares não integram o framework compartilhável nem comprovam futuros alvos.
- A metodologia incorporada é reutilizável para jogos e software geral. Estratégia do site, identidade profissional específica, geometria de layouts e número fixo de histórias não definem contratos universais.
- As fontes externas nesta pesquisa permaneceram somente leitura. Sua reconciliação no futuro produz recomendações e registros locais.
- A substituição da experiência autônoma atual foi solicitada. Compatibilidade com a CLI antiga não é requisito permanente; qualquer apoio temporário precisa de regra de transição.
- A constituição foi atualizada explicitamente para v2.0.0 antes da implementação para governar skills, processo readonly e Markdown canônico. A data original de ratificação segue pendente de confirmação; não foi inventada.
- Os nomes de pastas são interfaces solicitadas do produto; escolhas de linguagens, estrutura de implementação, mecanismos de isolamento e formatos técnicos pertencem ao plano.

## Scope and Dependencies

Inclui framework de análise, método de evidência, auditoria estática profunda, reconciliação readonly, documentação canônica, projeções seguras, revisão e evolução. Inclui reaproveitamento seletivo das capacidades existentes.

Não inclui correção dos projetos auditados, transformação do alvo, aprovação jurídica de licenças, inferência de impacto sem dados, recuperação infinita de arquivos perdidos, implementação de site de portfólio ou publicação automática em serviço externo.

Dependências: acesso de leitura aos alvos selecionados; agente capaz de seguir o método; ferramentas opcionais com cobertura/fallback declarado; contexto fornecido pelo usuário para autoria e fontes adicionais; governança atualizada antes da mudança arquitetural.

## Supporting Research

- [Método incorporado e reconciliação com o RepoDNA](methodology.md)
- [Mapa público de cobertura do método local](source-inventory.md)
- [Privacidade e autoridade local](contracts/privacy-local-authority.md)
- [Checklist de qualidade da especificação](checklists/requirements.md)
