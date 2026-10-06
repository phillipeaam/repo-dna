# Feature Specification: Framework de auditoria readonly e prontidão para portfólio

**Feature Branch**: `feature/001-readonly-audit-framework`

**Created**: 2026-10-03

**Status**: Auditoria estática e extensões US10–US13 de prontidão editorial, avaliação opcional da superfície do portfólio e catálogo técnico/contribuidores implementadas; US14 de reconstrução narrativa planejada, com implementação pendente

**Input**: User description: "Estudar o Notion e suas subpáginas somente para leitura, incorporar o método de avaliação ao RepoDNA e transformá-lo em um framework de skills e processos conduzidos por agente de IA. Receber repositórios em uma pasta ignorada pelo Git, analisá-los sem alterar nada e produzir uma página única de source of truth rica, completa e padronizada."

### Session 2026-10-05 — tags técnicas e lista de contribuidores

- Pedido incorporado à mesma feature: complementar a página Markdown canônica com tags e ocorrências rastreáveis de tecnologias, frameworks, pacotes, padrões, práticas, IA e codecs, além de uma lista qualificada de pessoas/contribuições.
- Pesquisa de referência: [tags, tecnologias e contribuidores](research-tags-and-contributors.md). Ela propõe facetas normalizadas, estados separados por ocorrência, atribuição ligada à evidência e perguntas de aceitação; suas fontes descrevem métodos e vocabulários, não comprovam uso no alvo.
- Decisões adotadas para esta especificação: reutilizar estados e IDs existentes; preservar declaração, disponibilidade, configuração, observação e temporalidade em eixos independentes; usar `observed_use` como perfil padrão de uso demonstrado; oferecer configuração ativa, histórico, inventário exploratório, assistência IA e experiência individual como consultas qualificadas distintas.
- Nenhuma clarificação adicional foi necessária: a documentação local existente e a pesquisa fornecem defaults seguros. A presença de instruções de agente não prova uso em tarefa; `AGENTS.md` não identifica ferramenta específica; nomes ou estrutura sem comportamento não provam padrões; uma pessoa não herda a stack do projeto.
- Escopo preservado: especificar o incremento, sem novo diretório de feature, integração externa, relatório separado, ferramentas obrigatórias ou reauditoria de alvo. T105/SC-025 continua reservado às validações finais.

### Session 2026-10-05 — reconstrução de contribuição e narrativa técnica

- Pedido incorporado à mesma feature: aproveitar fontes locais autorizadas para reconstruir contribuições, decisões e raciocínio técnico de projetos antigos, inclusive quando a memória pessoal for limitada, e sintetizar histórias úteis sem inventar fatos nem exigir uma forma editorial fixa.
- A análise deve ligar cada afirmação material à evidência e ao escopo em que ela vale; distinguir fato, inferência, hipótese e desconhecido; explicitar confiança qualitativa e seus motivos; separar autoria registrada, contribuição, decisão, colaboração, comportamento e resultado.
- A ausência de memória não é evidência negativa. Perguntas de esclarecimento só são úteis quando a resposta puder mudar materialmente a interpretação; lacunas sem fonte recuperável podem continuar desconhecidas. Destaques são opcionais (zero a três quando sustentados), concisos e revisáveis como rascunho.
- Lacunas inicialmente identificadas foram resolvidas no planejamento desta sessão: FR-083 e contratos agora tratam os campos como dimensões flexíveis; modelo/vocabulário incluem hipótese e reconstrução; metodologia e tarefas cobrem fontes, limites e cenários. A implementação continua pendente e está planejada em US14.

## Clarifications

### Session 2026-10-04
- Q: Qual deve ser o destino da página canônica gerada para cada projeto? Se escolher Notion, futuras análises podem criar ou atualizar páginas ali, mantendo as fontes originais somente para leitura? → A: Markdown local exclusivo em `analysis-output/`; remover HTML e Notion como destinos ou formatos de saída suportados.
- Q (decisão original, substituída pela revisão abaixo): Como comprovar que o repositório-alvo não pode ser alterado pela sessão de auditoria? → A: O host deve negar escrita no alvo e em seu Git associado, enquanto permite escrita separada em `analysis-output/`. Se não for possível comprovar essa separação antes da inspeção substantiva, o fluxo bloqueia.
- Q: Validação dinâmica pode fazer parte do fluxo quando solicitada e executada em cópia isolada? → A: Não nesta feature. O framework entregue é exclusivamente estático/readonly; qualquer validação dinâmica é um processo externo, separado e fora dos fluxos, responsabilidades e entregáveis desta feature.
- Q (revisão 2026-10-04): Auditoria deve bloquear quando o host não comprova prevenção efetiva de escrita? → A: Não por enquanto. A skill deve avisar quando a sessão puder gravar no alvo, seguir somente o procedimento estático sem escrita intencional e classificar a preservação como não verificada/observada; não pode afirmar garantia do host. A prevenção por sandbox/ACL continua recomendada para evolução futura.
- Q: Quem consulta o registro e onde Notion/Docs entram? → A: O entregável do framework permanece Markdown local; pessoas podem copiá-lo para documentos ou Notion depois, e agentes de IA podem consultá-lo. Isso não autoriza integração nem escrita externa pelo framework.

### Session 2026-10-05 — extensão de cobertura de portfólio

- Pedido incorporado: comparar os requisitos reutilizáveis de conteúdo, curadoria, evidência, experiência profissional, recomendações e avaliação do portfólio nas páginas de pesquisa com a spec existente; complementar esta mesma feature com os requisitos que faltavam, sem criar outra spec.
- Prompt aplicado pelo speckit-specify: “Amplie esta especificação existente, sem criar feature ou branch, para que o Markdown canônico resultante de uma auditoria ajude uma pessoa e um agente de IA a decidir como representar com segurança cada projeto em um portfólio. Incorpore os critérios reutilizáveis de briefing de público/cargo/canais, classificação editorial e justificativa de seleção, leitura rápida e aprofundamento técnico, contexto e ownership, histórias de engenharia, evidências e mídia, prontidão de claims, experiência profissional, recomendações e revisão da superfície do portfólio. Trate requisitos de Featured como pacote recomendado e proporcional; itens de Archive/Supporting recebem profundidade menor sem serem apagados. Quando a auditoria incluir um site ou protótipo de portfólio, avalie posicionamento, narrativa/arquitetura, descoberta de projetos, cases/evidências, direção visual, mobile, acessibilidade/interações, contato/conversão e manutenção; compare decisões que estiverem em aberto, considere especificações visuais fornecidas, registre o que foi realmente inspecionado, dimensões com notas justificadas, jornada do visitante, findings priorizados, decisões, próximos passos e fontes externas relevantes. Preserve o único Markdown local por produto, o procedimento de auditoria estática e a privacidade. Não use fatos, nomes, claims ou histórias específicas de outros estudos; não exija Notion nem outro serviço; não hardcode a identidade profissional, layout, tokens visuais, seleção de projetos ou número de histórias de um portfólio específico. Diferencie fatos, inferências, relato pessoal, recomendações e decisões humanas; deixe ausências como desconhecidas e não apresente recomendação como aprovação.”
- Decisão de escopo: a extensão cobre prontidão de conteúdo e, somente quando solicitada e houver uma superfície observável, uma avaliação de apresentação. Não implementa nem publica o site. O método local mantém os critérios generalizados; brief e decisões de um portfólio específico são contexto opcional, identificados por origem e estado.
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

