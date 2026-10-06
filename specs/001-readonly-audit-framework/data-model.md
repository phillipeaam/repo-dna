# Data Model: Auditoria e Source of Truth Markdown

Este modelo descreve os dados que o processo precisa avaliar e consolidar. Não implica persistir JSON ou gerar arquivos separados.

## Entidades

| Entidade | Campos essenciais | Relações |
|---|---|---|
| **Produto** | Nome canônico, aliases, contexto, slug Markdown, estado, links públicos verificados | Agrega um ou mais repositórios; possui um único arquivo canônico |
| **Repositório-alvo** | Caminho selecionado/canônico, nome/remote quando disponíveis, papel no produto, snapshot/ref, estado local, limite de leitura | Pertence a um produto por seleção explícita ou relação evidenciada |
| **Baseline** | Identidade do alvo, HEAD/branch/refs acessíveis, instante, conteúdo/inventário verificável, alterações locais, método/versão, estado de enforcement do host | Sessão usa uma ou mais; findings referenciam sua baseline |
| **Sessão de auditoria** | Data, método/versão, etapas, cobertura, checkpoints, término/falha, enforcement informado e estado de preservação (`verified`, `observed_unchanged`, `changed`, `partial`, `inconclusive`) | Atualiza o registro canônico; não é arquivo entregue independente |
| **Etapa** | ID, pré-condição, entrada, domínio/aplicabilidade, estado, resultado, motivo de falha | Pertence a uma sessão: preparação, A1, B1–B4, consolidação, reconciliação, revisão |
| **Fonte/evidência** | ID estável, origem/autoria quando conhecida, datas relevantes, repo/baseline/snapshot/versão, localização recuperável, natureza (direta/secundária/relato etc.), atualidade, divulgação, limites e proveniência | Sustenta findings/claims; adequação é avaliada para cada dimensão da afirmação, sem hierarquia universal |
| **Finding/conclusão** | ID, fato/inferência/relato/conflito, descrição, estado, confiança justificada, limites | Cita evidências; alimenta sistema, contribuição, release ou claim |
| **Sistema/feature** | Nome, comportamento/limite, estado de implementação, repo/snapshot, dependências | Possui evidência e ownership separados |
| **Identidade/contribuição** | Identidades observadas/candidatas, sistema, tipo de contribuição, ownership (pessoal/compartilhado/desconhecido), confiança e wording | Conecta pessoa/claim a sistema e diffs |
| **Release/artefato** | Evento/deadline/timezone, commit/ref candidato, binário/hash/version quando disponível, destino, estado de cada elo | Cadeia de procedência com confiança por relação |
| **Claim** | Afirmação, audiência, estado, wording, evidência e caveat | Referencia findings; mídia pode demonstrar produto sem provar ownership |
| **Asset/mídia** | Origem/criador/licença/crédito, integração, era/snapshot, uso, permissões e legenda | Sustenta comportamento/release; não concede autoria/licença por inferência |
| **Questão/conflito** | Tema, afirmações/fontes em conflito, estado, evidência necessária, bloqueio/resolução | Uma seção atual, ligada ao histórico quando muda |
| **Cobertura** | Domínio, aplicabilidade, estado, escopo, motivo/fallback | Um resultado por domínio da matriz |
| **Registro canônico** | `schema_version`, estado/baseline, resumo humano, facts atuais, claims, apêndices, índice e histórico | Um registro persistente Markdown por produto; versão identificada e migração no mesmo arquivo |

## Entidades complementares — US10/US11

