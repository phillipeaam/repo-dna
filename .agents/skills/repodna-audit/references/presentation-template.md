# Modelo neutro de apresentação

## Propósito e limites

Transformar um audit existente em apresentação para um público/canal, mantendo fatos e decisões no mesmo relatório. Entrada: identidade, evidências, versão, público, idioma e orientação do autor. Saída: seleção e representação proporcionais; aplicação visual opcional por pedido. Sem reaudit, catálogo, publicação, teste do jogo ou estética universal. Seguir [presentation-format.md](presentation-format.md) para procedência, estados e falhas.

## Responsabilidades dos blocos

| Bloco | Finalidade | Origem dos dados | Quando usar | Quando omitir | Cuidados |
|---|---|---|---|---|---|
| Acesso nativo | Permitir iniciar/obter o produto | Destino/artefato e capacidades documentadas | Acesso sustentado e disponível no canal | Acesso desconhecido ou ação nativa já suficiente | Não simular botão, prometer suporte ou confundir build local com publicação |
| Controles | Explicar ações necessárias | Inputs documentados/observados e confirmação atribuída | Inputs conhecidos, especialmente não óbvios | Produto sem inputs ou controle já explicado suficientemente | Distinguir ações, falhas e requisitos; não inventar dispositivo |
| Apresentação | Comunicar experiência e diferencial | Identidade/claims/mecanismos sustentados e voz do autor | Há resumo útil sustentado | Omitir somente aspectos sem suporte | Uma abertura concreta; não inventar história, promessa ou intenção |
| Mecânicas | Explicar progressão/decisões | Findings estáticos e evidências tipadas | Ajudam a compreender a experiência | Resumo já suficiente ou mecanismo desconhecido | Explicar consequências ao jogador; evitar repetir os inputs |
| Contexto | Situar criação, evento ou estado | Timeline, registros de evento, relatos atribuídos | Acrescenta sentido para o público | Sem fonte ou irrelevante ao destino | Distinguir época/versão e coletivo/individual; relato pessoal opcional |
| Créditos | Reconhecer participantes | Roster/créditos e links fornecidos | Participantes identificados | Omitir apenas funções/identidades sem suporte | Não inventar cargos, autoria exclusiva ou completude; crédito não é licença |
| Links | Conectar a contexto ou acesso | URL fornecida/documentada com origem | Destino relevante e coerente | Redundante, desconhecido ou inadequado | Rótulo descritivo; distinguir link fornecido de disponibilidade verificada |
| Mídia | Mostrar experiência e contexto | Inventário, conteúdo demonstrado e permissão por ação | Ajuda a demonstrar uma claim | Não acrescenta informação ou ação sem permissão | Disponibilidade não autoriza cópia; ordem sugerida não vira decisão aprovada |

## Composição e personalidade

Escolher blocos, ordem e extensão conforme projeto/canal. A ordem deve acompanhar as necessidades do visitante e as capacidades do canal, sem sequência universal. Cor, fonte, caixas e ritmo visual pertencem à aplicação. O texto deve conservar significado sem CSS. Usar as referências datadas do [canal itch.io](../../repodna-itch-format/references/channel-itch.md) e apoio já registrado na pesquisa; outra loja exige capacidades próprias.

Passar de código/evidência a linguagem pública: identificar a ação do jogador, sua consequência sustentada e o que a diferencia. Em um exemplo fictício, uma regra estática que desbloqueia uma passagem após coletar uma chave pode virar “Encontre a chave para abrir uma nova passagem”. Não acrescentar “equilíbrio perfeito” ou recepção medida. IDs, baseline, unknown e limites da análise ficam na matriz interna; ressalvas essenciais ao significado ficam compreensíveis para o visitante.

Eliminar repetição por função: controles dizem como agir; apresentação descreve a experiência; mecânicas explicam progressão; contexto situa criação. Não preencher todas as seções por obrigação. Dado faltante gera omissão/lacuna, nunca conteúdo inventado.

## Esqueleto preenchível no único audit

```markdown
### Seleção editorial
- Fonte canônica, schema, baseline e limites:
- Público / finalidade / canal / idioma:
- Voz e referências do autor, origem e estado:
- Blocos escolhidos e ordem, com motivo:
- Omissões e lacunas:

### Representações por canal
#### [chave e versão] — [draft/accepted/corrected/rejected] / [current/stale]
Referência da decisão humana e escopo, ou unknown:

Texto público (usar somente blocos úteis):
[Abertura concreta e experiência]
[Controles conhecidos]
[Mecânicas/progressão sem repetir controles]
[Contexto relevante e sustentado]
[Créditos e links]

Matriz interna: trecho → claim/finding → evidência recuperável → natureza/baseline/limite.
Metadados, ações nativas e mídia: separados; permissões e campos pendentes explícitos.

#### Aplicação visual, quando solicitada
- Versão de conteúdo aplicada:
- Arquivos derivados privados e hashes:
- Fonte/tamanho no tema versus overrides CSS:
- Paleta, layout e mídia: escolhas aprovadas versus recomendações:
- Validação fornecida: responsável/referência/escopo; não inferir publicação:
- Histórico das versões anteriores e dependências afetadas:
```

## Exemplo e conclusão

O exemplo controlado [Farol de Papel](../../../../tests/fixtures/readonly-audit/presentation-model/sample-product.md) demonstra fatos limitados e canais distintos, sem aplicação visual obrigatória. Exemplos reais selecionados pelo autor ficam em seus relatórios privados, sem copiar dados para esta referência ou testes. Para um próximo projeto, selecionar o audit único, preencher o brief, escolher blocos sustentados, redigir, adaptar ao canal e registrar a versão validada. Notas subjetivas não substituem esses critérios.

Concluir com fonte única, texto atual, decisões recuperáveis e derivados opcionais ligados à representação; lacunas factuais continuam visíveis. Fonte inacessível/contradição/campo essencial ausente bloqueiam somente a parte dependente conforme o runbook.
