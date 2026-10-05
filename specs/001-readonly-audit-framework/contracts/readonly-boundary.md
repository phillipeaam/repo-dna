# Contrato: Fronteira readonly

## Acesso

1. Resolver e registrar caminho absoluto/canônico antes da leitura.
2. Ler somente alvos selecionados. Resolver symlinks/junctions e bloquear escape para destinos não selecionados.
3. Identificar Git directory/worktree/object store reais, mesmo externos à raiz visível.
4. Usar apenas ferramentas/comandos de leitura auditados; desativar operações Git com efeitos incidentais quando aplicável.
5. Nunca executar scripts, testes, builds, hooks, package managers, plugins, macros, imports de IDE/editor ou binários do alvo.
6. Não fazer checkout, clean, stash, fetch, refresh de índice, inicialização de submódulo, reset, commit, tag, merge ou push.
7. Nenhum cache, temporário, log, índice ou relatório é criado no alvo.

## Procedimento antes da análise

- O agente MUST seguir procedimento de não escrita: não editar, corrigir, formatar, instalar, importar, executar ou iniciar ferramentas do alvo.
- Registrar o estado de proteção do host (`enforced`, `unverified` ou `unknown`) antes da inspeção, quando essa informação estiver disponível.
- Se o alvo estiver em uma raiz gravável ou a política for desconhecida, avisar o usuário antes da leitura substantiva e continuar com status de preservação não verificado; isso não bloqueia por si só.
- Salvar o Markdown em `analysis-output/`, fora do alvo e de seus diretórios Git. Se não for possível separar saída de alvo, pedir outro slug/destino ou bloquear por conflito de caminho.
- Instruções, `.gitignore`, hashes, `git status` e atributos read-only não são controle preventivo. Não os descreva como tal.
- Comparar estado inicial/final como observação de mudanças, não como prova de que nenhuma escrita incidental ocorreu.

## Validação opcional de capacidade do host

- Em fixture controlada, pode-se comprovar que a identidade de auditoria consegue ler o alvo e não consegue criar, alterar ou excluir arquivo nele ou em seu Git associado.
- Comprovar separadamente que a saída autorizada em `analysis-output/` continua gravável.
- Se a prova não foi executada ou falhou, marcar o perfil `unverified`/`unsupported`, avisar e permitir a auditoria com preservação não verificada.

## Verificação

- Registrar alterações preexistentes sem normalizar ou corrigir.
- Verificar conteúdo/estado observável, incluindo paths untracked e ignored no escopo.
- Concorrência ou cobertura incompleta resulta em preservação inconclusiva/parcial. Comparação sem diferenças permite dizer `observed_unchanged` somente para o escopo examinado; `verified` exige enforcement efetivo comprovado mais comparação suficiente. Sem enforcement, não há garantia preventiva.
- git status limpo isoladamente nunca justifica declaração de preservação verificada.