### User Story 10 - Preparar conteúdo de projeto para uma decisão editorial de portfólio (Priority: P1)

Como pessoa responsável por um portfólio, quero que a fonte de verdade mostre o que um projeto comprova, onde ele se encaixa editorialmente e o que ainda falta para apresentá-lo, sem transformar evidência técnica em afirmação promocional.

**Why this priority**: A documentação deve apoiar a seleção e a apresentação pública de projetos, preservando a contribuição individual, a força da prova e os limites de publicação.

**Independent Test**: Fornecer projetos com contexto profissional, independente, técnico e de arquivo; briefs com diferentes cargos/públicos; mídia com permissões diferentes; e evidência incompleta. Verificar a leitura rápida, a classificação justificada, os pacotes proporcionais e a ausência de claims sem suporte.

**Acceptance Scenarios**:

1. **Given** um brief editorial informado pelo usuário, **When** a auditoria é consolidada, **Then** público, cargo(s), idioma, canais, sinais prioritários e restrições ficam registrados com origem e estado; campos ausentes não são inferidos.
2. **Given** um conjunto comparável de projetos explicitamente fornecido, **When** o agente sugere seu papel editorial, **Then** diferencia Featured candidate, Strong supporting, Supporting/Technical e Archive/Playground, explica relevância, sinal distinto, força da evidência e limitações, e marca cada decisão como humana ou recomendação provisória.
3. **Given** um projeto sem inventário comparável, **When** o agente avalia sua contribuição ao portfólio, **Then** informa aderência possível ao brief sem declarar ranking entre projetos que não foram comparados.
4. **Given** uma pessoa ou agente que faz uma leitura rápida, **When** consulta a camada inicial, **Then** encontra produto/contexto, papel/equipe/período quando conhecidos, plataforma/tecnologia, contribuição individual, relevância para o brief, estado público e ressalva principal; detalhes técnicos e evidências têm navegação para leitura aprofundada.
5. **Given** uma proposta de case, **When** o agente seleciona histórias, **Then** cada história segue contexto, ownership, problema, restrições, abordagem, trade-offs, evidência, resultado e reflexão quando disponíveis; quantidade e profundidade dependem da força da evidência e não são infladas para simetria.
6. **Given** um projeto classificado como Featured ou como Supporting/Archive, **When** sua prontidão é avaliada, **Then** o pacote de evidências é proporcional ao papel: itens desejáveis de Featured aparecem como metas e lacunas, enquanto documentação factual de arquivo pode ser suficiente com resumo e fonte pública segura.
7. **Given** media, resultado, experiência profissional ou recomendação sem atribuição/permissão suficiente, **When** o agente prepara a projeção, **Then** o estado de prontidão e o motivo são explícitos e a informação não é convertida em claim pública.

### User Story 11 - Revisar uma superfície de portfólio quando ela fizer parte do escopo (Priority: P2)

Como responsável por um site ou protótipo de portfólio, quero uma avaliação independente e acionável da experiência que o visitante realmente consegue observar, sem confundir julgamento profissional com pesquisa de usuários ou certificação.

**Why this priority**: Uma análise de código e conteúdo não avalia por si só se recrutadores encontram projetos, compreendem contribuições ou chegam a provas e contato.

**Independent Test**: Fornecer uma URL pública ou material de design selecionado, com mais de uma dimensão e viewport disponíveis, e comparar o relatório às observações capturadas. Repetir sem superfície renderizada para confirmar que lacunas de acesso viram “não observado”.

**Acceptance Scenarios**:

1. **Given** uma superfície de portfólio explicitamente incluída, **When** o agente a avalia, **Then** examina posicionamento/primeira impressão, narrativa e arquitetura de informação, descoberta de projetos, cases/evidências, direção visual, mobile, acessibilidade/interações, conversão/contato e manutenção, registrando fonte e alcance realmente observado.
2. **Given** uma avaliação com notas, **When** o relatório apresenta placar de 1 a 5 por dimensão, **Then** cada nota tem critério e observação localizada, e é rotulada como diagnóstico profissional, não como benchmark, teste com recrutadores ou certificação.
3. **Given** fricções ou lacunas observadas, **When** o relatório apresenta findings, **Then** cada item inclui prioridade, evidência/localização, impacto para visitante, recomendação, esforço relativo, dependência/risco e confiança; um percurso conciso de visitante e plano por fases sintetizam os principais achados.
4. **Given** alternativas de arquitetura ou interação em decisão, **When** o agente as compara, **Then** considera descoberta, escaneabilidade, profundidade, mobile, acessibilidade, manutenção e alinhamento ao brief; não recomenda carrossel, filtro, autoplay ou outro padrão sem avaliar descoberta e controles acessíveis.
5. **Given** URL, dispositivo, design file ou interação indisponível, **When** o agente conclui, **Then** informa limitações e não declara viewport, comportamento, responsividade, acessibilidade ou validação que não observou.
6. **Given** uma recomendação ainda não aprovada, **When** o documento é consolidado, **Then** ela permanece recomendação para decisão humana e nenhuma página, arquivo de design ou implementação é alterado.

### User Story 12 - Consultar tecnologias e padrões com evidências (Priority: P1)

Como analista de portfólio ou agente que compara projetos, quero filtrar tecnologias, pacotes e padrões e chegar ao sistema e à evidência onde aparecem, para entender o que foi usado sem tratar listas de dependências como experiência demonstrada.

**Why this priority**: Tags úteis dependem de saber o alcance real, a finalidade e a força da prova, tanto para identificar trabalhos relevantes quanto para preparar conversas de contratação.

**Independent Test**: Usar casos sintéticos com manifests, locks, código em runtime/testes/exemplos, dependências de terceiros, configuração ativa, uso removido, nomes de padrões com falsos positivos e estruturas demonstradas. Fazer perguntas de filtro e verificar se cada resultado leva ao local, estado, baseline e evidência corretos.

**Acceptance Scenarios**:

1. **Given** tags com aliases e conceitos próximos, **When** consulto a tecnologia ou padrão, **Then** sinônimos chegam à chave correta e conceitos distintos continuam separados.
2. **Given** uma dependência em manifest/lock sem consumidor observado, **When** consulto uso demonstrado, **Then** o resultado não a descreve como usada/instalada sem evidência e mantém sua declaração/resolução no inventário exploratório.
3. **Given** tecnologia ligada a um sistema e ocorrência no código/configuração, **When** filtro pelo seu uso observado, **Then** encontro finalidade, localização, contexto, baseline, evidência e limite de exercício/publicação.
4. **Given** nome de padrão em classe/documentação sem comportamento sustentado, **When** consulto padrões implementados, **Then** recebo candidato/inferência limitada ou estrutura descritiva, sem afirmar padrão como fato.
5. **Given** ocorrência removida ou evidência obsoleta, **When** consulto estado atual e histórico, **Then** o resultado atual não mascara o registro histórico nem reaproveita evidência stale como atual.

### User Story 13 - Identificar quem contribuiu e o alcance de sua experiência (Priority: P1)

Como analista ou agente que prepara uma conversa de contratação, quero consultar pessoas e contribuições por evidências e sistemas, incluindo trabalho fora do código, para descrever com precisão o que cada pessoa fez sem atribuir a ela toda a stack do grupo.

