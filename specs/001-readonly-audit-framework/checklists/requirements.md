# Specification Quality Checklist: Framework de auditoria readonly

**Purpose**: Validar completude e qualidade da especificação antes do planejamento.
**Created**: 2026-10-03
**Updated**: 2026-10-05
**Feature**: [spec.md](../spec.md)
**Marker Semantics**: [x] indica qualidade de requisitos revisada; não indica implementação concluída.

## Content Quality

- [x] No implementation details (languages, frameworks, APIs).
- [x] Focused on user value and business needs.
- [x] Written for non-technical stakeholders.
- [x] All mandatory sections completed.

## Requirement Completeness

- [x] No NEEDS CLARIFICATION markers remain.
- [x] Requirements are testable and unambiguous.
- [x] Success criteria are measurable.
- [x] Success criteria are technology-agnostic.
- [x] All acceptance scenarios are defined.
- [x] Edge cases are identified.
- [x] Scope is clearly bounded.
- [x] Dependencies and assumptions identified.

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria.
- [x] User scenarios cover primary flows.
- [x] Feature meets measurable outcomes defined in Success Criteria at the requirements level.
- [x] No implementation details leak into specification.

## Review Notes

Revisão de qualidade realizada nesta etapa por speckit-specify. Critérios descrevem resultados esperados; execução e comprovação pertencem à implementação.

