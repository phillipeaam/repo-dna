# Mapa público de cobertura do método local

Este mapa substitui o inventário identificável das fontes de pesquisa. O método
incorporado é a autoridade local aprovada: constituição/spec governam requisitos;
skill, runbooks e contratos governam a execução. Todas as instruções necessárias
estão no checkout. Fontes externas de um alvo são evidência opcional, nunca uma
dependência para recuperar regras do método.

Os originais de procedência podem ser guardados em `private-context/research/`,
ignorado e não distribuído. Este mapa não contém nomes, títulos, IDs, links ou
datas particulares das fontes privadas. Ele preserva os temas metodológicos
generalizados, sem alegar cópia integral ou revalidação dos fatos dos casos.

## Correspondência dos temas incorporados

| ID | Tema e ensinamento preservado | Instrução local recuperável |
|---|---|---|
| L01 | Intenção: framework de investigação e um registro por produto | [Método §1](methodology.md) e [entrada/saída](contracts/input-output.md) |
| L02 | Regras: existência, autoria, publicação e impacto separados; fontes somente leitura | [Método §2](methodology.md) e [skill](../../.agents/skills/repodna-audit/SKILL.md) |
| L03 | Hierarquia contextual, confiança justificada e vocabulário de evidência | [Método §3](methodology.md) e [vocabulário](../../.agents/skills/repodna-audit/references/evidence-vocabulary.md) |
| L04 | Etapas, entradas, saídas, gates, domínio aplicável e checkpoints | [Método §4](methodology.md) e [workflow](../../.agents/skills/repodna-audit/references/workflow.md) |
| L05 | A1: identidade/timeline, sistemas, autoria, planejado vs implementado e histórias | [Método §5](methodology.md) e [A1](../../.agents/skills/repodna-audit/references/forensic-a1.md) |
| L06 | B1: arquitetura/configuração, jogos, apps/serviços e uso observado de dependências | [Método §6](methodology.md) e [B1](../../.agents/skills/repodna-audit/references/production-b1.md) |
| L07 | B2: riscos estáticos, lifetime/concorrência, medição com procedência e limites | [Método §7](methodology.md) e [B2](../../.agents/skills/repodna-audit/references/runtime-b2.md) |
| L08 | B3: fonte → artefato → publicação, snapshots separados e precisão por elo | [Método §8](methodology.md) e [B3](../../.agents/skills/repodna-audit/references/provenance-b3.md) |
| L09 | B4: créditos, autoria de asset, mídia, permissões por ação e readiness | [Método §9](methodology.md) e [B4](../../.agents/skills/repodna-audit/references/publication-b4.md) |
| L10 | Documento único: navegação, estado atual, índices, história e apêndices | [Método §10](methodology.md) e [consolidação](../../.agents/skills/repodna-audit/references/consolidation.md) |
| L11 | Reconciliação, classificação de fontes, conflitos, encerramento honesto de lacunas | [Método §11](methodology.md) e [consolidação](../../.agents/skills/repodna-audit/references/consolidation.md) |
| L12 | Casos generalizados: prazos, migrações, sucessores, pacotes e claims superadas | [Método §12](methodology.md) e [workflow multi-repo](../../.agents/skills/repodna-audit/references/workflow.md) |
| L13 | Capacidades existentes: reuso sem promover heurísticas, retirada do pipeline antigo | [Método §13](methodology.md) e [plano](plan.md) |
| L14 | Limites: sem execução dinâmica, sem afirmação inventada e aviso sobre proteção do host não comprovada | [Método §14](methodology.md) e [fronteira](contracts/readonly-boundary.md) |

## Autoridade e privacidade

Atualizações do método passam pela governança local. A descoberta de uma fonte
original divergente não altera instruções automaticamente. A ausência das fontes
originais ou da área privada não impede usar o método local.

Antes de compartilhar, revisar documentos atuais e índice Git conforme o
[contrato de privacidade e autoridade](contracts/privacy-local-authority.md).
Revisar também detalhes que padrões automáticos não reconhecem. Uma cópia de
trabalho limpa não prova que o índice ou commits antigos estejam limpos.