**Why this priority**: A utilidade de um portfólio para contratação depende de distinguir trabalho individual, compartilhado, declarado, de terceiro e desconhecido sem inferir senioridade ou liderança de atividade Git.

**Independent Test**: Usar casos sintéticos de autores/committers/coautores, aliases ambíguos, CODEOWNERS, bot, grupo, crédito de mídia, relato fornecido, contribuições não técnicas e histórico raso. Consultar uma pessoa, uma tecnologia e a completude da lista; verificar vínculo, limites e ausência de herança automática da stack.

**Acceptance Scenarios**:

1. **Given** um contributor listado na equipe e tecnologias observadas no projeto, **When** consulto experiência individual, **Then** só aparecem tecnologias ligadas a contribuições próprias por evidência.
2. **Given** aliases com suporte suficiente e aliases ambíguos, **When** a lista é consolidada, **Then** somente os primeiros são reconciliados e os demais permanecem como conflito/questão não resolvida.
3. **Given** contribuições de documentação, QA, revisão, arte ou áudio sem commits, **When** suas fontes disponíveis sustentam essas contribuições, **Then** elas aparecem com tipo, fonte, estado de atribuição e limite.
4. **Given** CODEOWNERS, commit de bot ou assistente e mídia de terceiro, **When** a lista é apresentada, **Then** responsabilidade, automação e procedência de terceiros não são convertidas em autoria de pessoa/equipe.
5. **Given** histórico raso ou fontes de crédito incompletas, **When** consulto a lista, **Then** ela declara que reúne contribuidores identificados no escopo e mostra a cobertura incompleta.

### User Story 14 - Reconstruir contribuição e raciocínio técnico com evidências (Priority: P1)

Como pessoa que documenta um projeto antigo, quero reunir evidências locais de código, histórico, documentação e validações disponíveis para reconstruir o problema, minhas contribuições e as decisões técnicas, mesmo sem lembrar todos os detalhes, e obter uma narrativa útil sem transformar hipóteses em fatos.

**Why this priority**: Histórias de portfólio ou consulta técnica precisam explicar o trabalho demonstrável e seu contexto, mas projetos antigos frequentemente têm memória incompleta, fontes parciais ou autoria compartilhada. A rastreabilidade permite recuperar contexto e corrigir interpretações sem exagerar resultados.

**Independent Test**: Em fixtures sintéticas com histórico de código, documentos contraditórios, testes configurados e resultados limitados, reconstruir uma contribuição individual/compartilhada e produzir zero a três destaques. Verificar rotas de evidência, tipos de conclusão, limites, autoria, estado de validação e ausência de afirmações sobre impacto sem suporte.

**Acceptance Scenarios**:

1. **Given** código, histórico e documentação local convergentes, **When** uma contribuição é reconstruída, **Then** cada afirmação material aponta para fontes e baseline e explica qual aspecto essas fontes sustentam.
2. **Given** memória pessoal limitada e evidência indireta, **When** são propostos contexto ou motivos candidatos, **Then** são marcados como inferência/hipótese com evidência favorável, alternativas ou contraevidência, confiança justificada e limites.
3. **Given** commit de autoria coletiva ou um sistema existente sem evidência individual de decisão, **When** o relatório descreve contribuições, **Then** não atribui automaticamente a uma pessoa a decisão, colaboração ou ownership do sistema inteiro.
4. **Given** um mecanismo técnico cuja consequência parece plausível, mas sem medição ou relato independente, **When** a narrativa discute resultados, **Then** separa o efeito observável no código do possível benefício e não o apresenta como resultado medido ou causalidade provada.
5. **Given** arquivos de teste, configuração de CI e logs/resultados fornecidos, **When** a validação é descrita, **Then** presença/configuração, execução/resultados e escopo (snapshot, cenário e ambiente) permanecem distintos; teste existente não prova qualidade geral nem resultado comercial.
6. **Given** fontes ausentes, inacessíveis ou conflitantes, **When** a reconstrução termina, **Then** registra cobertura, conflito ou estado desconhecido, não interpreta ausência como negação e não exige perguntas para fatos irrecuperáveis.
7. **Given** evidência suficiente apenas para parte da história, **When** destaques são sintetizados, **Then** cada destaque combina em prosa livre apenas aspectos sustentados, mantém lacunas visíveis e pode haver de zero a três destaques conforme evidência/relevância.
8. **Given** uma síntese candidata ou hipótese útil para apresentação, **When** ela entra no registro canônico, **Then** é identificada como rascunho/recomendação revisável e nenhuma publicação externa é feita automaticamente.

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
- A metodologia inclui orientação generalizada para transformar evidência de projeto em material de portfólio e avaliar uma superfície selecionada. Briefs, fatos pessoais, projetos, decisões de design e claims específicos são entradas contextuais, não padrões incorporados ao framework.
- Um manifest/lock pode identificar declaração ou resolução sem comprovar instalação, integração, execução ou contribuição; nome de padrão não basta sem seus participantes e comportamento observáveis.
- Configuração de assistente, SDK de IA, declaração em commit e atividade correlacionada têm forças diferentes; ausência de arquivos de instrução não comprova que IA nunca foi usada.
- Codec, alias ou identidade de pessoa podem permanecer desconhecidos quando o escopo só contém extensão/contêiner, nome semelhante ou email compartilhado sem evidência suficiente.
- Histórico limitado, squash, autoria compartilhada, CODEOWNERS sem implementação, pacote transitivo, código de exemplo/terceiro, evidência stale e acesso sem rede preservam cobertura parcial com limites declarados.
- Um registro de tecnologia, ocorrência ou pessoa pode ficar parcial. Manifest, lock, extensão, nome de classe, instrução de agente, CODEOWNERS ou estatística de commits, isoladamente, não sustentam as conclusões mais fortes de uso funcional, atividade de IA, implementação de padrão, identidade, autoria ou liderança.

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
- **FR-032**: Histórias de engenharia MUST tornar contexto, ownership, problema, restrições, abordagem, trade-offs, evidência e resultado recuperáveis; reflexão pessoal MUST ser identificada como relato. Campos sem suporte permanecem lacunas, e seleção/quantidade de histórias MUST acompanhar evidência e relevância sem obrigação de simetria.

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

- **FR-055**: A entrega MUST consistir em exatamente um arquivo Markdown canônico local por projeto/produto em `analysis-output/`, com status, data/baseline, Start Here, At a Glance, mapa de estudo, registro principal, avaliação de prontidão editorial para portfólio, projeção pública atual, questões, apêndices e índice de evidências; a avaliação da superfície do portfólio é incluída quando selecionada. Headings e identificadores estáveis MUST permitir a pessoas e agentes recuperar assuntos e apontar evidências. Todos os resultados e referências necessários à leitura MUST ser consolidados nesse arquivo; nenhum relatório, export ou anexo em outro formato é entregue.
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

#### Prontidão editorial e avaliação de portfólio

