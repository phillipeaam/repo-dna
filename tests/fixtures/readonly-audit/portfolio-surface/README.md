# Fixture sintética: revisão de superfície

Dados totalmente fictícios do framework. Esta fixture representa as anotações de uma inspeção manual de artefatos estáticos fornecidos; não abrir nem carregar site real como parte dos testes.

## Escopo da observação disponível

- Artefato: mock estático `portfolio-home-v1`, capturas fornecidas e sem scripts executáveis.
- Áreas: cabeçalho, resumo do perfil e projeto de exemplo `sample-featured`.
- Viewports representados nas capturas: desktop 1440×900 e mobile 390×844. Tablet não foi fornecido.
- Interações: links e rótulos visíveis nas capturas; teclado, foco e toque real não foram exercitados.
- A fixture não demonstra comportamento, preferência de recrutadores, conversão ou performance de uma aplicação real.

## Matriz completa de cobertura FR-089 / SC-027

Cada dimensão tem um estado, uma referência local à evidência sintética e um limite. `finding` indica somente o que está diretamente visível na captura fictícia. `not_observed` indica que a fixture não permite concluir.

| Dimensão | Estado | Evidência da fixture | Observação ou motivo | Limite |
|---|---|---|---|---|
| positioning | finding | E-S01 | O título visível identifica a pessoa como desenvolvedora de produto. | Texto de uma captura; não comprova diferenciação ou entendimento por leitores. |
| narrative-information-architecture | finding | E-S01 | A captura mostra resumo antes da lista de projetos. | Uma tela não revela a narrativa completa nem a estrutura de outras páginas. |
| discovery-grouping | finding | E-S02 | Um projeto Featured aparece antes do conteúdo de arquivo. | Uma captura não comprova facilidade geral de descoberta. |
| cases-evidence | finding | E-S03 | O card de `sample-featured` inclui link rotulado para o case. | O destino não foi aberto e a qualidade das evidências internas é desconhecida. |
| visual-readability | finding | E-S01 | Texto e títulos podem ser distinguidos na captura desktop fornecida. | Não foi feita medição de contraste, legibilidade real ou outros tamanhos. |
| mobile-reflow | not_observed | E-S04 | Existe captura mobile isolada, sem conteúdo equivalente para comparação. | Reflow e comportamento responsivo não podem ser inferidos de uma imagem. |
| tablet-reflow | not_observed | E-S04 | Nenhuma captura tablet foi fornecida. | Viewport tablet fora do escopo disponível. |
| reading-order | not_observed | E-S05 | Nenhuma árvore de acessibilidade ou ordem do DOM foi fornecida. | Ordem visual não prova ordem programática. |
| touch-targets | not_observed | E-S05 | Toque real e dimensões dos alvos não foram exercitados ou medidos. | Capturas não comprovam área acionável. |
| keyboard-navigation | not_observed | E-S05 | Nenhuma navegação por teclado foi executada. | Não inferir suporte pelo desenho dos links. |
| focus-visibility | not_observed | E-S05 | Nenhum estado de foco foi capturado. | Estado de foco desconhecido. |
| accessible-names | not_observed | E-S05 | Nomes acessíveis não constam do material fornecido. | Rótulos visuais não comprovam nomes programáticos. |
| semantic-structure | not_observed | E-S05 | HTML e semântica não foram fornecidos. | Hierarquia visual não prova semântica. |
| contrast | not_observed | E-S05 | Nenhuma medição de contraste foi feita. | Cor percebida em captura não é medição. |
| reduced-motion | not_observed | E-S05 | Nenhuma configuração ou movimento foi observado. | Não concluir suporte a preferência de movimento reduzido. |
| animated-media-controls | not_observed | E-S05 | A fixture não inclui mídia animada nem seus controles. | Presença e controle de mídia real são desconhecidos. |
| contact-conversion | not_observed | E-S06 | A captura mostra um link de contato, sem fluxo submetido. | Conversão, destino e resultado não foram testados. |
| maintenance-consistency | not_observed | E-S07 | Só uma versão e uma página foram fornecidas. | Consistência temporal e entre páginas exige comparação adicional. |
| unavailable-media | not_observed | E-S08 | Nenhum ativo quebrado foi incluído no mock. | Não comprova tratamento de falha em mídia real. |
| performance | not_observed | E-S09 | Não foram fornecidos métricas, waterfall ou medições de carregamento. | Capturas não comprovam desempenho. |

## Registro ilustrativo de finding

- Finding `P2`: o link do case está visível (E-S03); o próximo passo sugerido é verificar o destino quando houver autorização e material disponível.
- Esforço `M`, risco/dependência e confiança `moderate` são estimativas ilustrativas, não medições.
- Placar ilustrativo `3/5` para descoberta exige critério, escopo e evidência; não é benchmark nem certificação.
- Percurso hipotético: entrada → caso Featured → evidência. Correção, validação posterior e decisão humana continuam explícitas.

## Superfície indisponível

- Artefato fictício: referência `unavailable-prototype` inacessível.
- Resultado: todas as dimensões da matriz recebem `not_observed`; nenhuma nota ou finding é inventado.
- A auditoria de conteúdo e repositório continua possível; ausência de acesso à superfície não causa bloqueio global.

## Limite da fixture

Os registros exercitam o formato e a cobertura, não provam responsividade, acessibilidade, conversão, performance, preferência de recrutadores ou qualidade de qualquer site real.
