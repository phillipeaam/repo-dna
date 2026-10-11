# Contrato: privacidade do framework e autoridade local

## Conteúdo compartilhável

Versionar regras e exemplos generalizados. Excluir nomes dos projetos de pesquisa
privada, títulos/IDs/links de páginas pessoais, detalhes particulares e caminhos
de usuários reais. Identidade pública do framework e dependências oficiais pode
permanecer. Nunca colocar valores privados em mensagens de falha.

## Procedência local opcional

`private-context/` guarda entradas de pesquisa e termos privados conhecidos,
sem fazer parte do índice, CI, distribuição ou das instruções obrigatórias.
Não é saída de auditoria. Sua ausência não impede seguir o método.
Preservar a cópia original antes de generalizar documentos. Não reescrever o
histórico Git: uma exposição passada exige aviso e ação separada autorizada.

## Revisão de privacidade

Verificar arquivos atuais e conteúdo do índice, incluindo arquivos previamente
rastreados em áreas ignoradas. Sanitizar a cópia de trabalho não limpa o índice.
O guard verifica padrões de páginas pessoais, caminhos pessoais em documentos
e, quando disponível, termos de `private-context/known-sensitive-terms.txt`.
Revisão humana complementa o guard para informações sem padrão reconhecível.
Nenhum guard é certificação universal de ausência de informação confidencial.
Para distribuição, `--ref` revisa também os blobs da tag/commit realmente
empacotado; um checkout atual limpo não libera uma tag com metadados privados.

## Autoridade e cobertura

A constituição e a spec governam os requisitos; skill, runbooks e contratos
locais aprovados são a autoridade operacional. O mapa em `source-inventory.md`
liga todos os temas metodológicos incorporados a instruções locais recuperáveis.
Referências originais são procedência privada opcional, não requisitos de acesso.
Não há consulta obrigatória ao Notion nem a qualquer serviço para obter o método.
Contexto externo de um alvo pode complementar evidência quando autorizado,
sempre somente leitura; nunca redefine as regras do framework.

Generalizar um caso preserva sua regra e seus limites. Não equivale a copiar
integralmente a fonte nem a verificar todos os fatos particulares daquela fonte.
