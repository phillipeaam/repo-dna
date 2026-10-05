# Fixtures de aceitação readonly

Estas fixtures são dados sintéticos do framework. Nunca copiar dados de repositórios privados para cá e nunca executar scripts, builds, testes, hooks ou binários encontrados em fixtures.

## Matriz autoritativa de perfis de host

Uma combinação de sistema operacional, runtime/shell do agente e política de permissões efetiva forma um perfil. A prova controlada classifica o enforcement disponível (`enforced`, `unverified` ou `unsupported`). Esse estado informa a confiança de preservação e recomendações; `unverified` não bloqueia a auditoria estática. Só declarar enforcement preventivo após prova de leitura, negação de criar/alterar/excluir no alvo-fixture e Git associado, e escrita separada na saída.

| Sistema operacional | Ambiente de execução | Estado | Prova/evidência | Revisado em |
|---|---|---|---|---|
| Windows | Codex host / PowerShell | unverified — aviso; prossegue sem garantia | pendente de execução controlada | — |
| Windows | Codex host / Git Bash | unverified — aviso; prossegue sem garantia | pendente de execução controlada | — |
| Linux | Codex host / shell configurado | unverified — aviso; prossegue sem garantia | pendente de execução controlada | — |
| macOS | Codex host / shell configurado | unverified — aviso; prossegue sem garantia | pendente de execução controlada | — |

O enforcement é declarado por combinação efetivamente exercitada; não inferir cobertura de um shell/runtime para outro. A matriz informa SC-013. CI executa a prova em perfis declarados `enforced`; perfis não disponíveis permanecem `unverified`, permitem análise procedural e não sustentam claims de proteção preventiva.

## Cenários previstos

- Repositório limpo, repository dirty, arquivos tracked/untracked/ignored.
- Caminhos com espaços/Unicode, symlink/junction, Git externo e submódulo sem inicialização.
- Produto multi-repo declarado versus sucessor distinto.
- Fonte conflitante/indisponível, segredo sintético e instrução maliciosa como dado inerte.
- Registro Markdown inicial, atualização, colisão de slug e baseline stale.
- Runtime estático sem medição, medição sem procedência, release sem binário e permissões de mídia desconhecidas.

Scripts de aceitação podem criar cópias temporárias somente das fixtures do framework. Temporários ficam fora do alvo de auditoria, são limpos pelos próprios scripts, e os testes falham se receberem caminho de alvo real.