- A spec preserva a ordem de seções do template resolvido pelo mecanismo local de overrides/presets.
- Nomes de pastas, skills e readonly são interfaces/restrições do produto solicitadas. Referências a domínios de stack descrevem o que analisar, sem selecionar a stack de implementação.
- A pesquisa técnica, as fontes locais e exemplos ficam em methodology.md, separadas dos requisitos WHAT/WHY.
- Para a extensão técnica de 2026-10-05, a pesquisa [research-tags-and-contributors.md](../research-tags-and-contributors.md) é material de entrada; decisões testáveis entraram na spec e nenhuma tecnologia pesquisada foi afirmada como usada por um alvo real.
- O template efetivo foi resolvido pelo contrato local: overrides → presets → extensões → core. Não existem overrides, presets ou extensões de template no checkout; aplica-se `.specify/templates/spec-template.md`. A feature existente já possui seu diretório/checklist, portanto esta execução atualiza-os sem criar feature nova ou alterar `.specify/feature.json`.
- Não há `.specify/extensions.yml`; nenhum hook before_specify/after_specify foi registrado ou exigido nesta execução.
- O status distingue o fluxo de auditoria existente da extensão de prontidão editorial/avaliação de superfície ainda pendente de planejamento e implementação; especificar não é aprovar publicação.
- FR-006 limita afirmações de preservação à cobertura observada; git status sozinho não basta.
- FR-007 e FR-041 resolvem a diferença entre B2 das fontes, que admite profiling, e o contrato readonly desta feature: medições existentes são dados; execução dinâmica é externa e não é iniciada nem orquestrada pelo framework.
- FR-010 e FR-060 adaptam reconciliação das fontes para leitura: nenhuma edição ou exclusão no Notion.
- FR-022 e FR-052 mantêm verificação por tipo de claim e confirmação pessoal identificada.
- FR-054 permite encerramento com lacunas não bloqueantes, evitando recuperação infinita.
- A extensão de 2026-10-05 acrescenta brief editorial configurável, classificação/curadoria proporcional, conteúdo de leitura rápida e aprofundada, estrutura de histórias, pacote de evidência por tier, carreira/social proof e readiness sem incorporar fatos de projetos pesquisados.
- A revisão opcional de site/protótipo é somente leitura, depende de seleção explícita, declara viewports/interações realmente vistos e trata notas como diagnóstico profissional; implementação, publicação, certificação e pesquisa com recrutadores continuam fora do escopo.
- Critérios de Featured são metas de pacote, não gates para arquivar/documentar; Archive/Playground permanece explorável. Quantidade de histórias é guiada por evidência, sem número obrigatório.
- Brief, estratégia, categorias e decisões de design permanecem configuráveis. Nenhum dado de caso específico, identidade profissional, layout ou decisão não aprovada das fontes privadas foi transferido como padrão universal.
- A constituição v2.0.0 governou a migração inicial; a atualização v3.0.0 flexibilizou o gate de host mantendo aviso e preservação qualificada. A data original de ratificação permanece TODO até confirmação.
- A extensão de tags menciona linguagens, engines, packages, ferramentas e codecs como categorias dos dados que o RepoDNA deve analisar; não seleciona tecnologia para implementar o framework. Nenhuma API, dependência de implementação ou mudança no alvo foi especificada.
- O foco técnico permanece consultável por leitores não técnicos: cada etiqueta exige finalidade, sistema, estado e rota até sua evidência. Jargão de tags serve a filtro; o relatório também deve permitir uma explicação em linguagem comum.
- FR-095–113 foram revistos quanto a critérios observáveis: estado de pacote/uso, suporte estrutural de padrão, classes de sinal IA, identidade e créditos, perfis, migração, execução local e privacidade. Os SC-028–037 cobrem essas jornadas e os casos negativos.
- A nova pesquisa não identifica tecnologias ou pessoas de qualquer repositório real; exemplos são explicitamente sintéticos. A especificação preserva atribuição qualificada e não calcula domínio, liderança ou percentuais de autoria.
- O complemento de 2026-10-05 acrescenta US14, FR-114–125 e SC-038–047 para reconstrução baseada em evidências, memória limitada, hipóteses qualificadas, rastreabilidade por afirmação, validação delimitada, síntese editorial flexível e calibração justificada da confiança. Critérios de qualidade continuam revisados no nível da spec; evidência de implementação ainda não foi produzida nesta etapa.
- Lacunas de planejamento resolvidas nesta sessão: FR-083 e contratos usam dimensões editoriais sem sequência mandatória; modelo/vocabulário formalizam reconstrução, hipótese e rascunho; metodologia, quickstart e tasks cobrem fontes, limitações e aceitação. Implementação e validação continuam pendentes.
- O escopo de fontes foi delimitado sem nova integração: issues/reviews/releases só contam quando locais, fornecidas ou públicas sem autenticação; não há pressuposto de acesso a Notion, serviço privado, credenciais ou memória completa.
- A rubrica de confiança da US14 define `high`/`medium`/`low` por suporte/direção da fonte, corroboração, contradições e escopo; ausência de suporte fica unknown/unsupported sem nota. T133/T134 verificam aplicação e SC-047 mede consistência sem percentuais.
- Clarificação original de 2026-10-04: host enforcement era gate obrigatório. Revisão posterior de 2026-10-04 substitui essa decisão: perfil sem prova avisa e permite análise estática, com preservação não verificada; ver FR-008 e SC-013 atualizados.
- Clarificação de 2026-10-04: há exatamente um entregável Markdown local por produto; relatórios HTML, JSON/CSV publicados, anexos e escrita/exportação para Notion estão fora do escopo.
- Clarificação de 2026-10-04: pessoas podem copiar o Markdown para Notion/Docs depois; agentes de IA são consumidores previstos. SC-006 mede respostas rastreáveis de IA, e SC-011 continua medindo o tempo para encontrar como iniciar.
- Não há extensions.yml nem hooks before_specify/after_specify registrados nesta checkout. A branch observada é feature/001-readonly-audit-framework.

## Acceptance Coverage Map

Os requisitos têm observações binárias ou estados explícitos verificáveis. Esta matriz vincula grupos ao cenário de uso, ao resultado observável e à medida de aceitação; o plano detalhará casos de validação executáveis.

