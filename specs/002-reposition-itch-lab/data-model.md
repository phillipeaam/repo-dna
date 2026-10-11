# Data Model: Seleção e representações no registro canônico

**Versão proposta**: extensão editorial opcional 1.0 sobre o schema factual 2.1.0 da 001. Dados abaixo são subseções/tabelas no Markdown, não objetos JSON persistentes. Facts, IDs e vocabulários existentes permanecem autoritativos.

## Entidades e relações

| Entidade | Campos editoriais | Relação |
|---|---|---|
| Source reference | produto, path/âncora, schema/baseline, estado/limites conhecidos ou unknown | Refere o canônico existente; não copia outra ficha |
| Selection | chave local, público, finalidade, idioma, orientações de voz/referências criativas com origem/estado, itens escolhidos/omitidos, rationale/lacunas, baseline de origem | Muitas seleções no mesmo produto; referências C/F/E/P/K/T/O/R/H pertinentes; orientação criativa não é prova factual |
| Channel profile | chave local, real/fictitious, tipo de página, capacidades/campos obrigatórios/limites, fonte/data ou declaração fictícia | Referência a instrução generalizada; evidência do produto não deriva do canal |
| Representation | chave local, selection_key, channel_key, source_baseline, texto público, metadados sugeridos, mídia selecionada, mapa interno de claims/campos, lacunas | Diferentes representações compartilham a mesma autoridade factual |
| Editorial decision | representation_key, decisão, autor/data conhecidos ou unknown, escopo/motivo, referência à decisão explícita, versão anterior | Histórico no canônico; recomendação do agente não é aceitação humana; confiança factual não é campo editorial modificável |
| Freshness | baseline usada/atual, dependências alteradas, current/stale, razão/próxima ação | Separada de decisão e readiness |
| Readiness | dimensão, estado existente de B4, evidência/condição, ação bloqueada | Texto, contribuição, resultados, mídia/permissões independentes |

Migração privada usa manifesto de origem/path/hash/decisão/classificação, como preservação de entrada de pesquisa; não é ficha pública ou segundo entregável de audit. A correspondência generalizada vive em [migration.md](migration.md).

## Invariantes normativos

- **I01**: `produto, schema e baseline ausentes permanecem unknown e geram lacuna explícita`.
- **I02**: `cada afirmação material tem referência recuperável à fonte no mesmo canônico`; IDs preexistentes não são renumerados, e referências incompatíveis usam a migração da 001.
- **I03**: `público, canal, idioma e finalidade têm origem/estado confirmed, provisional ou unknown`.
  Orientações de voz e referências criativas também conservam origem/estado; sugestão sem brief do autor permanece provisional. Adaptações relevantes registram motivo, sem acrescentar facts ou divulgar fonte privada.
- **I04**: `canal real tem fonte e data; canal fictício tem declaração explícita e não alega compatibilidade real`.
- **I05**: `texto público não contém IDs internos, segredos ou marcadores de trabalho e preserva ressalvas essenciais`.
- **I06**: `decision é draft/accepted/corrected/rejected; freshness é current/stale`; accepted exige referência à decisão humana explícita. Aprovação só é vigente para accepted/current e escopo correspondente, sujeita à matriz de prontidão. Corrected é proposta corrigida até nova aceitação; rejected não é pronta.
- **I07**: `alteração material de baseline, evidência, seleção ou redação marca dependências stale e invalida aprovação afetada`; apenas revisão/revalidação apropriada pode devolver current, sem alterar confiança por redação.
- **I08**: `readiness reutiliza complete, complete_with_conditions, incomplete_blocking, incomplete_nonblocking ou optional por dimensão`; nenhum estado equivale a runtime, permissão jurídica ou publicação.
- **I09**: `mídia conserva permissão por link, embed, cópia/crop, rehosting e áudio, com desconhecidos explícitos`; apenas itens selecionados entram no rascunho, sem copiar assets para outra saída.
- **I10**: `existe exatamente um Markdown persistente por produto, inclusive texto, rastreabilidade e histórico`; não escrever no alvo ou gerar arquivo por canal.

## Transições

| Evento | Decisão / freshness | Registro |
|---|---|---|
| Primeira seleção/representação | draft / current ou stale se fonte afetada | Origem, campos, gaps e mapa de claims |
| Aceitação humana válida | accepted / current | Responsável/data quando conhecidos, motivo/escopo; sem publicar |
| Correção editorial | corrected / stale se material | Wording anterior preservado; revisão necessária |
| Rejeição | rejected / estado de freshness mantido | Motivo/histórico, sem apagar facts |
| Mudança material | Decisão histórica preservada / stale | Aprovação invalidada, dependências e ação de revalidação |
| Revalidação e nova aceitação | accepted / current | Baseline/versão nova e decisão, com evidência de revisão |

Freshness atual não resolve automaticamente lacunas/permissão. Campos essenciais exigidos pelo canal e não sustentados bloqueiam a representação; não criar valor fictício. Conhecimento ausente não significa ausência do atributo.

## Consolidação/aplicação — contrato vigente da revisão 3

Constituição 4.0.0 / FR-021/027–030: um relatório Markdown por produto; audit externo existente explicitamente escolhido permanece canônico com autorização de escrita e destino fora do alvo/Git. Não exigir importação ou segunda cópia. Consolidar material editorial único/histórico, verificar incorporação antes de remover duplicata e atualizar referências. Derivados HTML/CSS solicitados são privados, sem autoridade factual própria, vinculados à versão/decisão/configurações no audit. Estas regras substituem as restrições anteriores de importação obrigatória e proibição de derivados; não autorizam outro relatório, exportador, preview, execução ou publicação. Fatos 2.1.0 e extensão opcional 1.0 permanecem compatíveis. Preservar versões antigas como histórico, separar recomendações de decisões humanas e não usar nota subjetiva como aprovação. Modelo neutro define responsabilidade de blocos; identidade visual continua particular. Validação da página já fornecida pelo usuário não é repetida nem chamada de teste independente.

## Entrada editorial independente — revisão 4

FR-031–035: $repodna-audit investiga; $repodna-itch-format compõe itch.io e usa método/modelo compartilhados internamente. Caminho explícito prevalece, sem fallback silencioso; sem caminho usar audit inequívoco da conversa. Ambiguidade/inacessibilidade pede apenas identificação e insuficiência conserva lacunas, sem reaudit. Entrega e registro seguem pedido no original, preservam históricos/derivados aceitos e distinguem proposta de aprovação/publicação. Perfil do canal pertence à skill editorial; regras genéricas têm referência única. Handoff do audit indica comando, sem composição automática. Nesta implementação, dados reais validados não são usados nem modificados.
