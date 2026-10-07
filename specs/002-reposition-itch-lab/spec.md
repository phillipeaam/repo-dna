# Feature Specification: Modelo de apresentação de projetos a partir de audits

**Feature Branch**: `feature/002-reposition-itch-lab`

**Created**: 2026-10-04

**Updated**: 2026-10-07

**Revision**: 5 — documentação compartilhável neutra; arquitetura e rastreabilidade preservadas

**Status**: Documentação neutralizada e verificada no recorte compartilhável; validação do método usa cenários fictícios

**Input**: User description: "Definir um padrão reutilizável para transformar dados já gerados pelo audit RepoDNA em uma apresentação clara de um projeto na página itch.io ou em outra loja/canal escolhido."

A feature 001 governa a investigação e a fonte factual. Esta feature acrescenta seleção e apresentação por público/canal. A [migração de escopo](migration.md) registra a correspondência com requisitos antigos; FR-001–026 são preservados da revisão 2; FR-027–030 acrescentam consolidação e reuso na revisão 3.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Preparar uma apresentação fiel ao audit (Priority: P1)

Como responsável pelo projeto, quero selecionar o que o audit sustenta e preparar um rascunho para meu público, sem reinvestigar ou manter outra fonte factual.

**Why this priority**: Entrega o núcleo útil mesmo com pouca evidência.

**Independent Test**: Preparar apresentação concisa a partir de registro sintético com identidade, autoria compartilhada e resultado desconhecido; conferir origem de cada afirmação no mesmo registro.

**Acceptance Scenarios**:

1. **Given** audit com produto, versão e baseline, **When** preparo a apresentação, **Then** seleção e rascunho ficam no mesmo registro, com rota de cada afirmação material às fontes e limites existentes.
2. **Given** projeto pequeno com pouca evidência, **When** preparo o texto, **Then** posso usar poucos parágrafos e omitir dimensões sem suporte, sem inventar história, métrica ou mídia.
3. **Given** autoria compartilhada/desconhecida, **When** seleciono créditos/contribuições, **Then** preservo a atribuição sustentada, sem atribuir trabalho da equipe a uma pessoa.
4. **Given** fato, hipótese, relato e conflito com naturezas diferentes, **When** redijo, **Then** preservo essas diferenças; claims sem suporte são omitidas ou qualificadas de modo compreensível.
5. **Given** apenas fichas secundárias ou audit original indisponível, **When** preparo piloto real, **Then** registro recuperação/seleção da fonte como dependência; definição e validação sintética do modelo continuam.

---

### User Story 2 - Adaptar os mesmos fatos ao destino (Priority: P1)

Como responsável pelo projeto, quero adaptar sua apresentação às capacidades de cada loja/canal, para servir ao visitante sem presumir que todos os destinos funcionam como itch.io.

**Why this priority**: Reutilização entre destinos faz parte do propósito confirmado.

**Independent Test**: Derivar duas representações dos mesmos fatos, uma itch.io e outra fictícia em texto simples; comparar claims, campos e omissões sem publicar.

**Acceptance Scenarios**:

1. **Given** público, idioma e canal selecionados, **When** preparo o texto, **Then** registro essas escolhas e separo descrição, metadados, mídia e ações nativas do destino.
2. **Given** controles nativos de acesso, **When** adapto, **Then** aproveito suas capacidades sem controles fictícios ou repetição inútil; instruções não óbvias e requisitos pertinentes permanecem claros.
3. **Given** destino sem personalização/conteúdo enriquecido, **When** adapto, **Then** texto simples conserva significado e ressalvas essenciais.
4. **Given** limites reais com fonte/data ou capacidades fictícias declaradas, **When** componho, **Then** respeito esses limites; cenário fictício não recebe alegação de compatibilidade com loja real.
5. **Given** público de jogadores ou de avaliadores profissionais e orientação de voz do autor, **When** seleciono conteúdo, **Then** priorizo experiência/acesso ou contribuição/prova conforme finalidade, preservando a personalidade escolhida, sem estética ou sequência narrativa únicas.

---

### User Story 3 - Revisar e atualizar sem perder procedência (Priority: P2)

Como revisor, quero reconhecer rascunhos, decisões e conteúdo desatualizado, para corrigir a apresentação sem apagar evidências nem confundir aprovação com publicação.

**Why this priority**: Evita que redação antiga contradiga o audit ou pareça execução verificada.

**Independent Test**: Corrigir/aceitar um rascunho, mudar evidência material/baseline e conferir histórico/invalidação; avaliar mídia bloqueada separadamente.

**Acceptance Scenarios**:

1. **Given** rascunho, **When** aceito/corrijo/rejeito, **Then** a decisão registra escopo, responsável/data quando conhecidos e motivo, preservando versão anterior; aprovação não aumenta confiança factual.
2. **Given** mudança material de baseline/evidência, **When** retomo, **Then** a representação afetada fica stale até revalidação e perde aprovação vigente.
3. **Given** mídia sem permissão de cópia, **When** reviso, **Then** bloqueio a ação dependente e preservo texto seguro quando o canal permitir; crédito/publicação prévia não autorizam nova ação.
4. **Given** resultado sem medição/runtime não verificado, **When** reviso, **Then** não afirmo impacto ou funcionamento por inferência; evidência externa fornecida conserva condições e limites.
5. **Given** rascunho aprovado, **When** encerro preparação, **Then** aprovação continua distinta de aplicação, sem enviar ou alterar conteúdo externo.

---

### User Story 4 - Reutilizar o método com privacidade (Priority: P2)

Como mantenedor, quero um método generalizado que reutilize contratos e seja validável sem fontes pessoais/serviços externos, para atender novos produtos sem carregar um catálogo particular.

**Why this priority**: Torna o modelo uma capacidade do framework.

**Independent Test**: Seguir instruções locais com exemplos fictícios sem acervo privado, conta externa ou execução de projeto; conferir fonte única e privacidade.

**Acceptance Scenarios**:

1. **Given** contratos da 001, **When** uso o modelo, **Then** reutilizo evidências, roster, tecnologias, claims e narrativas existentes, sem outra ficha factual.
2. **Given** material importado, **When** retiro do escopo ativo, **Then** preservo originais/procedência antes da remoção, registro correspondência e mantenho trabalho não relacionado.
3. **Given** método compartilhável, **When** outro usuário o utiliza sem fontes privadas, **Then** encontra instruções suficientes e exemplos fictícios, sem catálogo/jogo obrigatório.
4. **Given** alvo auditado, **When** preparo apresentação, **Then** não escrevo/executo no alvo nem gero catálogo, preview, exportador, relatório companheiro ou publicação automática; derivados de aplicação explicitamente solicitados permanecem privados e ligados ao relatório único.
5. **Given** documentação compartilhável com exemplo real ou decisão particular, **When** neutralizo, **Then** o método permanece utilizável com exemplos fictícios, IDs e evidências de implementação preservados, sem alterar o material privado.

### User Story 5 - Consolidar e reutilizar uma aplicação validada (Priority: P1)

Como responsável, quero que decisões e aplicação aprovadas acompanhem o audit original, para reaproveitar um formato sem duplicar fatos nem impor a identidade de um jogo.

**Independent Test**: Cenário documental controlado seleciona um audit externo, incorpora material editorial único antes da retirada da cópia e aplica o esqueleto a um projeto fictício sem dependência privada.

**Acceptance Scenarios**:

1. **Given** original e cópia editorial, **When** consolido, **Then** fatos/IDs/histórico e acréscimos úteis permanecem recuperáveis no original antes da remoção da cópia.
2. **Given** texto e visual validados pelo autor, **When** registro, **Then** idioma, versão, configurações e decisão têm origem recuperável, sem publicar nem repetir testes da página.
3. **Given** outro projeto, **When** uso o modelo, **Then** escolho blocos sustentados, ordem e identidade próprias, omitindo dimensões sem dados sem inventar conteúdo.

### User Story 6 - Chamar a apresentação diretamente (Priority: P1)

Como autor, quero pedir a apresentação itch.io com um relatório indicado ou disponível na conversa, sem preencher o modelo manualmente nem repetir a investigação.

**Why this priority**: Torna o método existente acessível por uma entrada específica.

**Independent Test**: Usar somente audit fictício e contextos explícito, único, ambíguo e indisponível; conferir seleção e lacunas sem acessar alvo/site.

**Acceptance Scenarios**:

1. **Given** caminho explícito e outro audit na conversa, **When** chamo a apresentação, **Then** o caminho explícito prevalece; falha de acesso não causa substituição silenciosa.
2. **Given** nenhum caminho e audit inequívoco recém-gerado/selecionado, **When** chamo, **Then** a apresentação usa esse relatório sem pedir repetição ou preenchimento do modelo.
3. **Given** fonte ambígua/inacessível/insuficiente, **When** preparo, **Then** peço só identificação/dados essenciais e mantenho lacunas, sem reaudit automático ou conteúdo inventado.
4. **Given** texto ou HTML/CSS solicitados, **When** entrego, **Then** formato e idioma seguem o pedido, derivados privados e decisões ficam ligados ao original; proposta não vira aprovação.
5. **Given** audit concluído sem pedido de composição, **When** encerro, **Then** posso indicar o próximo comando, sem executar a apresentação automaticamente.

