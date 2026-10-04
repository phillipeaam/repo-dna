# Casos sintéticos de migração e retomada

| Caso | Estado anterior | Evento | Resultado esperado |
|---|---|---|---|
| M1 | Evidência legada `legacy-1`, método `1.0`, heurística `possible_use` | Schema compatível, mesma semântica preservada | Importar com origem/versão, manter `possible_use`, não elevar a observação |
| M2 | Claim legado sem snapshot ou procedência | Migração tenta inferir baseline | Recusar ou manter `not_verified`; registrar razão e evidência necessária |
| M3 | Registro v1 tem evidência ligada a `repo@a1` | Nova sessão confirma mesmo `repo@a1` e método compatível | Reutilizar finding após checar refs/escopo e manter histórico |
| M4 | Registro v1 usa `repo@a1` | Nova sessão encontra HEAD `b2` | Marcar findings dependentes como stale, revalidar e registrar ambos snapshots |
| M5 | Etapas A1/B1 concluídas; sessão parou antes de B2 | Retomada autorizada | Confirmar perfil readonly, identidade, baseline e método; continuar do checkpoint sem afirmar B2 concluído |
| M6 | Produto antigo e sucessor com nomes parecidos | Atualização tenta reutilizar registro | Manter registros separados até relação ser confirmada |

Resultado final continua no mesmo Markdown por produto; dados intermediários de sessão são descartáveis.
