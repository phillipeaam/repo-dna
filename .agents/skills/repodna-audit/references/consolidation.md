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

> Documento <schema-version> | Estado: <status> | Atualizado: <date>
> Método: <method-version> | Baselines: <repo@ref, ...>

## Start Here
## At a Glance
## Study Map
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
