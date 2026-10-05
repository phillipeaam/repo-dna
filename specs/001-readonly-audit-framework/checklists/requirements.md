# Specification Quality Checklist: Framework de auditoria readonly

**Purpose**: Validar completude e qualidade da especificação antes do planejamento.
**Created**: 2026-10-03
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
- Status Draft é intencional: artefatos prontos para planejamento, sem declarar framework implementado ou aprovação humana.
- FR-006 limita afirmações de preservação à cobertura observada; git status sozinho não basta.
- FR-007 e FR-041 resolvem a diferença entre B2 das fontes, que admite profiling, e o contrato readonly desta feature: medições existentes são dados; execução dinâmica é externa e não é iniciada nem orquestrada pelo framework.
- FR-010 e FR-060 adaptam reconciliação das fontes para leitura: nenhuma edição ou exclusão no Notion.
- FR-022 e FR-052 mantêm verificação por tipo de claim e confirmação pessoal identificada.
- FR-054 permite encerramento com lacunas não bloqueantes, evitando recuperação infinita.
- A constituição v2.0.0 foi atualizada explicitamente antes da implementação para governar skills, auditoria readonly e Markdown canônico; a data original de ratificação permanece TODO até confirmação.
- Clarificação original de 2026-10-04: host enforcement era gate obrigatório. Revisão posterior de 2026-10-04 substitui essa decisão: perfil sem prova avisa e permite análise estática, com preservação não verificada; ver FR-008 e SC-013 atualizados.
- Clarificação de 2026-10-04: há exatamente um entregável Markdown local por produto; relatórios HTML, JSON/CSV publicados, anexos e escrita/exportação para Notion estão fora do escopo.
- Clarificação de 2026-10-04: pessoas podem copiar o Markdown para Notion/Docs depois; agentes de IA são consumidores previstos. SC-006 mede respostas rastreáveis de IA, e SC-011 continua medindo o tempo para encontrar como iniciar.
- Não há extensions.yml nem hooks before_specify/after_specify registrados nesta checkout. A branch observada é feature/001-readonly-audit-framework.

## Acceptance Coverage Map

Os requisitos têm observações binárias ou estados explícitos verificáveis. Esta matriz vincula grupos ao cenário de uso, ao resultado observável e à medida de aceitação; o plano detalhará casos de validação executáveis.

| Requisitos | Jornada | Resultado observável | Critério |
|---|---|---|---|
| FR-001–002 | US1, US6 | Seleção inequívoca e agrupamento explícito | SC-007, SC-011 |
| FR-003–008 | US1 | Resultados externos, baseline, comparação e enforcement readonly pelo host antes da inspeção substantiva | SC-001–002, SC-013 |
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

## Iteration Log

1. Revisão inicial: identificada necessidade de separar evidência existente de execução dinâmica; baseline de conteúdo de status Git; método de fatos particulares do Notion.
2. Ajustes incorporados: FR-006–010, FR-022, FR-041, FR-054; limites da consulta registrados no inventário e metodologia.
3. Revisão após clarificação do entregável: 16/16 itens de qualidade atendidos; 70/70 requisitos incluídos na matriz. A decisão de entregável único está refletida em FR-003, FR-055, FR-064, FR-067, FR-069 e SC-007–008.
4. Revisão após decisão readonly do host: FR-008 e SC-013 exigem separação de permissões comprovada por fixture; constituição v2.0.0 atualizada. A data original de ratificação continua pendente.
5. Revisão após decisão de consumo por IA: SC-006 substitui o prazo de leitura humana por recuperação de respostas com evidência; SC-011 mantém o prazo de início do fluxo. Notion/Docs permanecem cópias posteriores fora do framework.
6. Revisão após reconciliação e multi-repo: classificações de fontes e linhagem de contribuições compartilhadas devem preservar procedência e evitar dupla contagem; a matriz cobre FR-059–061.

