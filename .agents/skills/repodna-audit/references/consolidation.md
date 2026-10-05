# Contrato de consolidação Markdown

Esta referência define a única saída persistente: `analysis-output/<safe-product-slug>.md`, um arquivo por produto. O documento é legível por pessoas e recuperável por agentes. Consulte [evidence-vocabulary.md](evidence-vocabulary.md) para estados e IDs normativos.

## Identidade, destino e integridade

1. Confirmar nome/identidade do produto e relação explícita entre repositórios antes de consolidar. Sem confirmação, manter registros separados e perguntar.
2. Gerar slug previsível e seguro; se o caminho colidir com outro produto ou arquivo existente de identidade incerta, bloquear para escolha explícita. Nunca sobrescrever ou fundir por semelhança de nome.
3. Confirmar que destino não intersecta alvo, Git externo ou submódulo selecionado; o destino continua apenas `analysis-output/`, mesmo quando o restante do checkout é gravável.
4. Criar/atualizar integralmente o mesmo Markdown do produto. Validar estrutura, IDs, links e conteúdo antes de substituir o arquivo. Não produzir anexos, JSON/HTML/CSV, diretórios por sistema, exports Notion ou segundo relatório.
5. Em falha ou bloqueio, registrar estado e causa no documento canônico quando for seguro gravá-lo; não gerar relatório de erro separado.

## Esqueleto estável do registro

```markdown
# <Nome do produto>

> Documento 2.0.0 | Estado: <status> | Atualizado: <date>
> Método: <method-version> | Baselines: <repo@ref, ...>

## Start Here
## At a Glance
## Study Map
## Prontidão editorial do projeto
### Brief e papel editorial
### Quick scan e relevância
### Case(s) e rota de evidências
### Pacote de mídia e claims
### Matriz de prontidão editorial
## Revisão opcional da superfície do portfólio
## Identidade e contexto
## Papel, equipe e contribuições
## Sistemas e arquitetura
## Decisões e trade-offs
## Timeline e releases
## Projeção pública e claims
## Evidências e índice
## Cobertura e estado das etapas
## Questões, conflitos e bloqueios
## Apêndices
### A1 — Forense
### B1 — Produção e arquitetura
### B2 — Runtime estático
### B3 — Release e procedência
### B4 — Publicação e créditos
### Reconciliação de fontes
## Histórico de verificação
```

Novos documentos usam schema 2.0.0. Ao atualizar registro 1.0.0, preservar IDs, fontes e histórico recuperáveis, migrar no mesmo Markdown e documentar o mapeamento/gaps no histórico. Seções editoriais/superfície ausentes significam não avaliadas, não aprovação. Nunca gerar cópia paralela para migração.

Headings são estáveis para consulta; mudança da versão do contrato registra migração e compatibilidade. Se uma seção não se aplica, registrar `not_applicable` e motivo em vez de removê-la silenciosamente.

## Regras de conteúdo e evidência

- Cada finding relevante tem ID `F-###`, tipo de conclusão, baseline, escopo/tempo, confiança justificada, limitações e referências `E-###` recuperáveis.
- Cada claim pública tem ID `C-###`, wording proporcional, estado e evidências; relatos pessoais ficam rotulados.
- Questões e decisões em aberto usam `Q-###`, estado, responsável quando conhecido e próxima evidência/ação necessária.
- Tabelas resumem matrizes; apêndices guardam detalhes e não substituem respostas atuais visíveis no início/core.
- Paths e URLs incluem contexto para revalidar a fonte. Não incorporar código grande, segredos, dados pessoais ou material não autorizado.
- Produtos distintos ficam em Markdown distintos. Trabalho ou pacote compartilhado recebe identidade estável e links para cada repo/baseline, mas conta como uma contribuição consolidada.
- Atualizações preservam histórico identificável, marcam conclusões afetadas como stale e registram baseline anterior/nova, decisões modificadas e checkpoints superados.
- A única saída é o Markdown canônico. Estado de sessão é efêmero e descartável; não há arquivo auxiliar persistente entregue.

## Autoridade e reconciliação

Manter uma resposta atual por tema. Fontes antigas são classificadas como `incorporated`, `retained_context`, `distinct_project`, `historical_superseded` ou `irrelevant`, sempre com origem e motivo. Conflitos permanecem visíveis até resolução sustentada. Uma sugestão para limpar fonte externa nunca executa a limpeza.

## Baseline e declaração de preservação

O primeiro registro inclui `## Baseline e preservação` com identidade/caminhos canônicos dos alvos e Git associado, repos/refs/HEAD, estado tracked/untracked/ignored, instante, estado de proteção do host (`enforced`, `unverified` ou `unknown`), método de inventário e cobertura/limites. Estado preexistente fica separado de alterações concorrentes ou posteriores.

No fechamento, atualizar a mesma seção com comparação final por categoria, divergências, arquivos/famílias não cobertos e estado `verified`, `observed_unchanged`, `changed`, `partial` ou `inconclusive`. `git status` isolado não basta. `verified` exige enforcement efetivo comprovado e cobertura de comparação suficiente; sem enforcement, mesmo sem divergências, registrar apenas `observed_unchanged` no escopo comparado, nunca `verified` como garantia preventiva.

