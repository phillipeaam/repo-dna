# Casos de recuperação por agente

Use somente `sample-product.md`, um registro sintético. O revisor envia cada pergunta a um agente com apenas esse Markdown. Cada resposta factual precisa citar os IDs de evidência referidos no registro; para o caso sem suporte, a resposta esperada é explicitamente desconhecida.

| Caso | Pergunta | Resposta esperada | Evidência exigida |
|---|---|---|---|
| R1 | Qual é a identidade do produto e qual baseline foi analisada? | Produto Fixture Atlas, baseline `repo-a@abc123`, snapshot sintético 2026-01-02. | `E-001` |
| R2 | Qual contribuição foi observada e ela é individual ou compartilhada? | Uma alteração do pacote compartilhado foi consumida pelo produto; contribuição consolidada uma vez, autoria individual não verificada. | `E-002`, `E-003` |
| R3 | Quais são os componentes da arquitetura descritos no registro? | Cliente consome o pacote local e consulta serviço HTTP; estático, sem afirmação de runtime. | `E-004` |
| R4 | Qual versão foi publicada para usuários? | Desconhecida; há tag e pacote, mas nenhuma evidência liga o artefato ao destino. | `E-005` sustenta somente o limite |
| R5 | A aplicação mantém 60 FPS em dispositivos móveis? | Desconhecido/não medido; não inferir performance a partir de configuração. | Nenhuma evidência de medição; responder `not_measured` |

O revisor registra por caso: resposta factual citada (sim/não), unknown preservado (sim/não), IDs usados e eventual extrapolação. Aprovação exige 100% das afirmações factuais rastreáveis e os casos R4/R5 mantidos como desconhecidos.
