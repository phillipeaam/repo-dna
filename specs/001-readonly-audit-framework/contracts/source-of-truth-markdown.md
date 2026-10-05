# Contrato: Página Project Source of Truth em Markdown

## Ordem de conteúdo

1. Metadados simples: versão do documento, produto, slug, data, estado, versão do método e repos/baselines cobertos.
2. Start Here: o que é, por que importa, papel/contribuições fortes, release/estado e cautela.
3. At a Glance e mapa de estudo.
4. Core Project Record por assunto: produto/fluxo, contexto/equipe/papel, ownership, sistemas/arquitetura/stack, implementação planejada vs encontrada, decisões, timeline/release, evidência, claims e questões.
5. Projeção pública e readiness, quando aplicáveis.
6. Readiness editorial por produto, com papel/contexto separados, leitura rápida, histórias sustentadas, pacote proporcional de evidências e decisão humana distinta da recomendação; campos sem suporte ficam desconhecidos.
7. Revisão de superfície de portfólio, somente quando selecionada, com escopo observado, percurso, placar justificado/findings ou `not_observed`, prioridades, plano e fontes no mesmo documento.
8. Cobertura, estado das etapas, perguntas pendentes e log de verificação.
9. Apêndices A1/B1/B2/B3/B4, reconciliação de fontes, índices e histórico.

## Regras

- Síntese concisa com termos técnicos necessários explicados.
- Novos documentos usam schema `2.0.0`. Registro legado `1.0.0` permanece legível e migra no mesmo Markdown quando atualizado, com nota no histórico; seções editoriais/superfície ausentes significam não avaliadas, não falha nem aprovação.
- Headings e identificadores estáveis MUST permitir que humanos e agentes recuperem respostas por tema e citem findings/evidências diretamente.
- Cada resposta factual destinada à consulta por agente MUST apontar a uma evidência recuperável, baseline e limitação; ausência de suporte deve permanecer explícita.
- Paths locais e URLs incluem contexto para revalidar fonte/data/versão.
- Tabelas compactas para matrizes; parágrafos/listas para explicações.
- Headers e sumário são navegação; toggles não são requisito.
- Verdade atual permanece no início/core; apêndices preservam evidência e auditoria histórica.
- Cada claim factual relevante aponta para fonte, baseline e limite/estado de confiança.
- Distinguir not_observed, not_applicable, unavailable e not_verified.
- Não incorporar código grande, credenciais, endpoints privados, e-mails ou dados pessoais desnecessários.
- Não criar representações HTML/CSV, pastas por sistema ou exports.
- A extensão editorial não exige brief, número fixo de projetos/histórias ou material visual; recomendações de pacote não são gates de elegibilidade.
- Avaliações condicionais do site/protótipo ocupam seções deste mesmo arquivo e registram somente páginas, viewports e interações realmente observados.