- **FR-078**: A pessoa usuária MAY fornecer um brief editorial com cargos e público pretendidos, idioma, canais de apresentação, competências/provas prioritárias, restrições de divulgação e especificações/decisões visuais aprovadas. O Markdown MUST registrar origem e estado desses dados (confirmado, provisório, histórico ou conflitante); brief ausente ou campo sem suporte MUST permanecer desconhecido, sem inferência automática.
- **FR-079**: Para cada produto incluído em avaliação de portfólio, o registro MUST separar contexto (por exemplo, profissional/comercial, independente, jam ou técnico) de papel editorial (Featured candidate, Strong supporting, Supporting/Technical, Archive/Playground ou não classificado), registrar sua justificativa e preservar a distinção entre decisão humana e sugestão do agente. Uma classificação de menor destaque MUST NOT excluir automaticamente o projeto do inventário ou da possibilidade de exploração em Archive/Playground.
- **FR-080**: Uma recomendação de seleção ou prioridade MUST considerar apenas um conjunto de projetos comparável e explicitamente selecionado, e explicar alinhamento ao brief, sinal profissional distinto, força/atualidade da evidência, disponibilidade pública, limitações e redundância. Sem esse conjunto, o relatório MAY avaliar aderência de um projeto, mas MUST NOT alegar ranking global ou seleção final do portfólio.
- **FR-081**: A camada de leitura rápida MUST permitir identificar produto e contexto, papel/equipe/período, plataforma/engine/tecnologias, foco, contribuições individuais, relevância ao brief, estado público e ressalva principal quando conhecidos; a documentação MUST oferecer navegação para aprofundamento técnico. A ausência de fato não impede o resumo e deve ser declarada.
- **FR-082**: A projeção editorial MUST poder propor título/linha de posicionamento, resumo curto, contribuições, relevância para o público, desafios, decisões, resultado/estado, links e ressalvas usando apenas claims rastreáveis. Texto deve priorizar trabalho demonstrado e contribuição sobre listas de ferramentas, evitar jargão desnecessário e manter facts, inferências e relatos distintos; proposta não equivale a aprovação humana.
- **FR-083**: A avaliação de histórias MUST considerar as dimensões contexto, ownership, problema, restrições, abordagem, trade-offs, evidência, resultado e reflexão, omitindo ou marcando campos sem suporte. Essa lista é um conjunto de prompts investigativos, não sequência, headings ou estrutura obrigatórios; síntese e prosa podem usar qualquer ordem. O contexto do produto deve ser conciso (até dois parágrafos curtos); histórias devem identificar a contribuição individual frente ao trabalho de equipe. Para Featured, duas histórias fortes são o padrão editorial e duas a três podem ser usadas quando a evidência justifica; isso é orientação, não quantidade obrigatória. O framework MUST permitir profundidade e quantidade diferentes entre categorias e MUST NOT inventar motivação, resultado ou simetria narrativa.
- **FR-084**: A prontidão por papel editorial MUST usar pacotes proporcionais. Para Featured, a referência de inventário desejável MUST poder acompanhar: uma imagem/clipe principal; um vídeo curto; dois a quatro clipes/GIFs de sistemas; três a seis screenshots; role/team/duration/platform/tech; três a cinco contribuições; um a três desafios; trade-offs; resultado/impacto/estado final; links públicos e nota de confidencialidade quando necessária. Um case Featured publicado SHOULD selecionar cerca de quatro a sete elementos visuais significativos (mídia principal, provas de histórias, diagrama opcional e apoio), evitando galeria excessiva; inventário disponível e elementos efetivamente usados são estados distintos. Metas não são gates absolutos para documentar ou publicar texto seguro. Supporting/Technical e Archive/Playground MAY usar resumo e evidência mais leves, mantendo identidade, contribuição e link/estado público quando disponíveis; ausência de mídia ou material incompleto MUST ser mostrada como lacuna, não como motivo automático para apagar a entrada.
- **FR-085**: Cada evidência visual/auditiva candidata MUST apontar para o comportamento, implementação ou claim que demonstra e distinguir captura/produto real de diagrama conceitual, proxy ou placeholder. O método SHOULD priorizar mídia real e pública com atribuição segura; diagramas originais/generalizados são alternativa para arquitetura confidencial. Proveniência, era/versão, autoria, terceiros, legenda e permissões continuam avaliados por ação conforme FR-047–050.
- **FR-086**: A matriz de prontidão editorial MUST avaliar separadamente texto, ownership, resultado/contexto público, build atual, artefato histórico, mídia visual/áudio/fontes, atribuição/permissões, links e claims quantitativas. Para cada item, registrar evidência, estado, condição, próximo passo e bloqueio específico; ausência de mídia não invalida automaticamente texto factual seguro.
- **FR-087**: Quando experiência profissional fizer parte do brief, o registro MUST distinguir empregador, título formal, intervalo, responsabilidades observadas/relatadas e projetos relacionados, mantendo cronologia de emprego separada da cronologia do produto e sem converter responsabilidade prática em título formal. Recomendações/testemunhos MAY ser preparados para uso editorial somente com texto exato, autor, origem, contexto e permissão de publicação identificáveis; não provam ownership ou liderança além do que declaram.
- **FR-088**: Relações entre projetos, produtos sucessores, produtos agrupados e funcionalidades compartilhadas MUST preservar lineage, evidência e autoria por produto. Agrupamento ou repetição de uma mesma contribuição MUST ser justificado e MUST NOT gerar dupla contagem ou claims conflitantes.
- **FR-089**: Quando a pessoa usuária incluir explicitamente um site, protótipo ou material de design de portfólio, o framework MUST oferecer avaliação condicional de posicionamento/primeira impressão; ordem, propósito e redundância de páginas/seções; descoberta e agrupamento de projetos; cases/evidências; direção visual e legibilidade; reflow mobile/tablet; acessibilidade e interação (ordem de leitura, toque, teclado, foco, nomes acessíveis, semântica, contraste, reduced motion e controle de mídia animada); contato/conversão e manutenção/consistência entre conteúdo, implementação e fonte visual. MUST avaliar falhas/indisponibilidade de mídia e performance apenas no limite de sinais e medições disponíveis, sem alegar benchmark ou teste que não ocorreu. A avaliação MUST registrar URLs/artefatos, páginas, viewports e interações realmente observados; uma dimensão indisponível ou sem evidência é `not_observed`, sem bloquear a auditoria de conteúdo/repositório. A inspeção MUST usar acesso somente leitura, sem autenticação, submissão de formulários ou ações que alterem estado.
- **FR-090**: A avaliação condicional de superfície MUST produzir no mesmo Markdown resumo executivo, placar por dimensão (1–5 com critério, observação e confiança), percurso de visitante, findings priorizados (P0–P3) com localização/evidência, impacto, recomendação, esforço relativo, risco/dependência e confiança, além de arquitetura/direção recomendada, gaps de conteúdo/evidência, plano por fases, decisões/perguntas e limitações. Notas são diagnóstico profissional, não benchmark de mercado, teste com usuários/recrutadores, certificação ou medida de conversão.
- **FR-091**: Ao avaliar uma decisão visual ou de navegação em aberto, o agente MUST comparar as alternativas realmente consideradas segundo descoberta, escaneabilidade, profundidade, mobile, acessibilidade, manutenção e alinhamento ao brief; MUST explicar controles, foco e descoberta se recomendar carrossel/seletor, examinar necessidade de busca/filtros/contador em relação ao tamanho e diversidade do inventário e MUST NOT presumir autoplay/loop ou impor layout, cor, tipografia, número de projetos ou filtro sem justificativa contextual. Especificações visuais aprovadas fornecidas para aquela superfície são referência de conformidade; exemplos de outro projeto não são tokens universais.
- **FR-092**: Pesquisa externa em uma avaliação de superfície MUST limitar-se a decisões relevantes e abertas, priorizar fontes confiáveis e atuais (incluindo padrões/fontes oficiais de acessibilidade quando aplicável), registrar título, link direto e data quando disponível, e separar recomendação geral, evidência da fonte e julgamento profissional. Estudos de domínios diferentes não devem ser extrapolados sem declarar limites. A falta de pesquisa externa MUST ser declarada quando ela for necessária para sustentar uma recomendação.
- **FR-093**: Briefs e decisões editoriais MUST preservar estados aprovado/locked, provisório, histórico/superado e conflito, com origem e data quando conhecidas. O agente MUST sinalizar conflito material e pedir posicionamento humano quando não houver resolução segura; recência isolada de uma fonte não prova aprovação ou autoridade.
- **FR-094**: As avaliações de conteúdo e de superfície MUST ser somente leitura. Elas MUST NOT executar código do alvo, alterar repositórios, páginas, protótipos ou arquivos de design, aprovar claims/permissões, publicar conteúdo, nem criar entregáveis persistentes adicionais.

