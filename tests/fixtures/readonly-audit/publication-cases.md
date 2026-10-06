# Casos sintéticos de reconciliação e publicação

| Item | Fonte/contexto | Classificação ou permissão esperada | Motivo/limite |
|---|---|---|---|
| R1 | Nota antiga diz que app foi criado em 2020; commit atual sustenta manutenção desde 2021 | `historical_superseded` para a data conflitante; manter ambas as fontes citadas | não assumir que commit é início do produto |
| R2 | Documento de um produto sucessor com nome parecido | `distinct_project` | produto não se funde por nome |
| R3 | Processo de portfólio antigo já substituído | `historical_superseded` | conservar somente contexto histórico útil |
| R4 | Nota irrelevante de layout de site para auditoria de código | `irrelevant` | fora do método de repositório |
| R5 | Resumo único de release ainda atual | `incorporated` | incorporar fato com origem e baseline |
| R6 | Explicação de pessoa que esclarece trade-off mas não tem prova no repo | `retained_context` | relato pessoal identificado |
| M1 | Vídeo já publicado, licença/autor não confirmados | Link: unknown; embed: unknown; cópia: unknown; crop: unknown; download/rehosting: unknown; alteração de áudio: unknown | publicação existente não autoriza ação nova |
| M2 | Asset com crédito no arquivo, licença ausente | crédito atribuído; licença e permissão desconhecidas | crédito não é licença nem verificação independente |

Não editar, comentar, apagar ou exportar as fontes de origem. Cada classificação requer referência e justificativa no registro local.
