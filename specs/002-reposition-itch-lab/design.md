# Design: Forma editorial derivada do audit

**Estado**: desenho vigente da revisão 3, com método e modelo neutro implementados. Ver [modelo](data-model.md) e contratos.

## Fluxo

1. Confirmar produto, registro, versão/baseline e limites; source incompatível recebe gap/migração pela 001.
2. Selecionar público/finalidade/idioma/canal, claims e itens de mídia; registrar omissões e lacunas no mesmo canônico.
3. Consultar capacidades datadas do destino e mapear descrição/metadados/mídia/ações nativas. Canal fictício declara suas regras sem simular loja real.
4. Redigir a menor apresentação útil, em ordem livre, mantendo ressalvas. Associar cada afirmação material à rota factual internamente.
5. Revisar evidência/atribuição, limites do destino, confidencialidade e prontidão por dimensão; registrar decisão, freshness e condições.
6. Retomar após mudança: revalidar dependências afetadas, preservar versão anterior e não confundir aprovação com estado publicado.

## Divisão de responsabilidades

- A1/B1/B2/B3/B4 e contratos 001 produzem/qualificam fatos; a 002 não refaz investigação nem autoridade factual.
- Runbook `presentation-format.md` orienta seleção e revisão; `presentation-template.md` define blocos e esqueleto; `channel-itch.md` orienta adaptação.
- Fonte factual, seleção e representação são camadas lógicas do mesmo Markdown, não três arquivos.
- Texto público fica delimitado da matriz interna de evidências. Claims omitidas continuam no audit, com seu estado; não são apagadas para facilitar copy.
- Componentes, cores e fontes da loja não fazem parte de um design visual universal. Texto deve ser compreensível sem CSS próprio.

## Mapa de conteúdo

| Tema | Para jogador | Para avaliação profissional |
|---|---|---|
| Identidade/contexto | Experiência e estado conhecido | Produto, equipe/período conhecido e relevância |
| Comportamento | Ação/objetivo sustentados | Mecanismo demonstrado, não intenção presumida |
| Acesso | UI nativa, controles/requisitos úteis | Amostra e condições de inspeção |
| Contribuição | Créditos corretos | P→K→O/T/E sustentado, autoria compartilhada explícita |
| Resultados | Limites úteis | Resultado observado versus impacto/benefício hipotético |
| Mídia | Demonstra produto com permissão | Demonstra claim específica com procedência |

Dimensões são opcionais por relevância/suporte. Não impor quantidade de seções ou narrativas. Omitir claim sem suporte ou qualificá-la; informação essencial desconhecida pode bloquear a representação, não inventar conteúdo.

## Personalidade e práticas recomendadas

Na seleção, registrar orientações do autor sobre tom, vocabulário, humor, atmosfera e referências criativas, com origem e estado confirmado/provisório/desconhecido. Ausência de orientação gera proposta provisória; não inferir intenção do autor. Não copiar material privado para exemplos públicos.

Aplicar três critérios distintos: regras documentadas do canal governam suas capacidades; recomendações das [fontes de apoio](research.md) orientam clareza, especificidade e créditos; escolhas criativas do autor governam a voz. Registrar razão de adaptações relevantes, preservando significado e ressalvas factuais. Um texto pode ser lúdico, sóbrio, experimental ou direto conforme o projeto, sem formato ou linguagem comercial obrigatórios.

A revisão compara representações dos mesmos fatos com escolhas de voz explícitas: localizar orientação/origem, verificar sua preservação e identificar ajustes exigidos pelo público/canal. Coerência factual e adequação à voz são avaliações separadas; a segunda não certifica recepção do público.

## Armazenamento e compatibilidade

Acrescentar dentro de `## Projeção pública e claims` subseções `### Seleção editorial` e `### Representações por canal`; manter matriz/histórico no mesmo documento. Extensão opcional `presentation_version: 1.0`; fatos permanecem schema 2.1.0. Registros antigos sem essa área permanecem legíveis e recebem editorial not_observed, sem aprovação automática.

Referências a entidades usam IDs existentes e âncoras do mesmo documento. Não acrescentar banco, API, catálogo, relatório HTML/CSS, relatório por canal ou nova família de IDs factuais. Derivados privados solicitados aplicam a versão registrada. Chaves editoriais são locais, só identificam seleções/representações.

## Limites

Não autenticar, publicar, jogar, testar builds nem reproduzir materiais privados em fixtures. Resultado externo fornecido pode ser consultado com limites; preparação editorial não inicia sua produção. Método público não depende do acervo preservado. Comparação de duas versões verifica coerência editorial; não prova experiência de visitantes ou renderização real da loja.

## Consolidação/aplicação — contrato vigente da revisão 3

Constituição 4.0.0 / FR-021/027–030: um relatório Markdown por produto; audit externo existente explicitamente escolhido permanece canônico com autorização de escrita e destino fora do alvo/Git. Não exigir importação ou segunda cópia. Consolidar material editorial único/histórico, verificar incorporação antes de remover duplicata e atualizar referências. Derivados HTML/CSS solicitados são privados, sem autoridade factual própria, vinculados à versão/decisão/configurações no audit. Estas regras substituem as restrições anteriores de importação obrigatória e proibição de derivados; não autorizam outro relatório, exportador, preview, execução ou publicação. Fatos 2.1.0 e extensão opcional 1.0 permanecem compatíveis. Preservar versões antigas como histórico, separar recomendações de decisões humanas e não usar nota subjetiva como aprovação. Modelo neutro define responsabilidade de blocos; identidade visual continua particular. Validação da página já fornecida pelo usuário não é repetida nem chamada de teste independente.

## Entrada editorial independente — revisão 4

FR-031–035: $repodna-audit investiga; $repodna-itch-format compõe itch.io e usa método/modelo compartilhados internamente. Caminho explícito prevalece, sem fallback silencioso; sem caminho usar audit inequívoco da conversa. Ambiguidade/inacessibilidade pede apenas identificação e insuficiência conserva lacunas, sem reaudit. Entrega e registro seguem pedido no original, preservam históricos/derivados aceitos e distinguem proposta de aprovação/publicação. Perfil do canal pertence à skill editorial; regras genéricas têm referência única. Handoff do audit indica comando, sem composição automática. Nesta implementação, dados reais validados não são usados nem modificados.