#### Tags, tecnologias e ocorrências

- **FR-095**: O registro canônico MUST incluir índice consultável de tags ligadas a registros detalhados, ocorrências, sistemas e evidências. Cada conceito MUST ter chave canônica estável, faceta, rótulo legível e aliases de consulta quando conhecidos; sinônimos MUST resolver para uma chave sem fundir conceitos distintos. O índice MUST conservar os qualificadores que delimitam cada resultado.
- **FR-096**: O inventário MUST cobrir linguagens, engines, frameworks, packages/bibliotecas, plataformas, serviços, ferramentas, práticas, domínios técnicos, estilos arquiteturais e padrões aplicáveis. Cada ocorrência MUST identificar repositório/componente e baseline, localização recuperável, sistema/finalidade, contexto (como runtime, editor, build, testes, CI, documentação ou exemplos), origem própria/terceira/gerada/desconhecida e evidências/limites aplicáveis.
- **FR-097**: Classificação de tecnologia MUST manter separados presença/dependência declarada, resolução de versão, disponibilidade material, uso observado no fluxo do sistema e configuração ativa. `installed` MUST exigir evidência de disponibilidade instalada no escopo; manifest ou lock, sozinhos, provam declaração/resolução conforme o caso, não instalação. Os estados `possible_use`, `observed_use` e `active_configuration` MUST conservar seus significados e NÃO podem ser promovidos por nome, importação solta ou intenção documental sem a evidência apropriada.
- **FR-098**: Packages MUST registrar, quando disponível sem execução, ecossistema, identidade/nome, namespace/origem, versão declarada, versão resolvida e relação do grafo (direta, transitiva, opcional, peer, vendorizada ou desconhecida), diferenciando esses dados de uso observado e contexto de consumo. Versões ausentes ou conflitos MUST permanecer explícitos; popularidade externa MUST NOT determinar detecção, relevância ou experiência.
- **FR-099**: O relatório MUST poder destacar packages/tecnologias cuja função seja relevante e demonstrada para sistemas/contribuições, justificando a seleção pela evidência e finalidade técnica. Inventário abrangente e resumo destacado MUST ser ligados e não duplicados; métricas externas de popularidade, vagas ou downloads MUST NOT ser tratadas como prova de uso, qualidade ou domínio individual.

#### Padrões, arquitetura e práticas

- **FR-100**: Padrão arquitetural/de software só MUST ser nomeado quando seu comportamento, participantes, relações e escopo forem sustentados por ocorrência e evidência. Nomes de tipos/pastas, pacote instalado, diagrama/README declarativo ou palavra no código são pistas, não prova isolada; caso a semântica não seja suficiente, descrever a estrutura observada em linguagem comum ou marcar candidato/inferência com limites.
- **FR-101**: Registros de padrão MUST distinguir intenção declarada, estrutura observada, inferência, implementação própria e utilização/integração de terceiro; MUST apontar participantes e ligações ao sistema. A ausência de exemplo conhecido não pode forçar a atribuição de padrão, e padrão observado não equivale a qualidade/certificação.

#### IA e codecs

- **FR-102**: O registro MUST distinguir assistência ao desenvolvimento por ferramentas/agentes, integração de IA no produto, técnica implementada e provedor/modelo configurado ou observado. Configuração/instruções, declaração atribuída, evidência de atividade correlacionada e fluxo de produto são níveis diferentes. Arquivo `AGENTS.md` sozinho MUST NOT identificar Codex nem outro produto; modelo/versão/provider não identificado MUST permanecer desconhecido.
- **FR-103**: A atribuição de assistência por IA MUST NOT derivar de estilo do código, MUST NOT estimar fração humano/IA e MUST NOT atribuir ferramenta a alguém ou tarefa sem evidência apropriada. A IA usada pelo agente auditor MUST NOT ser convertida em claim sobre o desenvolvimento do alvo. Prompts, transcrições, dados privados, credenciais e endpoints restritos MUST ser omitidos ou redigidos segundo divulgação.
- **FR-104**: O inventário MUST distinguir ferramentas Codex de codecs/formatos de mídia e registrar separadamente contêiner/formato, codec e configuração de processamento quando evidenciados. Extensão de arquivo ou contêiner, sem metadados/configuração que identifiquem o stream/codec, MUST resultar em codec desconhecido; ausência de ferramenta ou fonte de metadados MUST ser uma limitação, sem instalação ou execução de código do alvo.

#### Pessoas, contribuições e consulta individual

- **FR-105**: A seção existente de papel, equipe e contribuições MUST conter uma lista de pessoas/contribuidores identificados no escopo e informar cobertura/completude, fontes examinadas, identidades pendentes e limites temporais. Para cada identidade, registrar nome/alias publicável ou referência local permitida, papéis/contribuições observados ou declarados, sistemas/ocorrências associados, período observado, evidências e estado de atribuição/divulgação; campos não sustentados MUST permanecer desconhecidos.
- **FR-106**: Investigação de identidade MUST distinguir autor, committer, coautor, equipe/grupo, bot, assistente de IA, responsável CODEOWNERS e criador de asset de terceiros. Aliases MUST NOT ser unidos por semelhança de nome, email compartilhado ou conveniência estatística; mapeamento explícito/evidência adequada, conflitos e resolução devem preservar procedência. Histórico Git, gráfico de contribuidores e contagens MUST ser tratados como fontes parciais com limitações, não como cadastro completo.
- **FR-107**: A lista MUST admitir contribuições além de código, incluindo design, arte/animação, áudio, documentação, testes/QA, revisão, acessibilidade/localização, build/ferramentas e operação quando sustentadas. Papel formal/cargo/empregador MUST continuar distinto da participação observada ou relatada neste produto; responsabilidade configurada, contagem Git e relato pessoal não podem ser promovidos a autoria exclusiva ou liderança.
- **FR-108**: A ligação entre pessoa, contribuição e tecnologia/sistema MUST ser explícita e sustentada por evidência independente da existência da tag no produto. Uma pessoa da equipe MUST NOT herdar automaticamente as tecnologias do projeto. Participação compartilhada permanece compartilhada, bots/agentes permanecem identificados como não pessoas e terceiros são creditados sem serem apresentados como equipe própria sem suporte.
- **FR-109**: O documento MUST suportar consultas qualificadas distintas para uso demonstrado no projeto (`observed_use`), configuração ativa, experiência individual sustentada, inventário exploratório (declarado/candidato/conflitante), histórico/removido e assistência por IA. Perfil padrão de uso demonstrado MUST excluir somente declarados/candidatos e ocorrências históricas ou stale, sem ocultar essas categorias do registro detalhado; os demais perfis MUST mostrar escopo, estado, baseline, atribuição e caminho à evidência. Consulta individual exige vínculo próprio sustentado.