## Histórias de engenharia e talking points

História de engenharia usa problema → restrição → abordagem → trade-off → resultado → evidência. Cada trecho separa o que o snapshot comprova, a inferência e o contexto pessoal; motivação/resultado sem suporte fica como lacuna ou relato atribuído.

Talking points priorizam contribuição tecnicamente relevante e recuperável. Cada ponto traz `C-###`/`F-###` e `E-###`, baseline, limite e formulação segura. Não exigir quantidade fixa nem preencher lacunas pessoais. O agente sugere wording; a pessoa revisa a própria narrativa antes de qualquer uso externo.

## Hierarquia e reconciliação de fontes

A força da fonte depende do tipo de claim:

| Tipo de claim | Evidência preferida | Limite |
|---|---|---|
| Comportamento/estrutura no snapshot | Arquivo/configuração e referência de baseline | Não prova execução nem versão pública |
| Contribuição/autoria | Identidade confirmada e diff/histórico por sistema | Proxies de atividade não provam ownership |
| Release/publicação | Binário/hash ou destino correlacionado à fonte/ref | Tag/data aproximada não fecha correlação |
| Crédito/licença/permissão | Licença/termo e atribuição aplicáveis ao asset/ação | Crédito não é autorização jurídica |
| Motivação/resultado pessoal | Relato explícito da pessoa | Permanece `personal_account`, salvo apoio independente |

Citar cada fonte com data/snapshot quando disponíveis. Para conflito, conservar afirmações e escopo de cada fonte; preferência exige justificativa por claim e validade temporal. Fonte recente não supersede automaticamente uma antiga fora do seu escopo. Classificar todo item externo relevante como `incorporated`, `retained_context`, `distinct_project`, `historical_superseded` ou `irrelevant`, registrar origem e motivo, e nunca editar a origem.

## Migração de evidência legada

Antes de reaproveitar material legado, registrar origem, versão/schema, baseline e significado dos campos. Mapear explicitamente somente estados semanticamente compatíveis. Manter rótulos de heurística como pistas; não elevar `possible_use`, score, confiança implícita ou ausência de medição a finding verificado. Se proveniência/semântica não puderem ser determinadas, manter `not_verified` ou recusar a migração com motivo e evidência necessária. Não reescrever a fonte externa.

A migração atualiza o mesmo arquivo canônico, mantém a proveniência e uma nota histórica do mapeamento/recusa; não cria relatório legado paralelo.

## Prontidão editorial do projeto e superfície opcional

Quando aplicável, registrar brief com origem/estado por campo, contexto do projeto separado do papel editorial, recomendação separada de decisão humana e rationale de comparação. Sem conjunto explícito comparável, não declarar ranking. Preservar Featured candidate, Strong supporting, Supporting/Technical, Archive/Playground e unclassified sem exclusão automática. O quick scan mostra identidade/contexto, papel/equipe/período, stack, contribuição, relevância, estado público e ressalva e liga ao case.

Case usa contexto → ownership → problema → restrições → abordagem → trade-offs → evidência → resultado → reflexão, deixando lacunas. Inventário Featured acompanha imagem/clipe principal, vídeo curto, 2–4 clipes/GIFs, 3–6 screenshots, role/team/duration/platform/tech, 3–5 contribuições, 1–3 desafios, trade-offs, resultado/estado, links e confidencialidade. Separar disponibilidade da seleção; publicação recomenda 4–7 itens visuais significativos. Pacote não é gate.

A seção de superfície só aparece após seleção explícita de site/protótipo/design. Registrar fonte, páginas, viewports e interações realmente vistos. Usar uma linha por cada dimensão/subdimensão de `positioning`, `narrative-information-architecture`, `discovery-grouping`, `cases-evidence`, `visual-readability`, `mobile-reflow`, `tablet-reflow`, `reading-order`, `touch-targets`, `keyboard-navigation`, `focus-visibility`, `accessible-names`, `semantic-structure`, `contrast`, `reduced-motion`, `animated-media-controls`, `contact-conversion`, `maintenance-consistency`, `unavailable-media` e `performance`; cada linha recebe finding fundamentado ou `not_observed`, evidência/localização e limite. Falhas de mídia só são registradas quando diretamente observáveis. Performance aceita apenas sinais estáticos observados sem execução ou medições já existentes/fornecidas com sua proveniência; não iniciar teste de carregamento, profiler, benchmark ou execução do alvo. O scorecard inclui status e, quando aplicável, nota/critério/confiança, evidência, impacto e limite. O registro também contém resumo executivo, percurso do visitante, findings priorizados, arquitetura/direção recomendada, gaps de conteúdo/evidência, plano por fases, decisões/perguntas pendentes e limitações. Recomendações apontam evidência e não equivalem a decisão/aprovação. Nota 1–5 tem critério/localização e é diagnóstico profissional. Finding inclui prioridade P0–P3, impacto, recomendação, esforço, risco/dependência e confiança. Não autenticar, submeter, acionar conversão, editar ou publicar; indisponibilidade não bloqueia análise de conteúdo.