### Edge Cases

- Audit sem versão/baseline: registrar lacuna; não considerar piloto factual validado nem substituir por ficha secundária.
- IDs ausentes em legado: conservar rota recuperável e necessidade de migração pelo contrato existente; não inventar evidência.
- Fonte conflitante/removida/inacessível: preservar limite; omitir/qualificar claim afetada.
- Campo essencial do canal ausente: bloquear aquele campo/representação; versões independentes continuam revisáveis.
- Limite de texto não comporta ressalva essencial: reformular/omitir claim ou bloquear campo, sem esconder limite factual.
- Mídia sem autorização: usar texto seguro quando permitido, sem imagem enganosa.
- Crédito incompleto: distinguir participantes identificados de equipe completa; não deduzir projeto solo.
- Mudança editorial: registrar decisão sem elevar confiança; mudança material invalida aprovação.
- Divergência com site: registrar diferença sem presumir publicação da revisão local ou sobrescrever destino.
- Segunda loja indefinida: cenário fictício valida genericidade, não compatibilidade real.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O modelo MUST consumir audit identificado por produto, versão, baseline e estado; lacuna de origem MUST ser explícita, sem aceitar ficha secundária como substituto automático.
- **FR-002**: Facts MUST permanecer na fonte existente; seleção e representações MUST integrar o mesmo registro canônico, sem fonte factual paralela.
- **FR-003**: Cada afirmação material MUST conservar rota interna recuperável aos findings, claims, contribuições, tecnologias, narrativas e evidências pertinentes, com natureza, limites e atualidade.
- **FR-004**: Seleção MUST registrar público, canal, idioma, finalidade, itens selecionados/omitidos e lacunas; orientações de voz e referências criativas fornecidas pelo autor MUST conservar origem e estado; escolhas desconhecidas/provisórias MUST manter esse estado.
- **FR-005**: Apresentação MUST permitir identidade/premissa, experiência/objetivo, contexto/estado, acesso/controles/requisitos pertinentes, créditos, mídia e limitações úteis conforme evidência/público.
- **FR-006**: Conteúdo técnico, decisões/desafios e resultados MUST ser opcionais/proporcionais; ordem, redação e profundidade MUST ser flexíveis, sem história, métrica, vídeo, número fixo de blocos ou estética obrigatórios. Redação MUST preservar a voz/personalidade orientada pelo autor, incluindo tom, vocabulário, humor e atmosfera quando pertinentes; recomendações de indústria MUST orientar clareza e fidelidade sem impor estilo universal ou características sem suporte.
- **FR-007**: O modelo MUST distinguir jogadores de avaliadores profissionais, priorizando experiência/acesso ou contribuição/prova; stack coletiva MUST NOT virar experiência individual presumida.
- **FR-008**: Redação MUST preservar atribuição individual, compartilhada, integração, relato e desconhecido; crédito isolado MUST NOT provar autoria exclusiva ou equipe completa.
- **FR-009**: Impacto, resultado, execução e compatibilidade MUST NOT ser afirmados sem suporte apropriado; resultados externos fornecidos MUST conservar origem, snapshot, cenário, ambiente e limites conhecidos/desconhecidos.
- **FR-010**: Canal real MUST ter capacidades/limites com fonte/data; canal fictício MUST declarar suas capacidades; ausência de prova MUST impedir alegação de compatibilidade real.
- **FR-011**: Representação MUST distinguir descrição, metadados, mídia e ações nativas pertinentes, evitando controles fictícios e instruções redundantes sem utilidade.
- **FR-012**: Texto simples MUST ser alternativa quando conteúdo enriquecido estiver indisponível, conservando significado/ressalvas essenciais.
- **FR-013**: MVP MUST incluir adaptação itch.io fundamentada em documentação oficial datada e segunda representação fictícia com capacidades explícitas, derivadas dos mesmos fatos.
- **FR-014**: Texto candidato ao público MUST excluir IDs internos, segredos e marcadores de trabalho; ressalvas necessárias MUST permanecer inteligíveis.
- **FR-015**: Mídia MUST conservar claim demonstrada, origem, versão/era, atribuição e permissão por ação; bloqueio MUST ser separado da prontidão de texto seguro.
- **FR-016**: Representações MUST começar em rascunho; aceitar/corrigir/rejeitar MUST registrar escopo, responsável/data quando conhecidos, motivo e versão anterior, sem elevar confiança factual.
- **FR-017**: Mudança de baseline, evidência, seleção ou redação material MUST invalidar aprovação afetada e marcar dependências stale até revisão/revalidação.
- **FR-018**: Prontidão editorial, execução externa e estado público observado MUST permanecer independentes; aprovação MUST NOT equivaler a publicação/runtime/permissão jurídica.
- **FR-019**: Preparação MUST NOT executar código/builds/jogos/testes/profiler de alvos, escrever neles, iniciar validação dinâmica ou alterar/enviar conteúdo externo.
- **FR-020**: Capacidade MUST reutilizar método/contratos locais da 001, ser stack-neutral e funcionar sem Notion, conta externa, projeto ou catálogo pessoal obrigatórios.
- **FR-021**: Audit MUST manter um único relatório Markdown por produto, incluindo rascunhos/rastreabilidade, no destino existente explicitamente selecionado ou no destino padrão. MUST NOT gerar catálogo, ficha paralela, preview, exportador, backend ou relatório companheiro. Derivados de aplicação solicitados pelo usuário MUST permanecer privados, vinculados à versão editorial e sem autoridade factual própria.
- **FR-022**: Regras/exemplos compartilháveis MUST ser generalizados/fictícios; fontes particulares MUST permanecer privadas, opcionais e fora da distribuição.
- **FR-023**: Migração MUST identificar cada arquivo, origem conhecida/desconhecida, preservação e decisão antes da retirada, preservando trabalho não relacionado e histórico Git.
- **FR-024**: Requisitos/tarefas antigos MUST ter correspondência ou motivo de retirada; conclusões antigas MUST NOT ser herdadas como aceitação da revisão 2.
- **FR-025**: Seleção/importação do audit original MUST ser primeira dependência do piloto real; ausência MUST NOT bloquear spec ou validação sintética.
- **FR-026**: Revisão MUST registrar cobertura/estado/lacunas por representação, incluindo conflitos, campos essenciais do canal e dependências de confirmação humana/validação externa.