| Entidade | Campos essenciais | Relações e validações |
|---|---|---|
| **Brief editorial** | cargos/público, idioma, canais, sinais prioritários, restrições, decisões visuais, origem, estado (`confirmed`, `provisional`, `historical`, `conflicting`) | Opcional por produto; cada campo sem suporte permanece desconhecido; não define identidade por padrão. |
| **Contexto do projeto** | profissional/comercial, independente, jam, técnico ou desconhecido; equipe, período, plataforma | Descreve o projeto e não determina papel editorial nem título profissional. |
| **Papel editorial** | Featured candidate, Strong supporting, Supporting/Technical, Archive/Playground ou unclassified; rationale; decisão humana/recomendação provisória | Recomendação comparativa referencia inventário explicitamente selecionado; ausência desse inventário proíbe ranking global. Não remove o projeto. |
| **História de engenharia** | contexto, ownership, problema, restrições, abordagem, trade-offs, evidência, resultado, reflexão, estado de suporte | Campos podem ficar ausentes; cada claim factual referencia finding/evidência e limite. Relato pessoal é marcado como tal. |
| **Ativo/pacote editorial** | ativo desejável, presença, origem/proveniência, comportamento demonstrado, permissão/atribuição, claim, lacuna e prioridade | Pacote é proporcional ao papel; checklist Featured é meta recomendada e não gate. Asset sem permissão não se torna claim/uso aprovado. |
| **Registro profissional/recomendação** | texto exato, autor, fonte, contexto, período, permissão, relação com contribuição | Recomendação é testemunho atribuído e não prova automática de autoria, cargo ou impacto. Título formal e responsabilidade observada são dimensões separadas. |
| **Observação de superfície** | URL/artefato, página, viewport, estado de acesso, interação realmente observada, evidência, dimensão, limite | Somente leitura e sem autenticação/submissão/alteração de estado. Dimensão indisponível recebe `not_observed`. |
| **Finding de superfície** | dimensão, nota 1–5 opcional, critério, evidência/localização, impacto, prioridade P0–P3, esforço, risco/dependência, confiança, recomendação | Nota é diagnóstico profissional; finding aponta observação real. Lacunas são explicitadas sem alegação de teste/certificação/conversão. |

## Entidades complementares — US12/US13

| Entidade | Campos essenciais | Relações e validações |
|---|---|---|
| **Vocabulário/tag** | ID opcional do conceito, chave estável `faceta:slug`, faceta, rótulo, aliases, definição, relações hierárquicas e versão do vocabulário | Alias resolve a uma chave canônica; conceitos distintos não são fundidos por nome semelhante. Vocabulário é local, sem dependência de RDF/registry. |
| **Registro técnico (`T-###`)** | Categoria, nome/namespace/ecossistema, tags, finalidade, relevância demonstrada, versões conhecidas, resumo e temporalidade | Descreve linguagem, engine/framework, package, serviço, ferramenta, prática, arquitetura/padrão, técnica/provedor/modelo de IA, codec/formato. Aponta para uma ou mais ocorrências. |
| **Ocorrência (`O-###`)** | `T-###`, repositório/componente, baseline, caminho/símbolo/configuração/asset, sistema, finalidade, estado/natureza, contexto, origem, versões, exercício, atualidade, evidências e limites | Ocorrência específica, não sinônimo do conceito. Pode ser declarada, resolvida, instalada, candidata, observada ou ativa em contextos diferentes. |
| **Identidade/contribuidor (`P-###`)** | Tipo pessoa/grupo/bot/ferramenta de IA, nome/alias autorizado, fonte, resolução de identidade, janela observada, completude e divulgação | Aliases não resolvidos permanecem separados/pendentes. Nome civil, contato ou perfil externo só quando necessário e autorizado. Bot/agente não é pessoa. |
| **Contribuição (`K-###`)** | Tipo de trabalho, sistema/feature, repo/baseline/intervalo, estado individual/compartilhado/relatado/desconhecido, autoria, wording e fontes | Reutiliza evidências/findings; inclui código, design, arte, áudio, QA, revisão, documentação, acessibilidade/localização, build e operação quando evidenciados. |
| **Vínculo de experiência** | `P-###` + `K-###` + `O-###`/`T-###`, papel na ocorrência, prova e limites | Relação explícita pessoa → contribuição → tecnologia/sistema. Não herda stack da equipe nem duplica contribuição compartilhada. |
| **Perfil de consulta** | Finalidade/filtro e inclusão de estados, datas, escopo e prova mínima | Projeção efêmera do registro Markdown; não vira banco, catálogo/índice paralelo nem novo deliverable. |
| **Reconstrução técnica / destaque (`R-###` / `H-###`)** | Claim/síntese candidata; tipo de conclusão; contribuição/sistema; evidências favoráveis e contrárias; baseline/escopo; confiança e justificativa; limitações; alternativas; estado editorial (`draft`, `accepted`, `corrected`, `rejected`) e proveniência | Registra uma interpretação derivada de findings/claims e nunca substitui suas fontes. `H-###` pode ser hipótese de narrativa; zero destaques também é válido. R/H são IDs locais do documento, nunca IDs de fonte ou prova. |