#### Consolidação, atualização e privacidade técnica

- **FR-110**: Tags, registros técnicos, ocorrências, pessoas e vínculos MUST reutilizar fontes/evidências, sistemas, contribuições e identificadores existentes sempre que possível, mantendo referências sem autoridade duplicada. O relatório MUST permanecer um único Markdown, com índice e conteúdo concordantes, sem catálogo, JSON, banco ou relatório persistente paralelo.
- **FR-111**: Atualização MUST preservar estados e ocorrências históricas/removidas, identificar baseline e vocabulário, marcar evidências stale quando aplicável e revalidar classificação/atribuição afetada. Migração de relatório existente MUST ocorrer no mesmo arquivo, registrar lacunas e MUST NOT marcar áreas avaliadas sem suporte.
- **FR-112**: Descoberta de tags e contribuidores MUST funcionar a partir de fontes locais autorizadas, em método estático, sem serviço/rede, catálogo externo, Notion, instalação de dependências/parser, build ou execução do alvo como requisito. Ferramentas/fonte pública opcional já disponível podem informar identidades/descrições, mas sua indisponibilidade MUST preservar o resultado local e sua limitação.
- **FR-113**: A metodologia compartilhável MUST usar exemplos genéricos/fictícios e MUST NOT incluir nomes, empresas, projetos, aliases, contatos, prompts ou URLs privados. O relatório do projeto MUST registrar divulgação por campo quando pertinente e não publicar contatos pessoais, identidades civis, detalhes privados nem autoria de material de terceiros além do escopo autorizado.

#### Reconstrução de contribuição, raciocínio e narrativa técnica

