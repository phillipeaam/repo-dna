# Contrato: Prontidão editorial e revisão da superfície de portfólio

## Escopo

Este contrato estende o registro Markdown canônico existente. Prontidão editorial por projeto é uma capacidade disponível quando aplicável. A revisão de site, protótipo ou material visual é condicional à seleção explícita pela pessoa usuária. Ambas aparecem no mesmo arquivo `analysis-output/<safe-product-slug>.md`.

## Entrada opcional

O usuário pode fornecer público/cargos, idioma, canais, competências/provas, restrições de divulgação, decisões visuais aprovadas, inventário comparável e superfície/artefato específico. Cada entrada mantém origem e estado (`confirmed`, `provisional`, `historical`, `conflicting`). Campo omitido, ambíguo ou não comprovado permanece desconhecido; o framework não importa identidade ou decisões de casos de pesquisa.

## Seção editorial por projeto

1. Leitura rápida: contexto, papel/equipe/período quando conhecidos, papel editorial, plataforma/tecnologia, contribuição individual, aderência ao brief, estado público e principal ressalva.
2. Rationale de seleção: papel editorial e confiança; conjunto comparado e critérios quando seleção relativa for solicitada; sem ranking global fora de conjunto explicitamente comparável.
3. História técnica: dimensões de investigação incluem contexto/problema/restrições, contribuição/ownership, mecanismo/decisão/trade-off, evidência, consequência/resultado, colaboração, validação e reflexão. Esta lista é um conjunto de prompts, não sequência, headings ou campos obrigatórios; a prosa e sua ordem são flexíveis e omissões sem suporte permanecem lacunas. Relato pessoal, inferência e hipótese recebem rótulos claros e links para evidência/limites.
4. Pacote de mídia/evidência proporcional ao papel, com lacunas e status de permissão/atribuição visíveis. Para Featured, o inventário desejável acompanha imagem/clipe principal, vídeo curto, 2–4 clipes/GIFs de sistemas, 3–6 screenshots, role/team/duration/platform/tech, 3–5 contribuições, 1–3 desafios, trade-offs, resultado/estado, links públicos e confidencialidade quando pertinente. Distinguir itens disponíveis de itens selecionados; um case publicado recomenda cerca de 4–7 elementos visuais significativos. São metas, não barreiras para documentar/publicar texto factual seguro.
5. Matriz independente para texto, contribuição, resultados, mídia/áudio, permissões, experiência profissional e claims. Uma recomendação não equivale a aprovação.

### Reconstrução quando a memória é limitada

- Gerar uma ou mais interpretações candidatas somente a partir de fontes autorizadas; relacionar evidência favorável/contrária, alternativas, baseline, escopo, confiança qualitativa justificada e o que permanece desconhecido.
- Calibrar confiança pela rubrica de `source-of-truth-markdown.md` e justificar nível com tipo/direção da fonte, corroboração, contradição e escopo. Ausência de suporte significa unknown/unsupported sem nota, não confiança baixa.
- Diferenciar autoria em metadata de commit de evidência de decisão, colaboração, ownership total, comportamento ou resultado. Código pode indicar um mecanismo; não prova motivação pessoal nem benefício de negócio.
- Classificar um resultado de teste só se houver resultado observável; existência de suite/configuração é somente evidência de mecanismo de validação disponível. Declarar cenário, snapshot e ambiente conhecidos.
- Perguntar à pessoa apenas quando a resposta puder mudar materialmente interpretação, atribuição ou wording; não pedir para confirmar detalhes sem rota razoável de recuperação.
- Propostas de 0–3 destaques permanecem rascunhos editáveis/rejeitáveis com procedência original preservada. Sem publicação automática nem metas de contratação.

## Critério observável de leitura rápida

Nos cenários de aceitação, um leitor sem contexto deve localizar produto/contexto e contribuição individual em até 60 segundos. Para ao menos um case, registrar uma rota curta e direta que permita consultar evidências em cerca de 5–10 minutos, sem ler todos os apêndices. Capturar participante/perfil, documento, tarefa, tempo observado e dúvidas; o procedimento não afirma aprovação sem realizar essa avaliação.

## Revisão opcional de superfície

Registrar URL ou artefato, páginas/áreas, dispositivos/viewports e interações realmente observados, método de acesso e limitações. Cobrir posicionamento, narrativa/arquitetura, descoberta, cases/evidências, direção visual/legibilidade, mobile, acessibilidade/interação, contato/conversão e manutenção. Cada dimensão deve ter observação/findings com evidência ou `not_observed`.

Notas de 1 a 5 incluem critério e suporte localizado e são diagnóstico profissional, não pesquisa de usuário, benchmark ou certificação. Findings incluem prioridade P0–P3, impacto, recomendação, esforço, risco/dependência e confiança. Incluir percurso do visitante, fases sugeridas e decisões pendentes no mesmo Markdown. Comparar alternativas abertas nos critérios pertinentes; considerar especificações visuais aprovadas sem codificar um estilo universal. Pesquisa externa limitada registra título, URL e data e separa fonte de julgamento.

## Limites e integridade

- Inspeção somente leitura: não autenticar, submeter formulário, acionar compra/contato, mudar estado, editar ou publicar qualquer superfície.
- Não executar código do alvo nem validar comportamento por execução. Uma viewport não testada não é declarada responsiva; sinais estáticos não são medição.
- Não declarar acessibilidade certificada, conversão, resultado, propriedade, cargo ou permissão sem evidência apropriada.
- Decisões humanas e recomendações provisórias são estados separados. Conflito material fica aberto para posicionamento humano.
- Brief e revisão são opcionais; sua ausência não bloqueia análise de repositório ou prontidão editorial básica.
- Nenhum anexo, relatório, export ou arquivo persistente adicional é produzido.

## Consolidação/aplicação — contrato vigente da revisão 3

Constituição 4.0.0 / FR-021/027–030: um relatório Markdown por produto; audit externo existente explicitamente escolhido permanece canônico com autorização de escrita e destino fora do alvo/Git. Não exigir importação ou segunda cópia. Consolidar material editorial único/histórico, verificar incorporação antes de remover duplicata e atualizar referências. Derivados HTML/CSS solicitados são privados, sem autoridade factual própria, vinculados à versão/decisão/configurações no audit. Estas regras substituem as restrições anteriores de importação obrigatória e proibição de derivados; não autorizam outro relatório, exportador, preview, execução ou publicação. Fatos 2.1.0 e extensão opcional 1.0 permanecem compatíveis. Preservar versões antigas como histórico, separar recomendações de decisões humanas e não usar nota subjetiva como aprovação. Modelo neutro define responsabilidade de blocos; identidade visual continua particular. Validação da página já fornecida pelo usuário não é repetida nem chamada de teste independente.