### Entidades complementares — US14

| Entidade | Campos essenciais | Relações e validações |
|---|---|---|
| **Reconstrução técnica (`R-###`)** | pergunta/tema, claim candidata, sistema/feature, contribuição(s), escopo/baseline e janela, tipo (`fact`, `inference`, `personal_account`, `hypothesis`, `conflict`, `unknown`), confiança (`high`, `medium`, `low` ou sem nota quando sem suporte) e rationale, limites, alternativas, estado de revisão e necessidade de verificação | Sempre referencia findings/claims anteriores e `E-###` recuperáveis; cada relação fonte→claim identifica dimensão sustentada e adequação da fonte para essa dimensão, separadas da confiança da claim. Hipótese é interpretação editável, jamais fonte ou conclusão factual. Desconhecido/conflito podem ser resultados finais válidos. |
| **Destaque de engenharia (`H-###`)** | texto conciso em prosa livre, público/contexto se fornecido, relações a `R-###`/`K-###`/sistema, claims/evidências citadas, gaps e estado editorial (`draft`, `accepted`, `corrected`, `rejected`) | Zero a três por síntese, sem campos/headings/ordem obrigatórios. Todo claim factual material preserva evidência, baseline e limite. Alteração editorial não apaga finding ou texto anterior com procedência. |
| **Relação de suporte evidencial** | evidência/localização, baseline/escopo, dimensão suportada (`authorship`, `behavior`, `decision_or_intent`, `collaboration`, `validation`, `outcome`), relação (`supports`, `limits`, `contradicts`, `context_only`) e justificativa | Força é específica à dimensão: commit pode sustentar metadado de autoria registrada, mas não decisão/colaboração/resultado por si só. |
| **Procedência e adequação da fonte (US14)** | origem/canal e autor/publicador quando conhecidos; datas disponíveis; baseline/snapshot/versão; localização recuperável; natureza direta/secundária/relato/outro tipo justificado; atualidade; relação com outras fontes e corroboração independente quando disponível; adequação à dimensão da claim | Metadados ausentes ficam `unknown`. Procedência e adequação da fonte não são a confiança da claim nem formam score/ranking global. Hashes e cópias preservadas não são obrigatórios. Dados pessoais ou privados desnecessários são omitidos/mascarados conforme privacidade. |

### Regras de serialização dos IDs US12/US13

- IDs `T-###`, `O-###`, `P-###` e `K-###` são únicos dentro do documento canônico e nunca reutilizados para outra entidade; atualizações preservam IDs históricos válidos.
- Todo `O-###` referencia um `T-###`, repo, baseline, localização recuperável, sistema/finalidade, contexto, origem, atualidade e pelo menos uma evidência ou motivo explícito de cobertura sem evidência.
- Todo vínculo de experiência referencia `P-###` e `K-###`; para indicar domínio tecnológico também referencia `O-###` ou `T-###` e evidência que sustenta a relação. Ausência de ligação individual não é inferida da presença da tag no produto.
- Alias mapeia para uma chave canônica somente quando não ambíguo. Em conflito, preservar candidatos separados com estado `unresolved` até existir evidência/decisão.
- Em migração para 2.1.0, manter baseline anterior, vocabulário e mapeamento de cada campo recuperável; omissões e incompatibilidades permanecem como lacunas explícitas.

### Campos/estados técnicos

