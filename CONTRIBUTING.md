# Contribuindo com o RepoDNA

## Escopo atual

RepoDNA contém duas skills de produto: `repodna-audit`, que conduz investigação
estática, e `repodna-itch-format`, que prepara apresentação a partir de um audit
existente. O Spec Kit fornece ferramentas de desenvolvimento. Não há CLI nem
analisador de repositórios separado. Uma auditoria gera um Markdown canônico em
`analysis-output/`. Um repositório-alvo é somente leitura; nunca execute scripts,
builds, testes ou instaladores encontrados nele.

Leia primeiro [README.md](README.md), a constituição em
`.specify/memory/constitution.md` e os contratos em
`specs/001-readonly-audit-framework/`.

## Alterações e validação

- Preserve os limites readonly, a rastreabilidade entre conclusão e evidência,
  e o formato único de saída.
- Adicione cenários com fixtures sintéticas do framework. Não use um checkout
  de usuário como fixture.
- Não gere, versione ou publique conteúdo de `target-repos/` ou
  `analysis-output/`.
- Execute `bash tests/run.sh --framework` e `git diff --check`.

O método aprovado é local; consulte `methodology.md` e `source-inventory.md` na
feature para recuperar os ensinamentos sem acessar fontes originais. Guarde
procedência privada opcional somente em `private-context/`. Generalize nomes,
títulos, links/IDs pessoais, detalhes particulares e caminhos de usuário antes
de compartilhar. Preserve a identidade pública de copyright e do framework.

Execute também `python scripts/check-public-context.py` (Python 3.11+) para
revisar arquivos atuais e índice. Uma versão privada já preparada para commit
precisa ser substituída pela versão sanitizada; ignorar a área não limpa arquivos
já rastreados. O guard reconhece padrões e termos conhecidos, não toda informação
confidencial: revise semanticamente documentos e binários. Não reescreva histórico
para retirar exposição passada sem autorização específica.

Os testes de contrato podem ler os artefatos do framework e criar repositórios
descartáveis em diretório temporário. Eles não devem executar código de um
repositório-alvo.

## Pull requests

Explique a mudança observável, os contratos cobertos e qualquer limite de
compatibilidade. Nunca anexe dados privados de auditoria, relatórios de alvo,
credenciais ou arquivos de `analysis-output/`.
