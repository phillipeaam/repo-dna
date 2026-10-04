# Data Model: Auditoria e Source of Truth Markdown

Este modelo descreve os dados que o processo precisa avaliar e consolidar. Não implica persistir JSON ou gerar arquivos separados.

## Entidades

| Entidade | Campos essenciais | Relações |
|---|---|---|
| **Produto** | Nome canônico, aliases, contexto, slug Markdown, estado, links públicos verificados | Agrega um ou mais repositórios; possui um único arquivo canônico |
| **Repositório-alvo** | Caminho selecionado/canônico, nome/remote quando disponíveis, papel no produto, snapshot/ref, estado local, limite de leitura | Pertence a um produto por seleção explícita ou relação evidenciada |
| **Baseline** | Identidade do alvo, HEAD/branch/refs acessíveis, instante, conteúdo/inventário verificável, alterações locais, método/versão | Sessão usa uma ou mais; findings referenciam sua baseline |
| **Sessão de auditoria** | Data, método/versão, etapas, cobertura, checkpoints, término/falha, verificação de preservação | Atualiza o registro canônico; não é arquivo entregue independente |
| **Etapa** | ID, pré-condição, entrada, domínio/aplicabilidade, estado, resultado, motivo de falha | Pertence a uma sessão: preparação, A1, B1–B4, consolidação, reconciliação, revisão |
| **Fonte/evidência** | ID estável, path/commit/URL, tipo, data, repo/snapshot, síntese permitida, divulgação, confiança e limites | Sustenta findings/claims; fonte primária ou contexto |
| **Finding/conclusão** | ID, fato/inferência/relato/conflito, descrição, estado, confiança justificada, limites | Cita evidências; alimenta sistema, contribuição, release ou claim |
| **Sistema/feature** | Nome, comportamento/limite, estado de implementação, repo/snapshot, dependências | Possui evidência e ownership separados |
| **Identidade/contribuição** | Identidades observadas/candidatas, sistema, tipo de contribuição, ownership (pessoal/compartilhado/desconhecido), confiança e wording | Conecta pessoa/claim a sistema e diffs |
| **Release/artefato** | Evento/deadline/timezone, commit/ref candidato, binário/hash/version quando disponível, destino, estado de cada elo | Cadeia de procedência com confiança por relação |
| **Claim** | Afirmação, audiência, estado, wording, evidência e caveat | Referencia findings; mídia pode demonstrar produto sem provar ownership |
| **Asset/mídia** | Origem/criador/licença/crédito, integração, era/snapshot, uso, permissões e legenda | Sustenta comportamento/release; não concede autoria/licença por inferência |
| **Questão/conflito** | Tema, afirmações/fontes em conflito, estado, evidência necessária, bloqueio/resolução | Uma seção atual, ligada ao histórico quando muda |
| **Cobertura** | Domínio, aplicabilidade, estado, escopo, motivo/fallback | Um resultado por domínio da matriz |
| **Registro canônico** | Estado/baseline, resumo humano, facts atuais, claims, apêndices, índice e histórico | Um registro persistente Markdown por produto |

## Vocabulários controlados

- **Cobertura**: complete, partial, not_observed, not_applicable, unavailable, not_verified.
- **Conclusão**: fact, inference, personal_account, conflict, unresolved.
- **Sistema**: implemented, partial, prototype, planned_only, not_found_in_scope.
- **Contribuição**: individually_verified, strongly_supported_shared, shared, unknown, unverified.
- **Tecnologia**: installed, possible_use, observed_use, active_configuration.
- **Runtime**: static_fact, static_risk, measured, not_measured.
- **Release**: exact, strongly_supported, bounded_range, unresolved.
- **Claim**: safe, qualified, internal_only, unsupported, rejected.
- **Publicação**: complete, complete_with_conditions, incomplete_blocking, incomplete_nonblocking, optional.
- **Questão**: resolved, partially_resolved, open_blocking, open_nonblocking, closed_with_reason.
- **Etapa**: pending, in_progress, complete, partial, blocked, not_applicable.

“Confiança” descreve suporte evidencial e requer justificativa. Volume de atividade não estabelece confiança de autoria.

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

Bloquear é válido quando o host não garante acesso readonly, o alvo é ambíguo ou a baseline muda durante a sessão.