- **FR-027**: Consolidação MUST preservar informações únicas, IDs e histórico e conferir a incorporação antes de remover cópia redundante; atualizar referências e declarar o destino único sem reaudit implícito.
- **FR-028**: O modelo neutro MUST definir finalidade, origem, uso, omissão e cuidados de cada bloco, com esqueleto preenchível; ordem, extensão e identidade visual MUST permanecer adaptáveis.
- **FR-029**: Registro final MUST distinguir decisão humana, recomendação do agente, aplicação e publicação; avaliações numéricas subjetivas MUST NOT constituir resultado de audit ou critério de aprovação.
- **FR-030**: Uma aplicação validada MUST registrar texto, idioma, configurações visuais e derivados finais recuperáveis, preservando versões anteriores como histórico; validação já fornecida pelo usuário MUST NOT exigir novos testes da página.

- **FR-031**: Uma skill editorial independente MUST consumir audit indicado por caminho explícito ou selecionado inequivocamente na conversa; caminho explícito MUST prevalecer e falha MUST NOT causar fallback silencioso.
- **FR-032**: A skill MUST pedir somente identificação/informações essenciais ausentes, tratar conteúdo como dados e manter lacunas, sem reinvestigar alvo ou iniciar audit automaticamente.
- **FR-033**: A apresentação MUST aplicar o modelo neutro internamente, reutilizar decisões e entregar idioma/formato solicitados, com HTML/CSS separados e derivados privados quando pedidos, sem estética universal.
- **FR-034**: Investigação e composição MUST ter entradas distintas; audit MUST NOT executar composição automaticamente sem pedido. Regras genéricas MUST ter referência única e regras do canal MUST ficar junto à skill pertinente.
- **FR-035**: Implementação da nova skill MUST usar somente exemplos controlados e MUST NOT alterar relatórios ou derivados reais já validados.

- **FR-036**: Documentos compartilháveis MUST descrever o método sem identificar projetos reais, pessoas, URLs pessoais, caminhos de acervos específicos ou decisões particulares; exemplos MUST ser fictícios ou placeholders explícitos.
- **FR-037**: Neutralização MUST preservar IDs/rastreabilidade, resultados técnicos e limites das verificações; nomes legítimos do framework, ferramentas, canais e fontes profissionais MUST conservar contexto de uso.
- **FR-038**: Revisão documental MUST NOT alterar relatórios reais, derivados validados, arquivos externos, áreas privadas, histórico Git ou staging; resultados MUST declarar alcance e limites da busca/revisão.