- **FR-114**: A reconstrução MUST usar somente fontes locais, fornecidas pelo usuário ou acessíveis publicamente sem autenticação e dentro do escopo autorizado. Issues, reviews e releases só podem ser considerados quando materializados localmente, fornecidos pelo usuário ou publicamente acessíveis em leitura; serviço privado indisponível/inacessível MUST ser `unavailable`/`not_observed`, nunca assumido como consultado ou inexistente.
- **FR-115**: Cada afirmação material da reconstrução MUST apontar a fonte/localização recuperável e baseline/escopo, declarar a relação entre a evidência e a afirmação, tipo (`fact`, `inference`, `hypothesis`, `unknown`/`not_observed` ou conflito), limitação e confiança qualitativa com justificativa. A rubrica comum MUST usar `high` para suporte direto e adequado ao escopo, sem contradição material aberta; `medium` para suporte parcial/indireto ou com limitação relevante, sem alternativa igualmente sustentada; e `low` para suporte fraco/ambíguo ou explicações alternativas igualmente plausíveis. Claim sem suporte evidencial suficiente permanece `unknown`/`unsupported` e sem nota de confiança; não recebe `low` por padrão. Justificativas MUST considerar tipo/direção da fonte, corroboração, contradições e escopo. Tipos diferentes MUST NOT ser silenciosamente promovidos uns aos outros.
- **FR-116**: A avaliação MUST distinguir o que cada fonte pode sustentar: autoria registrada, comportamento/estrutura, decisão ou intenção relatada, colaboração, validação executada e resultado/impacto. Evidência adequada a uma dimensão não prova automaticamente as demais.
- **FR-117**: Metadado de autor/committer, presença de pessoa em roster, existência de sistema, CODEOWNERS ou estatística de atividade, isoladamente, MUST NOT sustentar que alguém tomou uma decisão, colaborou em sua implementação, foi responsável pelo sistema completo ou obteve determinado resultado. Contribuição individual, compartilhada, declarada e desconhecida permanece distinguível.
- **FR-118**: Quando a memória for limitada, o processo MUST poder propor reconstruções candidatas a partir das fontes, associando suporte, contraevidência/alternativas, confiança e limites. A hipótese deve permanecer editável e não substituir a evidência original; confiança MUST ser explicada qualitativamente, sem probabilidade inventada.
- **FR-119**: Falta de lembrança ou de fonte não é evidência de que algo não ocorreu. Perguntas de esclarecimento SHOULD ser feitas apenas quando uma resposta puder mudar materialmente atribuição, interpretação ou wording seguro; detalhes sem rota razoável de recuperação podem permanecer desconhecidos sem bloquear o restante.
- **FR-120**: Desafio, restrição, dificuldade, mecanismo, decisão e trade-off MUST ser descritos no nível sustentado pelas fontes. Complexidade, qualidade ou motivação pessoal MUST NOT ser inferidas apenas pelo tamanho/novidade do código ou pela existência de uma arquitetura.
- **FR-121**: Consequência técnica diretamente demonstrável MUST ser separada de benefício potencial para usuário/negócio. Impacto, melhoria, métrica e causalidade exigem evidência apropriada; sem ela, efeitos plausíveis permanecem hipóteses ou perguntas, nunca resultados afirmados.
- **FR-122**: Artefato de teste/configuração, resultado de execução existente, revisão, experimento e release MUST ser registrado como tipo de validação distinto e limitado ao snapshot, cenário e ambiente conhecidos. Presença de teste ou log não prova qualidade geral, adoção, impacto ou resultado comercial.
- **FR-123**: A síntese técnica MUST permitir prosa e ordem editorial flexíveis. Contexto/problema/restrições, mecanismo/decisão/trade-off, contribuição, consequência, colaboração, validação e resultado são dimensões de investigação, não headings ou sequência obrigatórios. Destaques MUST ser concisos, conter de zero a três itens conforme suporte e relevância, e cada afirmação material deve conservar rota de evidência e limites.
- **FR-124**: Texto de apresentação, interpretação ou hipótese sugeridos MUST ser marcados como rascunho/recomendação para revisão humana; aceitação, correção ou rejeição MUST preservar a procedência evidencial. O framework MUST NOT publicar ou enviar automaticamente a síntese a qualquer destino externo.
- **FR-125**: A avaliação da qualidade desta capacidade MUST estabelecer previamente projetos/cenários representativos, perfil de revisão, perguntas e critérios de rastreabilidade/compreensibilidade; MUST registrar observações e lacunas qualitativas sem inventar taxa percentual, promessa de contratação ou limiar de sucesso sem baseline empírico aprovado.

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
- **Brief editorial**: cargos/públicos/canais/sinais prioritários e restrições declarados, com origem, vigência e estado de decisão.
- **Papel editorial do projeto**: contexto, categoria, justificativa de aderência, força de evidência e decisão humana ou sugestão provisória.
- **Ativo e pacote de apresentação**: mídia/claim demonstrada, era, permissão, atribuição e papel no nível editorial selecionado.
- **Registro profissional/social proof**: experiência, título formal, responsabilidades, datas e recomendação com fonte e permissão quando aplicável.
- **Finding de superfície**: dimensão, viewport/localização, evidência, prioridade, impacto, recomendação, esforço relativo, risco e confiança.
- **Método local**: conjunto normativo aprovado de instruções, regras e contratos, com correspondência por tema e sem dependência das fontes originais.
- **Vocabulário/tag**: conceito técnico com chave/faceta estáveis, rótulo, aliases, relações, definição e versão de vocabulário.
- **Registro técnico e ocorrência**: tecnologia, package, ferramenta, padrão, prática, técnica de IA ou codec e sua ocorrência localizada por repo/componente/baseline, finalidade, contexto, estado, origem, versão, evidência e limites.
- **Pessoa/contribuidor**: pessoa, equipe/grupo, bot ou ferramenta de IA com identidade/alias, fonte, tipo de crédito, contribuições, sistemas ligados, período observado, resolução de identidade, completude e estado de divulgação.
- **Vínculo de contribuição**: relação sustentada entre pessoa, contribuição, sistema/tecnologia e ocorrência, com autoria individual/compartilhada/declarada/desconhecida e fontes de evidência.
- **Perfil de consulta**: critério selecionado de busca de tags para uso observado, configuração, experiência pessoal, inventário exploratório, histórico ou assistência IA; mantém estados e rotas de evidência.
- **Reconstrução técnica/destaque**: hipótese ou síntese narrativa ligada a contribuição, sistema, baseline e fontes; preserva tipo de conclusão, relação de suporte, contraevidência/alternativas, confiança justificada, limitações e estado de revisão humana. Não substitui claim nem finding de origem.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em todas as auditorias de aceitação, nenhum conteúdo/estado de projeto do alvo é alterado; casos com verificação incompleta são explicitamente parciais.
- **SC-002**: 100% dos resultados e temporários permanecem fora dos alvos e de seus diretórios Git.
- **SC-003**: Cada domínio obrigatório tem resultado ou estado de cobertura com motivo; nenhum domínio desaparece silenciosamente.
- **SC-004**: 100% das conclusões relevantes no registro principal têm referência recuperável, escopo, estado de evidência e limitação quando aplicável.
- **SC-005**: Nos casos de aceitação com autoria ambígua, planejamento sem código, tag sem binário e desempenho não medido, nenhuma claim é promovida indevidamente.
- **SC-006**: Dado um conjunto predefinido de perguntas sobre identidade do projeto, contribuições, arquitetura, release atual/histórico, adequação editorial, prontidão de evidências e limites, um agente de IA responde com referências recuperáveis para cada afirmação factual e declara como desconhecidas as respostas sem suporte; nenhuma resposta factual fica sem evidência citada.
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
- **SC-017**: Em todos os casos de aceitação com brief presente ou ausente, o relatório registra origem/estado dos critérios editoriais e deixa como desconhecidos os dados de público, cargo, canal ou restrição que não foram fornecidos ou sustentados.
- **SC-018**: Em todos os casos de aceitação com mais de um projeto, recomendações de papel/prioridade identificam conjunto comparado, rationale e estado humano/provisório; sem conjunto comparável, nenhum ranking global é produzido.
- **SC-019**: 100% dos resumos e propostas de case nos casos de aceitação têm referências para claims factuais, distinguem contribuição individual/equipe e mantêm campos de história sem prova como lacunas ou relato identificado.
- **SC-020**: Casos Featured e Archive/Supporting produzem pacotes de prontidão proporcionais: os itens desejáveis de Featured e seus gaps ficam visíveis, sem impedir documentação ou texto factual seguro por falta de assets.
- **SC-021**: Nos casos com experiência profissional, recomendação, mídia sem permissão, case histórico ou claim de performance sem medição, o relatório não infere cargo, autorização, estado atual, autoria ou resultado não provado e mostra o bloqueio/limite correspondente.
- **SC-022**: Quando uma superfície de portfólio é incluída, toda nota, finding e recomendação contém suporte observável e limite de avaliação; o relatório identifica dimensões não observadas e não afirma testes, certificação ou conversão sem evidência.
- **SC-023**: A avaliação de superfície registra as viewports/interações realmente observadas e inclui sumário, percurso, prioridades e plano de ação no mesmo Markdown; nenhuma superfície ou fonte externa é modificada.
- **SC-024**: Todo conteúdo adicional do framework permanece genérico e utilizável sem Notion; nomes, claims, layout, tokens e decisões de casos/portfólios pesquisados não são promovidos a padrão universal.
- **SC-025**: Em todos os documentos de aceitação com projeção editorial, um leitor não familiarizado localiza produto/contexto e contribuição individual em até 60 segundos; ao menos uma história selecionada oferece uma rota de evidência adequada a uma leitura aprofundada de cerca de 5–10 minutos, sem exigir a leitura integral dos apêndices.
- **SC-026**: Cases Featured de aceitação apresentam uma seleção curta de aproximadamente 4–7 elementos visuais significativos ou registram com clareza as lacunas de mídia/permissão; a quantidade de arquivos disponíveis não é confundida com quantidade publicada.
- **SC-027**: Na avaliação de superfícies, todas as dimensões do FR-089 recebem finding fundamentado ou estado `not_observed`; nenhuma propriedade de viewport, interação, performance, acessibilidade ou conversão é declarada sem observação ou medição indicada.
- **SC-028**: Em 100% dos registros de tecnologia/padrão presentes no índice dos casos de aceitação, tags resolvem para facetas/chaves normalizadas e ocorrência detalhada com localização, sistema, baseline e evidência recuperável; aliases não geram identidade duplicada ou fusão incorreta.
- **SC-029**: Nos casos com manifesto/lock isolado, disponibilidade ausente, versão divergente, pacote transitivo, terceiro, exemplo, teste, flag condicional e referência morta, estado/contexto permanecem separados e nenhuma declaração é apresentada como instalação, uso funcional ou versão exercitada sem suporte.
- **SC-030**: Nos casos de aceitação de padrões com nome falso positivo, intenção documental, estrutura parcial, terceiro e padrão demonstrado, o relatório preserva natureza, participantes, escopo e prova; nenhum padrão recebe conclusão afirmativa sustentada apenas pelo nome de tipo/pasta.
- **SC-031**: Nos casos de IA com AGENTS.md, instrução específica de ferramenta, SDK sem fluxo, integração estática, modelo configurado, atividade declarada/correlacionada e nenhum sinal, dimensão/fonte/limite ficam visíveis e nenhum uso, autoria, modelo ou percentual não sustentado é afirmado.
- **SC-032**: Nos casos de mídia, contêiner/extensão isolados identificam apenas formato demonstrado; codec somente é listado quando uma fonte apropriada o identifica, mantendo Codex separado de codecs.
- **SC-033**: Em todo relatório de aceitação, a lista de contribuidores informa escopo/completude/fontes; identidades não resolvidas e aliases conflitantes permanecem pendentes, histórico limitado deixa cobertura parcial e contribuições fora do Git continuam elegíveis quando evidenciadas.
- **SC-034**: Em todos os casos de aceitação, tags técnicas só aparecem como experiência individual quando contribuição própria é ligada à ocorrência por evidência; autoria compartilhada, trabalho não técnico, bot/IA e créditos de terceiros mantêm seus tipos e limites.
- **SC-035**: Casos de migração/atualização preservam no mesmo Markdown IDs e fontes válidos, registram baseline/vocabulário, mantêm removidos como históricos, identificam evidências stale e não declaram áreas novas completas por mera presença de headings.
- **SC-036**: Toda a matriz de aceitação de tags/contribuições pode ser concluída com fontes locais e ferramentas já disponíveis; indisponibilidade de rede/catálogo/parser deixa cobertura/limites explícitos e não produz saída persistente fora do arquivo Markdown canônico.
- **SC-037**: Conteúdo versionado da metodologia/fixtures usa exclusivamente exemplos sintéticos; zero nomes, empresas, projetos ou metadados pessoais de fontes privadas aparecem em tags, fontes demonstrativas ou vínculos de contribuidor.
- **SC-038**: Em todos os cenários de reconstrução, somente fontes locais, fornecidas ou públicas sem autenticação são usadas; indisponibilidade de serviço/fonte privada é registrada como cobertura indisponível/não observada e nunca como ausência comprovada.
- **SC-039**: 100% das afirmações materiais nas reconstruções de aceitação têm evidência/localização e baseline, relação de suporte, tipo de conclusão, limite e justificativa de confiança; hipóteses não são apresentadas como fatos.
- **SC-040**: Nos cenários com commit/roster/sistema, decisão, colaboração, autoria de sistema e resultado são atribuídos apenas quando a evidência é apropriada; autoria de commit ou existência de sistema isoladas nunca bastam para inferir os demais.
- **SC-041**: Nos cenários de consequência plausível sem medição, benefícios, métricas e causalidade não aparecem como resultados factuais; efeito estático observável, hipótese e resultado medido permanecem separados.
- **SC-042**: Nos cenários com testes/configurações/logs, o registro distingue artefato presente de execução/resultados e limita cada resultado a snapshot, cenário e ambiente; nenhum deles é generalizado automaticamente para qualidade ou impacto comercial.
- **SC-043**: Quando a memória ou fonte estiver ausente, a reconstrução preserva `unknown`/`not_observed` ou conflito e faz pergunta somente se a resposta puder alterar materialmente interpretação, atribuição ou wording; silêncio/memória limitada nunca prova não ocorrência.
- **SC-044**: Uma revisão de síntese aceita histórias legíveis em ordens e formas de prosa diferentes, seleciona de zero a três destaques sustentados e encontra evidência/limites para todas as afirmações materiais sem exigir headings ou sequência fixa.
- **SC-045**: Sugestões de narrativa/hipóteses são identificadas como rascunho revisável, e aceitação/correção/rejeição mantém vínculo à evidência; nenhum cenário publica ou envia conteúdo automaticamente.
- **SC-046**: A avaliação de compreensibilidade usa cenários representativos, perguntas e critérios definidos antes da revisão e registra resultados/limites qualitativos; nenhum percentual, previsão de contratação ou limiar sem baseline é inventado.
- **SC-047**: Em todos os casos de reconstrução com suporte evidencial, confiança usa consistentemente `high`/`medium`/`low` conforme FR-115 e registra justificativa baseada em fonte/direção, corroboração, contradição e escopo; alegações sem suporte permanecem sem nota (`unknown`/`unsupported`) em vez de receberem `low` automaticamente.

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
- A metodologia é reutilizável para jogos e software geral. Critérios editoriais e de avaliação de superfície são locais e configuráveis; identidade profissional, estratégia/IA de um site, layout, design tokens e seleção de projetos não são hardcoded. Narrativas seguem estrutura reutilizável, sem impor número fixo de histórias.
- As fontes externas nesta pesquisa permaneceram somente leitura. Sua reconciliação no futuro produz recomendações e registros locais.
- A substituição da experiência autônoma atual foi solicitada. Compatibilidade com a CLI antiga não é requisito permanente; qualquer apoio temporário precisa de regra de transição.
- A constituição v2.0.0 governou a migração inicial para skills, auditoria readonly e Markdown canônico; foi posteriormente atualizada para v3.0.0 para permitir análise estática procedural com aviso quando o host não comprova prevenção de escrita. A data original de ratificação segue pendente de confirmação; não foi inventada.
- Os nomes de pastas são interfaces solicitadas do produto; escolhas de linguagens, estrutura de implementação, mecanismos de isolamento e formatos técnicos pertencem ao plano.
- Chaves de tags são um vocabulário local versionado, extensível e passível de alias; não exigem RDF, SBOM formal ou taxonomia universal. Conceito não encontrado permanece identificável como não verificado ou candidato.
- `installed` exige evidência local de disponibilidade do pacote/tecnologia; manifests e locks informam declaração/resolução, com estados distintos, sem presumir instalação ou build.
- A lista é de contribuidores identificados no escopo, não necessariamente inventário legal/total da equipe. Relato pessoal é admissível se atribuído e não convertido em comprovação independente.
- O perfil padrão de busca representa uso estático observado; configuração ativa e execução/release permanecem eixos separados. Nenhum perfil sozinho certifica qualidade, segurança ou competência.
- Codex representa assistência/agente de desenvolvimento; codec representa codificação de mídia. Sistemas de IA de jogo ou de produto são categorizados pelas técnicas/integrações sustentadas, sem exigir modelos generativos.
- Fontes locais podem permitir reconstruir parte de um projeto antigo sem memória completa; toda reconstrução continua qualificada pela evidência disponível e pode deixar fatos desconhecidos.
- Issues, revisões, serviços e conversas privadas não são acessados por credenciais/integradores como requisito; somente cópias locais, material fornecido ou acesso público anônimo explicitamente no escopo podem contribuir.
- Destaques de engenharia são rascunhos editoriais opcionais, não uma nova saída: permanecem no mesmo Markdown, podem ser zero e não são publicados automaticamente.

