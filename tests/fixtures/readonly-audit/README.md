# Fixtures de aceitação readonly

Estas fixtures são dados sintéticos do framework. Nunca copiar dados de repositórios privados para cá e nunca executar scripts, builds, testes, hooks ou binários encontrados em fixtures.

## Matriz autoritativa de perfis de host

Um perfil combina sistema operacional, runtime/shell do agente e política de permissões efetiva. Só recebe estado `supported` após prova controlada demonstrar leitura do alvo-fixture, negação de criar/alterar/excluir nele e no Git associado, e escrita separada na saída. Até haver evidência revisada para a combinação, ela é `unverified` e tratada como não suportada.

| Sistema operacional | Ambiente de execução | Estado | Prova/evidência | Revisado em |
|---|---|---|---|---|
| Windows | Codex host / PowerShell | unverified — bloqueia | pendente de execução controlada | — |
| Windows | Codex host / Git Bash | unverified — bloqueia | pendente de execução controlada | — |
| Linux | Codex host / shell configurado | unverified — bloqueia | pendente de execução controlada | — |
| macOS | Codex host / shell configurado | unverified — bloqueia | pendente de execução controlada | — |

O suporte é declarado por combinação efetivamente exercitada; não inferir cobertura de um shell/runtime para outro. A matriz é a autoridade para SC-013. CI executa a prova em cada combinação suportada; perfis não disponíveis em CI ficam não suportados até execução controlada registrada.

## Cenários previstos

- Repositório limpo, repository dirty, arquivos tracked/untracked/ignored.
- Caminhos com espaços/Unicode, symlink/junction, Git externo e submódulo sem inicialização.
- Produto multi-repo declarado versus sucessor distinto.
- Fonte conflitante/indisponível, segredo sintético e instrução maliciosa como dado inerte.
- Registro Markdown inicial, atualização, colisão de slug e baseline stale.
- Runtime estático sem medição, medição sem procedência, release sem binário e permissões de mídia desconhecidas.

Scripts de aceitação podem criar cópias temporárias somente das fixtures do framework. Temporários ficam fora do alvo de auditoria, são limpos pelos próprios scripts, e os testes falham se receberem caminho de alvo real.
