# Research: Modelo de apresentação de projetos a partir de audits

**Data**: 2026-10-06 | **Escopo**: decisões de planejamento, sem execução/publicação.

## D01 — Reutilizar a autoridade factual da 001

**Decision**: Consumir canônico 2.1.0 e referências C/F/E/P/K/T/O/R/H existentes; seleção e representações ficam no mesmo arquivo.
**Rationale**: Constituição IV e contratos [entrada/saída](../001-readonly-audit-framework/contracts/input-output.md), [fonte de verdade](../001-readonly-audit-framework/contracts/source-of-truth-markdown.md) e [prontidão](../001-readonly-audit-framework/contracts/portfolio-readiness.md) já definem facts, claims, atribuição e narrativa. O delta é a apresentação por canal.
**Alternatives considered**: Ficha JSON de conteúdo/professional_context, catálogo e pipeline de HTML importados: rejeitados por duplicação e incompatibilidade com fonte única.

## D02 — Separar informação comum de forma editorial

**Decision**: Núcleo com premissa, experiência, acesso/contexto/créditos/limites; conteúdo técnico opcional por público. Não impor headings, narrativa completa ou identidade visual.
**Rationale**: FR-078–090/114–127 da 001 permitem profundidade proporcional e dimensões narrativas flexíveis. Informação suficiente para jogador e prova profissional são necessidades diferentes.
**Alternatives considered**: Usar uma página de jogo como layout universal; exigir todos os campos/histórias/mídias: rejeitados por inventar simetria e aumentar esforço sem evidência.

## D03 — Perfil itch.io baseado em fontes oficiais

