# Audit Requirements Checklist: Framework de auditoria readonly

**Purpose**: Revisar se os requisitos da auditoria de repositórios definem com clareza os limites readonly, a avaliação baseada em evidências e o registro canônico Markdown.
**Created**: 2026-10-04
**Feature**: [spec.md](../spec.md)

**Note**: Este checklist revisa a qualidade dos requisitos, não a conclusão da implementação.
**Review Ownership**: Este é um artefato de revisão de requisitos. Marque um item [x] somente quando a pessoa revisora considerar satisfeito o critério de qualidade.
**Marker Semantics**: [x] indica que a qualidade do requisito foi revisada e satisfeita; não significa que o trabalho de implementação foi concluído.

## Clareza do escopo e da entrada

- [x] CHK001 Os requisitos definem critérios explícitos para selecionar um repositório e associar vários repositórios a um mesmo produto sem fusão automática? [Clarity, Spec §FR-001–002]
- [x] CHK002 Os requisitos deixam inequívoca a diferença entre o repositório-alvo, temporários descartáveis e o entregável persistente? [Clarity, Spec §FR-003]
- [x] CHK003 Os requisitos especificam como caminhos reais, symlinks, junctions, submódulos e diretórios Git externos afetam o limite de leitura e escrita? [Completeness, Spec §FR-008]
- [x] CHK004 Os requisitos esclarecem o que acontece quando o alvo é ambíguo, o slug colide ou a relação entre repositórios não está confirmada? [Coverage, Edge Case, Spec §FR-002, FR-058]

## Garantia de preservação e privacidade

- [x] CHK005 Os requisitos definem quais componentes da baseline precisam ser registrados para distinguir alterações preexistentes das ocorridas durante a sessão? [Completeness, Spec §FR-004]
- [x] CHK006 Os requisitos delimitam de forma verificável o que conta como conteúdo ou estado do projeto preservado, inclusive itens ignorados e não rastreados? [Clarity, Spec §FR-005–006]
- [x] CHK007 Os requisitos esclarecem quando a cobertura de preservação é insuficiente para declarar o alvo integralmente preservado? [Acceptance Criteria, Spec §FR-006]
- [x] CHK008 Os requisitos distinguem análise estática readonly de validação dinâmica explicitamente fora de todos os fluxos e entregáveis desta feature? [Consistency, Coverage, Spec §FR-007, FR-041]
- [x] CHK009 Os requisitos especificam como conteúdo não confiável, segredos, dados pessoais, código proprietário e limites de divulgação afetam evidências e trechos no Markdown? [Completeness, Spec §FR-009–012]

## Evidência, interpretação e autoria

- [x] CHK010 Os requisitos tornam recuperável cada conclusão relevante por meio de fonte, baseline, escopo temporal, estado de verificação, confiança justificada e limitações? [Measurability, Spec §FR-022–023]
- [x] CHK011 Os requisitos distinguem fato, inferência, relato pessoal, conflito e ausência de observação, sem converter indisponibilidade em evidência negativa? [Consistency, Spec §FR-018–019, FR-023]
- [x] CHK012 Os requisitos deixam claro que atividade, churn, blame e contagens não comprovam autoria exclusiva, liderança ou impacto? [Clarity, Spec §FR-024–027]
- [x] CHK013 Os requisitos separam implementação, planejamento, configuração, exercício, inclusão em release e publicação para cada sistema ou claim? [Consistency, Spec §FR-028–030]
- [x] CHK014 Os requisitos especificam como evidências conflitantes, fontes indisponíveis e mudanças de baseline afetam conclusões e retomada? [Coverage, Recovery, Spec §FR-018, FR-059–066]

## Fonte de verdade e critérios de aceitação

- [x] CHK015 Os requisitos definem headings e identificadores estáveis para pessoas e agentes recuperarem resumo, cobertura, evidências, claims, pendências e histórico? [Completeness, Clarity, Spec §FR-003, FR-055–057, FR-067]
- [x] CHK016 Os requisitos esclarecem como atualizações do mesmo produto preservam histórico sem criar relatórios paralelos ou autoridades concorrentes? [Consistency, Spec §FR-003, FR-064–068]
- [x] CHK017 Os critérios de aceitação permitem determinar objetivamente quando há exatamente um Markdown persistente por produto e nenhum entregável alternativo? [Measurability, Spec §SC-007–008]
- [x] CHK018 Os critérios de aceitação cobrem cenários de preservação incompleta, autoria ambígua, release sem artefato correlacionado e desempenho não medido? [Scenario Coverage, Edge Case, Spec §SC-001, SC-005]
- [x] CHK019 Os requisitos distinguem revisão/conclusão da auditoria de aprovação humana, segurança de publicação e autorização para publicar? [Clarity, Spec §FR-047–054, FR-067–068]
- [x] CHK020 (revisado em 2026-10-04) Os requisitos distinguem enforcement efetivo de procedimento e comparação observacional, exigindo aviso e limitando claims quando não há prova, sem bloquear a auditoria estática? [Clarity, Spec §FR-008, SC-013]
- [x] CHK021 Os requisitos definem a procedência e as condições de comparação das medições e separam tamanho de build, configuração e risco estático de resultados de runtime? [Completeness, Clarity, Spec §FR-037–041]
- [x] CHK022 Os requisitos avaliam separadamente permissão para link, embed, cópia, crop, download/rehosting e alteração de áudio, sem inferir autorização a partir da publicação existente? [Completeness, Edge Case, Spec §FR-047–051]
- [x] CHK023 Os requisitos definem categorias distintas para itens reconciliados e exigem fonte e justificativa para cada classificação? [Completeness, Clarity, Spec §FR-059–060]
- [x] CHK024 Os requisitos definem como rastrear uma contribuição compartilhada pela linhagem entre repositórios e evitar sua dupla contagem na consolidação? [Completeness, Measurability, Spec §FR-045, FR-061]

## Notes

- Todos os itens foram revisados contra os artefatos de design. [x] registra que há argumentos explícitos de qualidade nos requisitos/contratos; não significa implementação concluída.
- Evidências revisadas:
  - CHK001–004: spec FR-001–002/058, Edge Cases; `contracts/input-output.md` define seleção explícita e bloqueio de colisão de slug.
  - CHK005–009: spec FR-004–012, Edge Cases; `contracts/readonly-boundary.md` define baseline, escopo observado, verificação parcial e bloqueios.
  - CHK010–014: spec FR-018–032 e FR-059–066; `data-model.md` define proveniência, estados de evidência, relações e atualização após mudança de baseline.
  - CHK015–019: spec FR-055–068 e SC-001/005/007–009; `contracts/source-of-truth-markdown.md` e `contracts/input-output.md` definem navegação, história, saída única e limites de revisão/publicação.
  - CHK020–024: spec FR-008, FR-037–041, FR-045, FR-047–051, FR-059–061 e SC-013; contratos readonly e de saída e tarefas T005/T007/T019/T033/T039/T041/T045/T046 cobrem os respectivos critérios.
- Este checklist não registra execução ou conclusão da implementação.
- Os itens CHK001–CHK024 têm referências à especificação para rastreabilidade.