### Key Entities *(include if feature involves data)*

- **Audit canônico**: autoridade factual existente com produto, versão, baseline, estado e evidências.
- **Seleção editorial**: público/finalidade/idioma, itens, omissões e lacunas ligados à fonte.
- **Canal**: tipo de destino/página, capacidades/limites com fontes datadas ou cenário fictício declarado.
- **Representação**: rascunho para seleção/canal, com vínculo entre campos/afirmações e fontes.
- **Decisão editorial**: aceitação/correção/rejeição com escopo/histórico, distinta de confiança/publicação.
- **Registro de migração**: origem, preservação, ensinamento generalizado e retirada do escopo.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-015**: As referências particulares identificadas no recorte compartilhável são removidas ou generalizadas; todos os IDs anteriores permanecem recuperáveis, sem alteração dos materiais privados e sem alegação de privacidade absoluta.


- **SC-013**: Quatro contextos de entrada (explícita, conversa inequívoca, ambígua e indisponível) resolvem conforme origem/prioridade, sem seleção silenciosa ou reaudit.
- **SC-014**: Todas as referências locais após a separação resolvem, sem duplicação do perfil de canal; artefatos reais selecionados para preservação permanecem com hashes idênticos.


- **SC-011**: Consolidação conserva 100% das informações únicas verificadas, elimina a cópia concorrente e identifica o relatório único e os derivados finais.
- **SC-012**: Cada bloco do modelo tem finalidade/origem/uso/omissão/cuidados; o esqueleto pode ser preenchido sem dados privados nem estética obrigatória.


- **SC-001**: 100% das afirmações materiais dos cenários têm origem recuperável e qualificadores coerentes; zero aumentos de confiança por redação/aprovação.
- **SC-002**: Duas representações dos mesmos fatos, itch.io e cenário fictício em texto simples, têm zero contradições e mantêm todas as ressalvas essenciais das claims incluídas.
- **SC-003**: Cenário com pouca evidência termina com apresentação curta revisável e lacunas explícitas, sem história/resultado/contribuição/mídia inventados.
- **SC-004**: Cenários de autoria compartilhada/desconhecida e resultado sem medição têm zero promoções a exclusividade, experiência presumida ou impacto comprovado.
- **SC-005**: Cenário com mídia sem permissão bloqueia apenas ações/campos dependentes e conserva texto seguro quando permitido.
- **SC-006**: Mudança material invalida todas as aprovações afetadas e preserva origem/versão anterior; nenhuma representação stale é tratada como pronta.
- **SC-007**: Cada produto conserva exatamente um relatório factual persistente; derivados solicitados têm versão/origem recuperáveis, sem relatório concorrente, execução de alvo ou envio/publicação externos.
- **SC-008**: Migração registra decisão/preservação para 100% dos arquivos particulares selecionados, com zero perdas observadas e zero alterações no trabalho não relacionado identificado.
- **SC-009**: Método/exemplos compartilháveis têm zero identificadores particulares do acervo e podem ser seguidos sem fontes privadas.
- **SC-010**: Revisão guiada localiza público, canal, estado, lacuna principal, orientações de voz com origem/estado e rota de evidência de cada representação sem segunda fonte factual; registra como a voz foi preservada ou adaptada, com observações/limites sem alegar pesquisa de usuários.

## Assumptions

- Documentação em português; idioma público é parâmetro, não prova de idioma/suporte do produto.
- Perfis pessoais e catálogos particulares ficam fora das entregas; nenhum projeto é exemplo obrigatório.
- Personalidade editorial segue orientações/referências do autor; sem brief, sugestões de voz permanecem provisórias, sem atribuir intenção criativa ao autor. Práticas recomendadas são datadas e contextualizadas, distintas de regras obrigatórias do destino.
- Audit real será selecionado antes do piloto; cenário fictício permite validar o método independentemente.
- Segunda loja real exige seleção/pesquisa; cenário fictício comprova apenas genericidade nas capacidades declaradas.
- Feature 001 governa evidência/confiança/IDs/roster/tecnologias/narrativas; a 002 acrescenta forma editorial.
- Leitura privada autorizada permite preparação local, sem autorizar divulgação/publicação.
- Relatório único é requisito vigente; emenda constitucional 4.0.0 autoriza destino existente e derivados privados solicitados sem segunda autoridade factual.
- [Migração](migration.md) preserva histórico; a implementação de 2026-10-07 registra conclusão das tarefas com evidências novas, sem herdar conclusões antigas. Rascunhos não aceitos permanecem drafts; versões aceitas exigem decisão humana recuperável no respectivo relatório.