- Reutilizar a natureza existente `fact`, `inference`, `personal_account`, `conflict`, `unresolved` e os estados `installed`, `possible_use`, `observed_use`, `active_configuration`. US14 acrescenta `hypothesis` como status provisório de interpretação, `unknown`/`not_observed` para ausência de conhecimento e estados editoriais de draft/revisão; hipótese não é fonte nem autorização para promover um claim.
- `declared` e `resolved` qualificam declaração/resolução da dependência; não substituem estado de uso. `installed` exige prova local de disponibilidade material instalada, não só manifest/lock. Versão declarada, resolvida, observada e release são distintas.
- Relação de dependência (`direct`, `transitive`, `peer`, `optional`, `vendored`, `bundled`, `unknown`) e contexto (`runtime`, `editor`, `build`, `test`, `ci`, `documentation`, `sample`, `asset_pipeline`, `unknown`) são eixos independentes; usar apenas os valores justificáveis no ecossistema.
- Origem distingue implementação própria, implementação/asset de terceiro, integração própria de terceiro, gerado e desconhecido.
- Atualidade indica baseline atual, histórica/removida, desconhecida, stale ou revalidada; ocorrência stale não entra em filtro atual.
- Codec, contêiner, extensão, configuração de importação e metadata de stream são dados independentes. Sem fonte suficiente, codec é `unknown`.
- Assistência IA distingue configuração/instruções, relato, declaração de commit, atividade correlacionada e ausência de sinais; integração no produto, técnica, provedor e modelo têm registros próprios.
- Padrão de software guarda participantes, relações, comportamento, propósito/escopo e se é estrutura observada, inferência, declaração, implementação própria ou integração de terceiros.
- Pessoa tem janela observada de contribuições; intervalo de emprego/título formal usa a entidade profissional já existente e não é inferido da primeira/última aparição Git.

## Vocabulários controlados

- **Cobertura**: complete, partial, not_observed, not_applicable, unavailable, not_verified.
- **Conclusão**: fact, inference, personal_account, conflict, unresolved.
- **Conclusão para reconstrução US14**: fact, inference, personal_account, hypothesis, conflict, unknown/not_observed. Preservar `unresolved` em registros existentes; `hypothesis` é candidata explicativa e exige relações a suporte, contraevidência, alternativa, limites e confiança justificada.
- **Estado de destaque**: draft, accepted, corrected, rejected. Estado humano/editorial não altera o tipo nem a força da evidência citada.
- **Sistema**: implemented, partial, prototype, planned_only, not_found_in_scope.
- **Contribuição**: individually_verified, strongly_supported_shared, shared, unknown, unverified.
- **Tecnologia**: installed, possible_use, observed_use, active_configuration.
- **Relação/contabilidade de package**: direct, transitive, peer, optional, vendored, bundled, unknown; versões e contextos permanecem campos separados, não estados de conclusão.
- **Atualidade técnica**: current, historical/removed, unknown, stale, revalidated; só ocorrência current/revalidated elegível ao perfil padrão.
- **Atribuição de pessoa**: individual, shared, declared, unknown; tipo de contribuição/crédito, fonte e limite também devem ser registrados.
- **Divulgação de identidade/claim**: permitted, restricted, unknown, com origem/escopo quando disponível; desconhecido não equivale a permissão.
- **Runtime**: static_fact, static_risk, measured, not_measured.
- **Release**: exact, strongly_supported, bounded_range, unresolved.
- **Claim**: safe, qualified, internal_only, unsupported, rejected.
- **Publicação**: complete, complete_with_conditions, incomplete_blocking, incomplete_nonblocking, optional.
- **Questão**: resolved, partially_resolved, open_blocking, open_nonblocking, closed_with_reason.
- **Etapa**: pending, in_progress, complete, partial, blocked, not_applicable.

“Confiança” descreve suporte evidencial, não certeza subjetiva nem probabilidade, e requer justificativa baseada em tipo/direção da fonte, corroboração, contradições e escopo: `high` = suporte direto adequado ao escopo sem contradição material aberta; `medium` = suporte parcial/indireto ou limitado, sem alternativa igualmente sustentada; `low` = suporte fraco/ambíguo ou alternativas igualmente plausíveis. Sem suporte suficiente, registrar `unknown`/`unsupported` sem nota, nunca `low` por padrão. Volume de atividade não estabelece confiança de autoria.

## Relações e invariantes

