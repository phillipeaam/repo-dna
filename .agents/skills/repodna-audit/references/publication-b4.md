# B4 — Publicação, claims, créditos e mídia

## Propósito e limite

Avaliar suporte factual e prontidão editorial de material potencialmente público. Isto não concede licença, autorização jurídica ou autorização do usuário para publicar. A saída permanece no Markdown local e fontes externas são somente leitura.

## Texto e claims

Para cada claim `C-###`, registrar wording, audiência, evidências `E-###`, snapshot/escopo, estado (`safe`, `qualified`, `internal_only`, `unsupported`, `rejected`) e caveat. Separar fato do repositório, inferência e relato pessoal. Conservar lista de claims a evitar sem nova evidência (ownership exclusivo, liderança, impacto, métricas e release).

## Créditos e mídia

Por asset: origem e versão/era, criador atribuído versus verificado, integração técnica, terceiros visíveis/audíveis, crédito presente, licença/fonte, claim demonstrada, legenda sugerida e limites. Avaliar permissões independentemente para link, embed, cópia, crop, download/rehosting e alteração de áudio. Publicação atual não implica permissão para outra ação. Ausência de licença fica desconhecida, nunca autorizada por padrão.

## Readiness por dimensão

Separar texto, links, imagens, vídeo, áudio e quantitativos. Cada linha usa `complete`, `complete_with_conditions`, `incomplete_blocking`, `incomplete_nonblocking` ou `optional`, com evidência, condição e próxima ação. Uma mídia bloqueada não bloqueia automaticamente texto factual seguro; conclusão da auditoria não é aprovação humana.

## Reconstrução de engenharia e prompts editoriais (US14)

Ao transformar findings em uma história, use dimensões opcionais: contexto/problema/restrições, contribuição/ownership, mecanismo, decisão/trade-off, consequência, colaboração, validação, resultado e reflexão. Escolha a ordem e forma de prosa que melhor preservam entendimento e evidência; estes itens não são headings, campos mandatórios nem checklist de preenchimento. Não force storytelling quando as fontes sustentam apenas um registro técnico curto.

Cada afirmação material de R-###/H-### conserva referência e localização de evidência, baseline/escopo, tipo, relação de suporte, limite, confiança justificada e alternativas quando relevantes. Diferencie autoria registrada de decisão, colaboração, validação e resultado; consequência técnica observável não é benefício/impacto medido. Hipótese e wording sugerido ficam draft; aceitação/correção/rejeição mantém procedência. Destaques são de zero a três, breves e proporcionais à evidência. Sem fonte ou memória recuperável, mantenha unknown ou personal_account atribuído, sem completar narrativa por plausibilidade.
## Saída e checkpoint

Claims e readiness entram no registro canônico com IDs e evidências. Recomendação editorial pode ser feita; publicação, alteração ou upload são fora do escopo.

## Prontidão editorial proporcional e inventário Featured

Separar contexto do projeto, papel editorial e estado da decisão. Conjunto não comparável não recebe ranking global. Cada claim pública mantém evidências, snapshot e caveat; recomendações e responsabilidades profissionais são atribuídas à fonte.

Para Featured, inventariar como metas desejáveis: imagem/clipe principal; vídeo curto; 2–4 clipes/GIFs de sistemas; 3–6 screenshots; role/team/duration/platform/tech; 3–5 contribuições; 1–3 desafios; trade-offs; resultado/impacto/estado final; links públicos e confidencialidade quando necessária. Separar itens disponíveis dos selecionados. Case publicado recomenda 4–7 elementos visuais significativos. Supporting/Technical e Archive/Playground recebem pacote mais leve e continuam no inventário.

Cada mídia declara a claim/comportamento demonstrado e distingue captura real, diagrama, proxy e placeholder. Proveniência, era, autoria, terceiros, legenda e permissões são registradas por ação. Falta de autorização deixa o item como lacuna, sem bloquear texto factual seguro.

## Apresentação por público e canal (feature 002)

Seguir [presentation-format.md](presentation-format.md) e o perfil
[itch.io](../../repodna-itch-format/references/channel-itch.md) para derivar representações dos fatos de B4. Seleção,
texto e rastreabilidade permanecem no canônico. Inventário Featured acima é
contexto opcional de portfólio; não impõe pacote, headings, sequência ou estética
à apresentação por canal. Voz orientada pelo autor e dados sustentados governam
a composição proporcional.

Avaliar texto, ownership/contribuição, resultados, mídia/permissões e campos
essenciais separadamente, reutilizando complete, complete_with_conditions,
incomplete_blocking, incomplete_nonblocking e optional. Mídia permission_unknown
bloqueia só a ação dependente; texto seguro independente continua revisável.
Execução externa e estado público observado são dimensões independentes.
Accepted exige decisão humana explícita; aprovação não é confiança factual,
licença, runtime ou publicação. Mudança material de baseline/evidência/seleção/
redação/canal invalida aprovação afetada e marca stale até revalidação, com
versão anterior preservada. Não escrever/rodar alvo ou enviar conteúdo externo.

## Consolidação editorial e aplicação — revisão vigente

Para apresentação de audit existente, o destino original explicitamente escolhido pode permanecer canônico; não copiar obrigatoriamente para analysis-output/. A regra de saída única significa um relatório factual por produto. Derivados HTML/CSS explicitamente solicitados são arquivos privados de aplicação, não relatórios; registrar sua versão/configuração e decisão no mesmo audit. Novos audits continuam no destino padrão; os derivados dependem de pedido explícito. Seguir [modelo neutro](presentation-template.md) e manter fatos/IDs/histórico. Não escrever/executar no alvo, publicar ou repetir testes da página já validados pelo usuário.