**Decision**: Separar descrição de metadados, screenshots/trailer, downloads/execução e comunidade nativos; orientar controles, créditos, requisitos e estado quando pertinentes. Não duplicar controles sem necessidade.
**Rationale/source**: [Designing your page](https://itch.io/docs/creators/design), consultado em 2026-10-06. Sugestões de seções são orientação, não headings obrigatórios para todo projeto.
**Alternatives considered**: Recriar o site/controles em prévia: fora do propósito e não demonstra funcionamento real.

## D04 — Representação fiel e plataforma comprovada

**Decision**: Metadados, idiomas, plataformas e mídia devem refletir o produto; texto pronto não comprova execução. Não transformar tag/engine observada em autoria ou compatibilidade presumida.
**Rationale/source**: [Content creator quality guidelines](https://itch.io/docs/creators/quality-guidelines), consultado em 2026-10-06: classificações pertinentes, conteúdo não enganoso, screenshots quando aplicáveis, plataformas/idiomas corretos. Audit estático não realiza o teste de plataforma; usa resultado externo fornecido e limitado ou registra lacuna.
**Alternatives considered**: Preencher metadados para descoberta sem suporte, deduzir suporte pelo engine: rejeitados.

## D05 — Texto simples como base portável

**Decision**: O MVP produz texto no Markdown canônico; não entrega HTML/CSS. Destino fictício aceita só texto simples, sem mídia/controles nativos, e exige nome/resumo; demais campos opcionais, sem limite numérico arbitrário.
**Rationale/source**: [CSS Customization Guide](https://itch.io/docs/creators/css-guide), consultado em 2026-10-06: HTML é limitado e pode ser reescrito pelo editor; classes próprias têm prefixo `custom-`; CSS depende de habilitação e deve preservar UI/acessibilidade. Essas capacidades não serão presumidas nem implementadas. Nenhuma fonte consultada define limite universal de palavras/caracteres ou blocos de descrição.
**Alternatives considered**: CSS como dependência, copiar markup entre lojas, presumir capacidade da conta: rejeitados. Segunda loja real será pesquisada quando escolhida.

## D06 — Revisão editorial independente de evidência e publicação

**Decision**: Registrar decisão e freshness separados; mudança material invalida aprovação afetada; mídia bloqueada não bloqueia texto seguro independente.
**Rationale**: Reutilizar B4 e prontidão da 001; revisão humana altera wording, não a natureza/confiança das fontes. Aprovação é local e não aciona envio.
**Alternatives considered**: Um único ready para texto/build/permissão/site: rejeitado por equivalência falsa.

## D07 — Preservar e retirar o contexto particular

**Decision**: Inventário/hash individual privado, cópia verificada antes da retirada; documentos da 002 reescritos; asset rastreado não relacionado mantido.
**Rationale**: [privacidade/autoridade](../001-readonly-audit-framework/contracts/privacy-local-authority.md); fontes privadas são opcionais e não entram em fixtures/distribuição. [migration.md](migration.md) registra o aprendizado sem detalhes particulares.
**Alternatives considered**: Apagar material único sem preservar, deixar fontes pessoais no framework ou substituir README geral pelo README importado: rejeitados.

## D08 — Compatibilidade e validação

**Decision**: Extensão editorial opcional 1.0 no canônico factual 2.1.0, mantendo headings/IDs; validar cenários sintéticos e revisão guiada, sem promessa de resultado comercial ou compreensão medida.
**Rationale**: Contratos locais exigem migração explícita e fonte única; headings criados não significam capacidade validada. Sem audit real, planejamento e cenário fictício prosseguem.
**Alternatives considered**: Novo schema factual/fonte paralela ou bloquear spec por fonte particular ausente: desnecessários.

## D09 — Referências da indústria e seus limites

**Decision**: Usar fontes primárias como apoio à análise, registrando finalidade, data e limite de aplicação. Regras do destino, recomendações editoriais e escolhas criativas têm autoridades diferentes; recomendação de outra loja não vira requisito universal.

| Fonte consultada em 2026-10-06 | Aplicação no modelo | Limite |
|---|---|---|
| itch.io — design, qualidade e CSS (D03–D05) | Capacidades e orientações do canal MVP | Distinguir exigência de sugestão; não presumir capacidades da conta |
| [Steamworks — Store Page Written Description](https://partner.steamgames.com/doc/store/page/description?l=english) | Apoio à clareza: descrever experiência específica com palavras próprias, resumo útil, leitura escaneável e linguagem compreensível ao público | Fonte sobre Steam; suas restrições de campos/links não se aplicam automaticamente ao itch.io. Não acrescenta adaptador Steam ao MVP |
| [IGDA — Game Crediting Guidelines 10.1, março de 2023](https://igda.org/wp-content/uploads/2021/11/IGDA-Game-Crediting-Guidelines-10.1-March-2023.pdf) | Apoio à revisão de créditos: inclusão de participantes e atribuição do trabalho, sem apagar contribuição compartilhada | Guia de recomendações; não prova contribuição de um projeto nem resolve permissão jurídica |
| [GDC 2010 — Getting Noticed: Why You Need an Online Portfolio and How to Make One](https://www.gdcvault.com/play/1012377/Getting-Noticed-Why-You-Need) | Contexto histórico sobre apresentar trabalho e demonstrar habilidades no portfólio | Consultada apenas a sinopse pública; vídeo/slides não analisados. Não estabelece padrão atual de contratação ou garantia de resultado |

**Rationale**: Fontes sustentam decisões delimitadas, sem alegar consenso ou cobrir toda a indústria. A aplicação conjunta ao framework é síntese editorial desta feature, sujeita à revisão por público/projeto.
**Alternatives considered**: Usar páginas de terceiros como norma, transferir todas as regras Steam ou tratar palestra antiga como evidência atual: descartados.

## D10 — Preservar personalidade com clareza factual

**Decision**: Registrar na seleção as orientações de voz do autor e suas referências, com origem/estado. Preservar tom, vocabulário, humor, atmosfera e ritmo pertinentes, podendo adaptar extensão/ênfase ao público. Sem orientação, propostas ficam provisórias. Toda afirmação material continua sujeita ao audit.
**Rationale**: Clareza, atribuição e restrições do canal podem ser verificadas sem homogeneizar a escrita. A documentação Steamworks admite descrição em palavras próprias e estratégia adequada ao produto; a proteção explícita da voz é requisito do usuário nesta feature, não regra universal atribuída às fontes.
**Validation**: Cenário B compara representações com adaptação deliberada de voz, mantendo fatos/ressalvas e registrando as escolhas; SC-010 revisa essas escolhas. Não exigir slogan, humor, primeira pessoa ou linguagem comercial.

## Questões remanescentes

Nenhum NEEDS CLARIFICATION obrigatório. Seleção do audit real e pesquisa de segunda loja real são dependências futuras, registradas no plano; não são fatos concluídos.

## D11 — consolidação e aplicação solicitadas, 2026-10-07

Pedido humano supera exclusão de HTML/CSS do MVP inicial: derivados de aplicação opcionais sem fonte factual paralela. Manter audit externo escolhido evita duplicação. Emenda IV 4.0.0 e revisão 3 registram compatibilidade/migração; esquema factual/IDs e fontes D03–D10 permanecem. Fonte/tamanho da loja versus CSS são escolhas distintas; documentação já consultada não enumera Size, portanto não inventar opção. Sem pesquisa adicional necessária para registrar decisões existentes.

## D12 — entrada editorial independente, 2026-10-07

Separar skill audit de skill itch-format torna o método chamável sem formulário manual. Preservar referência genérica única; mover somente perfil de canal. Descoberta normal da skill continua, sem execução encadeada pelo audit. Fontes oficiais existentes são reutilizadas, sem nova pesquisa de capacidades nesta mudança estrutural. Exemplos reais permanecem privados e intactos.

## D13 — documentação neutra, 2026-10-07

O método compartilhável independe de um projeto real. Contexto de aplicações e acervos fica no respectivo registro privado; exemplos do framework são fictícios ou placeholders. Preservar fontes profissionais, capacidades datadas e resultados de verificação com limites, sem decisões criativas obrigatórias. Nenhuma nova pesquisa externa necessária para esta revisão de documentação.
