# Contrato: Entrada e única saída

## Entradas

- Repositório selecionado em target-repos/<repo-name>/; o usuário escolhe a cópia.
- Um produto pode abranger mais de um repositório. Relação e identidade são confirmadas antes de consolidar.
- Contexto de autoria, links e permissões é opcional e recebe origem/qualificação.
- Nenhum manifesto ou serviço externo é exigido na primeira versão.
- Instruções normativas são locais. Procedência privada de pesquisa é opcional e não é entrada obrigatória de auditoria; seguir o [contrato de privacidade e autoridade](privacy-local-authority.md).

## Saída

- Um arquivo Markdown persistente analysis-output/<safe-product-slug>.md por produto.
- O Markdown contém resumo, fatos atuais, análise dos domínios aplicáveis, claims/limites, evidências e índice, perguntas, cobertura, estado das etapas e verificação.
- Nova execução do mesmo produto atualiza a mesma autoridade e mantém histórico identificável.
- Produto distinto usa arquivo distinto.
- Slugs são estáveis; colisão interrompe o fluxo para escolha explícita, sem sobrescrever outro arquivo.
- Não gerar HTML, JSON/CSV, ZIP, anexos por sistema, pastas de relatório, Notion exports ou publicação remota.
- Estado temporário pode existir, mas não se torna saída persistente e é removido ao concluir.

## Integridade

- Antes de escrever, confirmar identidade do produto e destino fora de todo alvo e de seus diretórios Git.
- Validar conteúdo Markdown integralmente antes da atualização do arquivo canônico.
- Sessão parcial/bloqueada declara causa no arquivo e não gera relatório de erro independente.
- Output existente não autoriza fundir produtos sem confirmação.