1. Um produto possui exatamente um arquivo persistente analysis-output/<safe-slug>.md.
2. Agrupar vários repositórios exige relação indicada pelo usuário ou evidência confirmada; sucessores mantêm produtos separados.
3. Todo finding de repositório registra repositório e baseline. Claims preservam linhagem até as fontes.
4. Existência de sistema, autoria, versão pública, medição runtime e permissão de mídia são dimensões independentes.
5. O Markdown referencia e sintetiza; não copia grandes arquivos de código.
6. O Markdown reúne evidência, índice e histórico necessários; não há relatório companheiro.
7. Intermediários, se necessários, são efêmeros, ficam fora do alvo e podem ser descartados.
8. Um finding atualizado não sobrescreve silenciosamente a história; estado atual e checkpoints superados permanecem distinguíveis.
9. Uma contribuição compartilhada mantém identidade estável entre repositórios e baselines; a linhagem alteração do pacote → versão → produto consumidor → release liga todas as evidências e a contribuição é contabilizada uma única vez.
10. Brief, classificação editorial, observação de superfície e recomendações são contextuais/opcionais e não alteram evidência técnica nem aprovação humana.
11. Uma avaliação de superfície ocupa uma seção do registro canônico do produto e não cria outro arquivo persistente.
12. Tags no índice apontam a T/O; ocorrências apontam a repo/baseline/sistema/evidências; links quebrados invalidam a checagem do registro.
13. Experiência individual exige vínculo sustentado P/K/T/O; presença no roster, manifest ou tag de projeto não cria vínculo automaticamente.
14. Um conceito técnico pode ter várias ocorrências com contexto/estado diferentes; o filtro deriva delas e não reduz o conceito a um único estado global contraditório.
15. A lista de pessoas declara fontes e cobertura; incompletude é permitida, mas não pode ser reportada como roster total comprovado.
16. Todos os registros são serializados e atualizados no Markdown canônico 2.1.0; metadados fora dele são temporários e descartáveis.
17. Cada reconstrução/destaque é projeção de findings, contribuições e fontes autorizadas; autoria, comportamento, decisão, colaboração, validação e consequência permanecem dimensões separadas.
18. Evidência de teste/configuração e resultado observado têm IDs/escopos distintos; resultados sempre indicam baseline/snapshot e cenário/ambiente conhecidos.
19. Ausência de memória, arquivo ou acesso externo não significa que o evento não aconteceu; usar `unknown`, `not_observed`, `unavailable` ou conflito conforme o motivo.
20. A sequência contexto→ownership→problema→restrições→abordagem→trade-offs→evidência→resultado→reflexão é checklist de investigação; o relatório pode omitir dimensões sem suporte e compor prosa em qualquer ordem.
21. Procedência/atualidade/independência da fonte, adequação por dimensão e confiança da claim são campos analíticos distintos; atributos não recuperáveis permanecem desconhecidos, sem reduzir automaticamente o valor nem promover a fonte.

## Ciclo de estados

### Privacidade e autoridade local

- **Procedência privada**: fontes originais, metadados e termos conhecidos; área `private-context/`, opcional, ignorada, fora do índice e da distribuição. Não é entregável de auditoria.
- **Mapa público do método**: tema, ensinamento generalizado, referência local recuperável e limites. Não contém identificadores de projetos privados ou links de páginas pessoais.
- **Revisão de compartilhamento**: superfícies `working_tree` e `index`, arquivo, regra, estado `pass`/`blocked`; diagnósticos não incluem valores encontrados. Uma superfície limpa não libera a outra.
- **Autoridade**: spec/constituição governam o produto; skill/runbooks/contratos locais aprovados governam a execução. Evidências externas opcionais respondem sobre o alvo, não alteram o método.

    prepared -> in_progress -> complete
                          -> partial
                          -> blocked

    complete/partial -> consolidation -> reviewed_for_handoff
    baseline_changed -> stale (revalidar findings afetados antes de retomar)

Bloquear é válido quando o alvo é ambíguo, o escopo não pode ser resolvido ou a baseline muda durante a sessão. Host sem enforcement comprovado limita a preservação e gera aviso, mas não bloqueia análise estática.
