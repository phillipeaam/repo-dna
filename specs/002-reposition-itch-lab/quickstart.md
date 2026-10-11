# Quickstart: Validar a apresentação derivada do audit

**Estado**: método implementado e verificado em 2026-10-07; [tarefas](tasks.md) registram execução. Exemplos/checks controlados estão disponíveis. Não executar códigos de targets. Referências: [modelo](data-model.md), [entrada](contracts/editorial-source.md), [representação](contracts/public-presentation.md), [revisão](contracts/editorial-review.md).

## Pré-requisitos

- Método/runbooks implementados e fixture fictícia sob `tests/fixtures/readonly-audit/presentation-model/`.
- Instruções locais disponíveis; sem conta externa/Notion.
- Para piloto real, audit original selecionado com identidade/schema/baseline e limites. Se ausente, registrar dependência e continuar somente cenários sintéticos.
- Checks do framework recebem apenas fixtures controladas, nunca `target-repos/` ou `analysis-output/` reais.

## Cenários

| Caso | Procedimento somente no registro sintético | Resultado esperado |
|---|---|---|
| A — fonte e seleção | Selecionar público/idioma, claims e lacunas; redigir resumo curto | Origem de 100% das afirmações; uma autoridade; SC-001/003/010 |
| B — dois canais | Representar os mesmos facts em itch.io e canal fictício texto simples com orientações fictícias de voz e adaptação deliberada por público | Zero contradições; limites, ressalvas e personalidade escolhida preservados, adaptações justificadas; SC-002/010 |
| C — atribuição/resultado | Usar contribuição shared/unknown, stack coletiva e resultado not_measured | Nenhuma exclusividade, experiência presumida ou impacto inventado; SC-004 |
| D — mídia bloqueada | Selecionar item permission_unknown por ação e texto independente | Ação dependente bloqueada, texto seguro preservado quando permitido; SC-005 |
| E — revisão/retomada | Aceitar wording e mudar evidência/baseline ou redação material | Stale/invalidação, histórico e revalidação adequada; SC-006 |
| F — pouca evidência/campo obrigatório | Remover detalhe opcional, depois nome/resumo essencial ao canal fictício | Primeiro caso curto e revisável; segundo bloqueado no escopo certo; FR-026 |
| G — privacidade/saída única | Seguir método sem acervo privado e contar registros por produto | Um Markdown, sem execução/publicação/identificador particular; SC-007/009 |
| H — migração | Conferir manifesto privado e correspondência generalizada | 100% dos arquivos selecionados preservados; unrelated intacto; SC-008 |

## Verificações operacionais

Executar `bash tests/publication_format_contract_test.sh` e `bash tests/run.sh --framework`, exclusivamente sobre fixtures. Em 2026-10-07, os 17 checks da suíte passaram, incluindo 15 mutações negativas do novo contrato. O novo check recusou argumento fora da fixture antes de leitura. Guard `python scripts/check-public-context.py` e links locais passaram; o guard não certifica ausência de toda informação privada. Resultados controlados estão na [fixture](../../tests/fixtures/readonly-audit/presentation-model/README.md).

Revisão guiada deve registrar produto/representação, perfil do revisor quando disponível, perguntas, observações e dúvidas. Checar público/canal/estado/gap/rota de fonte e origem/estado das orientações de voz sem consultar segunda base. Perguntar quais escolhas preservam a personalidade e quais adaptações têm justificativa de público/canal; separar avaliação de voz de fidelidade factual. Se realizada somente pelo agente, rotular revisão do agente, sem alegar estudo humano ou tempos.

## Aplicação a um audit selecionado

Selecionar o audit existente e confirmar origem/schema/IDs e limites antes de compor. Não importar obrigatoriamente nem repetir investigação. Preparar conteúdo proporcional no mesmo relatório; configurações, decisões, derivados e lacunas particulares permanecem nesse registro, fora da documentação compartilhável.

Para outro produto, usar o [modelo neutro](../../.agents/skills/repodna-audit/references/presentation-template.md) internamente. Se houver duplicata editorial, conferir informações únicas e histórico antes de retirar a cópia. Declarações de autoria, compatibilidade e impacto continuam limitadas pela evidência. Testes de página já validados pelo usuário não são repetidos nem descritos como execução independente.

Concluir com cobertura/lacunas; exemplos fictícios não provam qualidade de página ou recepção. Conferências históricas de migração são observações do recorte então registrado; acervos privados não são dependência de uso e não são consultados por testes.

## Usar a skill independente

Com caminho: `Use $repodna-itch-format com o audit E:/caminho/relatorio.md. Prepare em inglês e entregue HTML e CSS separados.`

Com contexto: `Use $repodna-itch-format com o audit que acabamos de gerar. Prepare o texto para itch.io.`

Não preencher o modelo manualmente. Caminho explícito prevalece; sem caminho identificar audit único selecionado. Se ambíguo/inacessível, pedir apenas identificação/correção. O audit não chama a composição automaticamente. Verificação controlada usa sample-product.md e contextos declarados, não material real ou conta externa.
