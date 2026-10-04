# Contrato: Fronteira readonly

## Acesso

1. Resolver e registrar caminho absoluto/canônico antes da leitura.
2. Ler somente alvos selecionados. Resolver symlinks/junctions e bloquear escape para destinos não selecionados.
3. Identificar Git directory/worktree/object store reais, mesmo externos à raiz visível.
4. Usar apenas ferramentas/comandos de leitura auditados; desativar operações Git com efeitos incidentais quando aplicável.
5. Nunca executar scripts, testes, builds, hooks, package managers, plugins, macros, imports de IDE/editor ou binários do alvo.
6. Não fazer checkout, clean, stash, fetch, refresh de índice, inicialização de submódulo, reset, commit, tag, merge ou push.
7. Nenhum cache, temporário, log, índice ou relatório é criado no alvo.

## Controle antes da análise

- A política efetiva do host MUST permitir leitura e impedir criação, alteração e exclusão pelo processo de análise no alvo e em seus diretórios Git reais.
- A mesma política MUST permitir salvar o Markdown em analysis-output/, fora do alvo e de seus diretórios Git.
- Validar a separação usando os caminhos canônicos e permissões efetivas antes da inspeção substantiva; bloquear com estado e motivo quando não puder ser comprovada.
- Se o alvo intersectar uma raiz gravável do agente, bloquear, a menos que o host prove uma exclusão mais específica que negue escrita no alvo e Git associado.
- Instruções de skill, .gitignore, hashes e git status não constituem controle preventivo de permissão.
- Comparar estado inicial/final como defesa adicional, sem substituir controle preventivo.
- Atributo filesystem read-only não é garantia se o mesmo processo puder removê-lo ou alterar as permissões.

## Teste de capacidade do host

- Em fixture controlada, comprovar que a identidade de auditoria consegue ler o alvo e não consegue criar, alterar ou excluir arquivo nele ou em seu Git associado.
- Comprovar separadamente que a saída autorizada em analysis-output/ continua gravável.
- Se qualquer controle não puder ser exercitado ou comprovado, declarar o perfil do host incompatível e bloquear antes da inspeção substantiva.

## Verificação

- Registrar alterações preexistentes sem normalizar ou corrigir.
- Verificar conteúdo/estado observável, incluindo paths untracked e ignored no escopo.
- Concorrência ou cobertura incompleta resulta em preservação inconclusiva/parcial.
- git status limpo isoladamente nunca justifica declaração de preservação verificada.