## Scope and Dependencies

Inclui framework de análise, método de evidência, auditoria estática profunda, reconciliação readonly, documentação canônica com índice de tags/tecnologias/contribuidores, projeções seguras, revisão e evolução. Inclui reaproveitamento seletivo das capacidades existentes.

Não inclui correção dos projetos auditados, transformação do alvo, aprovação jurídica de licenças, inferência de impacto sem dados, recuperação infinita de arquivos perdidos, implementação de site de portfólio ou publicação automática em serviço externo. Uma avaliação da superfície pública/desenho do portfólio é condicional e somente leitura; ela não constrói nem altera o site.

Dependências: acesso de leitura aos alvos selecionados; agente capaz de seguir o método; ferramentas opcionais com cobertura/fallback declarado; contexto fornecido pelo usuário para autoria e fontes adicionais; governança atualizada antes da mudança arquitetural.

## Supporting Research

- [Método incorporado e reconciliação com o RepoDNA](methodology.md)
- [Mapa público de cobertura do método local](source-inventory.md)
- [Privacidade e autoridade local](contracts/privacy-local-authority.md)
- [Checklist de qualidade da especificação](checklists/requirements.md)
- [Pesquisa de tags, tecnologias, padrões e contribuidores](research-tags-and-contributors.md)
- Alinhamento de planejamento realizado em 2026-10-05: `plan.md`, `data-model.md`, `methodology.md`, contratos, `quickstart.md` e `tasks.md` agora cobrem US14/FR-114–125/SC-038–047. A lista de FR-083 é um conjunto de prompts de investigação, com ordem editorial livre. Restam execução e validação da implementação; SC-025 permanece a validação humana final.