| Requisitos | Jornada | Resultado observável | Critério |
|---|---|---|---|
| FR-001–002 | US1, US6 | Seleção inequívoca e agrupamento explícito | SC-007, SC-011 |
| FR-003–008 | US1 | Saída externa, baseline/comparação e divulgação do estado de proteção do host antes da inspeção substantiva | SC-001–002, SC-013 |
| FR-009–012 | US1, US5 | Instruções em fontes não governam fluxo; dados/exclusões/privacidade respeitados; nenhuma escrita externa | SC-001–002, SC-004–005 |
| FR-013–018 | US2, US7 | Etapas com contratos, combinação registrada, checkpoints e falhas declaradas | SC-003, SC-009, SC-011 |
| FR-019–021 | US2, US6 | Mapa de cobertura, base genérica e execução sem serviços | SC-003, SC-008 |
| FR-022–027 | US4 | Referências e confiança justificada; autoria e atividade separadas | SC-004–005 |
| FR-028–032 | US3, US4 | Matrizes, arquitetura, timeline e histórias com escopo/evidência | SC-003–006 |
| FR-033–036 | US2, US6 | Produção e especializações aplicáveis, stack instalada vs utilizada | SC-003–004, SC-008 |
| FR-037–041 | US4 | Runtime estático, medições e limites em estados distintos | SC-003–005 |
| FR-042–046 | US4, US6 | Cadeia de release/pacotes com força por relação e limites temporais | SC-004–005, SC-007 |
| FR-047–054 | US5 | Procedência, ações de mídia, claims e bloqueios independentes | SC-004–005, SC-010 |
| FR-055–058 | US3 | Página humana, apêndices e única autoridade por tema | SC-006–007 |
| FR-059–061 | US5, US6 | Reconciliação rastreável, produtos distintos preservados e contribuição compartilhada sem dupla contagem | SC-004, SC-007 |
| FR-062–063 | US3, US4 | Talking points sem invenção e evidências recuperáveis | SC-004–006 |
| FR-064–066 | US7 | Versões/migrações e atualização controlada | SC-007, SC-009, SC-012 |
| FR-067–068 | US1–US7 | Handoff com cobertura, preservação e gates explícitos | SC-001–010, SC-013 |
| FR-069–070 | US2, US7 | Orientação do framework e capacidades legadas reconciliadas | SC-011–012 |
| FR-071–077 | US8, US9 | Privacidade de pesquisa, método local como autoridade e independência das fontes privadas | SC-014–016 |
| FR-078–080 | US10 | Brief editorial, classificação e seleção explicadas sem ranking sem base comparável | SC-017–018, SC-024 |
| FR-081–083 | US3, US10 | Leitura rápida, conteúdo seguro e histórias ligadas à evidência | SC-006, SC-019, SC-025 |
| FR-084–086 | US5, US10 | Pacote visual proporcional e prontidão independente por evidência/claim | SC-010, SC-020–021, SC-026 |
| FR-087–088 | US4, US6, US10 | Experiência profissional/social proof qualificados; lineage e agrupamento sem dupla contagem | SC-019, SC-021 |
| FR-089–091 | US11 | Revisão opcional da superfície, scorecard justificado e comparação contextual de alternativas | SC-022–023, SC-027 |
| FR-092–094 | US5, US9, US11 | Pesquisa referenciada, decisões com estado e preservação readonly/Markdown único | SC-015, SC-023–024, SC-027 |
| FR-095–099 | US12 | Tags normalizadas, ocorrências rastreáveis, relação/versão/contexto de pacotes e destaque sustentado | SC-028–029, SC-036 |
| FR-100–101 | US12 | Padrões ligados a participantes, comportamento, escopo, origem e força da conclusão | SC-030 |
| FR-102–104 | US12 | Assistência IA versus produto, atividade/modelo qualificados, codec versus contêiner e privacidade | SC-031–032, SC-037 |
| FR-105–108 | US13 | Lista qualificada de pessoas, fontes/aliases, créditos além de código e vínculo individual evidenciado | SC-033–034, SC-037 |
| FR-109–113 | US12–13 | Perfis de consulta, histórico/migração, Markdown único, operação local e privacidade | SC-028, SC-034–037 |
| FR-114–118 | US14 | Fontes permitidas e claims tipadas, com rotas, papéis de evidência, atribuição e hipótese revisável | SC-038–040 |
| FR-119–122 | US14 | Memória/fonte ausente, perguntas materiais, mecanismo, consequência e validação delimitada | SC-041–043 |
| FR-123–125 | US14 | Síntese flexível e rascunho humano, destaques proporcionais e baseline qualitativa de avaliação | SC-044–046 |
| FR-115 | US14 | Níveis qualitativos de confiança e rationale uniforme, sem converter falta de suporte em confiança baixa | SC-039, SC-047 |

## Focused Review: extensão de tags e contribuidores (2026-10-05)

