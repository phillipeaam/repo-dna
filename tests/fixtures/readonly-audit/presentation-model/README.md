# Cenários controlados de apresentação

[sample-product.md](sample-product.md) é o único canônico fictício do produto.
Evidências são inline e fictícias; não são fontes executáveis. Não usar nomes,
URLs, mídia, código ou dados de inputs privados. Não requer conta/Notion/rede.

Setup: Python 3.11+, Bash e checkout do framework. Executar
`bash tests/publication_format_contract_test.sh` ou `bash tests/run.sh --framework`.
O check aceita somente o caminho exato da fixture resolvido; recusa qualquer
outro argumento antes de leitura. Nunca passar targets/audits reais, nem executar
conteúdo da fixture. Mutações negativas ficam em memória, sem novos entregáveis.

| Caso | Pergunta/procedimento | Resultado e requisito |
|---|---|---|
| A | A rota do resumo recupera fonte primary, baseline e limites? | C-001–004 → E existentes no único registro; secondary não substitui primary; SC-001/003/010 |
| B | As duas variantes conservam fatos/ressalvas, com voz e adaptação justificadas? | itch real e texto fictício, sem compatibilidade real adicional; SC-002/010 |
| C | Trabalho shared/unknown vira exclusividade, cargo, composição ou resultado? | nenhuma promoção; SC-004 |
| D | Permissão unknown de mídia bloqueia texto seguro independente? | só reuso da mídia bloqueado, texto revisável; SC-005 |
| E | Mudança b1→b2 preserva v1 e invalida aceitação? | v1 accepted/stale não elegível; v2 draft até decisão explícita; SC-006 |
| F | Pouca evidência/campo essencial ausente/ressalva sem espaço? | texto mínimo válido, ausência essencial bloqueia dependente; nunca remover caveat; FR-026/SC-003 |
| G | Pode seguir método sem fonte privada ou executar alvo/criar outro registro? | um Markdown, sem execução/publicação/identificador privado; SC-007/009 |
| H | Preservação individual da migração foi verificada? | consultar migration da 002 e manifesto privado opcional; se ausente, registrar ausência, não inventar conferência; SC-008 |

Revisão guiada SC-010 no próprio canônico: público, canal, estado, principal gap,
rota factual e voz/origem/estado; perguntas sobre fidelidade e personalidade são
separadas. Resultados do agente não são avaliação humana nem prova de recepção.
O teste faz rejeições de referências quebradas, claims sem suporte, IDs privados,
ressalva perdida, aprovação sem decisão, stale elegível, mídia sem licença e
segundo canônico; não prova verdade de projeto, conformidade final de página,
acessibilidade, renderização, runtime ou permissão jurídica.

## Verificação

2026-10-07: check de apresentação passou e rejeitou **15 mutações negativas**
em memória. A tentativa de passar path fora da fixture foi recusada antes da
leitura. Suíte seletiva do framework: **17/17 checks passaram**; guard de
contexto público e referências locais passaram. Casos A–G receberam revisão
guiada do agente no canônico, sem estudo humano ou medição temporal. Caso H
foi conferido no recorte de migração registrado, sem copiar dados particulares
para esta fixture. Não há dependência de um acervo real específico. Probe de
host da suíte permanece unsupported/unverified; não certifica sandbox do alvo.


## Revisão guiada da entrada itch-format — 2026-10-07
+
+Revisão documental/manual pelo agente, usando apenas sample-product.md e contextos declarados; não é execução de agente independente, estudo de recepção ou teste de página.
+
+| Contexto simulado | Resultado da revisão | Limite |
+|---|---|---|
+| Caminho explícito para sample-product.md e outro audit citado na conversa | Priorizar o caminho explícito; selecionar Farol de Papel, schema 2.1.0, synthetic-b2/partial | Outro audit apenas contextual não substitui fonte |
+| Sem caminho; conversa identifica sample-product.md como audit recém-gerado | Reutilizar esse caminho; não solicitar preenchimento do modelo | Contexto deve conter referência recuperável |
+| Sem caminho; dois audits possíveis | Pedir somente qual relatório usar; não selecionar pelo nome mais recente ou varrer pastas | Nenhum texto factual gerado antes de resolver identidade |
+| Caminho explícito indisponível, mesmo com fixture acessível na conversa | Informar indisponibilidade e pedir correção; não fazer fallback silencioso | Sem reaudit ou relatório substituto |
+
+Com fonte válida e pouca evidência, a experiência de navegação por sinais é sustentada; funções completas, execução e resultados conservam desconhecidos. Inputs, engine e links de acesso não são inventados. HTML/CSS solicitados representam a mesma seleção em blocos separados, sem chamar a auditoria nem impor estética. Uma proposta continua draft; histórico aceito anterior não autoriza nova redação automaticamente. Perfil do canal movido, método genérico compartilhado e grafo local validados pelos checks; nenhum relatório privado foi consumido como exemplo.
+
+quick_validate oficial do skill-creator passou (PyYAML instalado apenas em tmp para o check). Suíte 17/17 passou com 15 mutações negativas. Links de 29 documentos resolvem; perfil antigo removido. Hashes de artefatos reais selecionados para preservação permaneceram idênticos, sem leitura editorial desses dados. Esses checks validam estrutura/contratos; decisões futuras do agente dependem do contexto real.
+