- [x] Cobertura reaproveitada sem duplicar as regras existentes de evidência, autoria, stack, saída única e privacidade.
- [x] Taxonomia e estados são extensíveis e não exigem fonte, conexão, parser ou instalação externos.
- [x] Filtros preservam baseline, escopo, estado, sistema e evidência; perfil pessoal requer vínculo próprio.
- [x] Pacote declarado, versão resolvida, disponibilidade, uso observado e configuração ativa são distinguíveis.
- [x] Nomes de padrão, instruções/agentes IA, extensão de mídia e diretório de propriedade não bastam isoladamente para alegações fortes.
- [x] Lista de contribuidores comunica cobertura; considera fontes além de Git e mantém aliases/terceiros/bots/IA qualificados.
- [x] Migração preserva histórico no Markdown único; T105/SC-025 segue reservado às validações finais.
- [x] Exemplos e fixtures futuros não devem conter referências particulares ou identificadores de fontes privadas.

## Focused Review: reconstrução de contribuição e narrativa técnica (2026-10-05)

- [x] Memória incompleta não bloqueia reconstrução parcial nem se torna evidência negativa.
- [x] Afirmações materiais distinguem fato, inferência, hipótese, desconhecido e conflito e preservam fonte, baseline, limite e confiança justificada.
- [x] Autoria registrada, comportamento técnico, decisão, colaboração, validação e resultado têm papéis evidenciais independentes.
- [x] Benefício plausível sem medição permanece hipótese; presença de teste não equivale a execução nem resultado.
- [x] Histórias podem usar ordem e prosa próprias; zero a três destaques são possíveis e cada um permanece rascunho rastreável.
- [x] Fontes externas privadas não viram integração/requisito; acesso permitido e estado de indisponibilidade são explícitos.
- [x] Contradições com sequência narrativa fixa, modelo/vocabulário, metodologia e tarefas foram registradas para alinhamento posterior; não se declara implementação.

## Iteration Log

1. Revisão inicial: identificada necessidade de separar evidência existente de execução dinâmica; baseline de conteúdo de status Git; método de fatos particulares do Notion.
2. Ajustes incorporados: FR-006–010, FR-022, FR-041, FR-054; limites da consulta registrados no inventário e metodologia.
3. Revisão após clarificação do entregável: 16/16 itens de qualidade atendidos. A decisão de entregável único está refletida em FR-003, FR-055, FR-064, FR-067, FR-069 e SC-007–008.
4. Revisão inicial da decisão readonly do host: foi especificado gate de separação de permissões; a revisão posterior de 2026-10-04 atualizou FR-008/SC-013 e a constituição v3.0.0 para aviso sem bloqueio. A data original de ratificação continua pendente.
5. Revisão após decisão de consumo por IA: SC-006 substitui o prazo de leitura humana por recuperação de respostas com evidência; SC-011 mantém o prazo de início do fluxo. Notion/Docs permanecem cópias posteriores fora do framework.
6. Revisão após reconciliação e multi-repo: classificações de fontes e linhagem de contribuições compartilhadas devem preservar procedência e evitar dupla contagem; a matriz cobre FR-059–061.
7. Complemento speckit-specify de 2026-10-05: US10–11 e SC-017–027 cobrem prontidão editorial e revisão de superfície; a matriz cobre FR-001–094.
8. Complemento speckit-specify de 2026-10-05: incorporadas as lacunas de tags/ocorrências, dependências e pacotes, padrões, IA, codecs e autoria individual em US12–13, FR-095–113 e SC-028–037; a matriz agora cobre FR-001–113. O núcleo reusa requisitos anteriores de evidência, privacidade, autoria e Markdown único. Nenhuma dúvida material sem default seguro permaneceu; implementação e validação permanecem pendentes.
9. Complemento speckit-specify de 2026-10-05: US14, FR-114–125 e SC-038–047 definem reconstrução de contribuição e raciocínio a partir de fontes permitidas, claims rastreáveis, hipóteses qualificadas, limites de autoria/resultado, perguntas materiais e síntese editorial flexível. A matriz agora cobre FR-001–125. O alinhamento de modelo, contratos, metodologia, fixtures, plano e tarefas ocorreu nas fases subsequentes; implementação continua pendente.
10. Ajuste após speckit-analyze: a confiança de FR-115 tem rubrica `high`/`medium`/`low`, com rationale por suporte/direção, corroboração, contradição e escopo; ausência de suporte fica sem nota. SC-047 e tasks/quickstart cobrem consistência da rubrica. Implementação segue pendente.

