# Revisão opcional da superfície de portfólio

## Propósito e pré-condição

Avaliar a experiência observável em site, protótipo ou material visual explicitamente selecionado. Não substitui A1/B1–B4 nem implementa ou publica a superfície. Sem artefato selecionado, estado not_applicable; artefato inacessível gera not_observed por dimensão.

## Entrada e limites

Registrar URL/artefato, páginas/áreas, data, viewports e interações realmente observados, método e limitações. Usar somente acesso público/estático. Não autenticar, submeter formulários, acionar contato/compra/conversão, alterar estado, editar design/site, instalar dependências ou executar o alvo. Uma captura comprova apenas o que ela mostra.

## Rubrica

Para cada dimensão abaixo, registrar `finding` ou `not_observed`, evidência/localização, leitura profissional, impacto ao visitante, confiança e limite. Usar os identificadores estáveis para que nenhuma dimensão desapareça ao preencher o scorecard:

| ID | Dimensão e procedimento observável |
|---|---|
| `positioning` | Posicionamento/primeira impressão: público e valor compreensíveis sem inventar claims. |
| `narrative-information-architecture` | Propósito, ordem, redundância e coerência das páginas/seções. |
| `discovery-grouping` | Descoberta de projetos, agrupamento/filtros, scanabilidade e alternativas abertas. |
| `cases-evidence` | Contexto, contribuição, profundidade, claims e rotas às provas. |
| `visual-readability` | Hierarquia e legibilidade visual; contraste só é finding quando observado/medido. Comparar com brief ou referência visual aprovada quando fornecidos. |
| `mobile-reflow` | Viewports mobile realmente inspecionados; uma captura isolada não prova reflow. |
| `tablet-reflow` | Viewports tablet realmente inspecionados; ausência de viewport resulta em `not_observed`. |
| `reading-order` | Ordem de leitura apenas quando a ordem programática puder ser inspecionada por material disponível sem executar código. |
| `touch-targets` | Toque e dimensão de alvos somente quando observados/medidos; imagem estática não comprova acionabilidade. |
| `keyboard-navigation` | Navegação por teclado somente quando exercitada em superfície pública sem autenticação ou mudança de estado. |
| `focus-visibility` | Estado de foco observado; aparência normal não demonstra foco visível. |
| `accessible-names` | Nomes acessíveis quando expostos por evidência disponível; rótulo visual não comprova nome programático. |
| `semantic-structure` | Semântica quando exposta por fonte/árvore acessível disponível sem executar conteúdo do alvo. |
| `contrast` | Medição ou evidência visual localizada, identificando método e limite; percepção em captura não equivale a medição. |
| `reduced-motion` | Preferência/configuração e resultado somente quando fornecidos ou observados de forma segura; não inferir suporte. |
| `animated-media-controls` | Controles e comportamento de mídia animada somente quando observados sem acionar estado proibido; ausência de mídia fica `not_observed`. |
| `contact-conversion` | Clareza e disponibilidade aparente; não submeter contato/conversão nem declarar taxa/intenção sem estudo ou medição. |
| `maintenance-consistency` | Consistência observável entre conteúdo, implementação e fonte visual; não alegar manutenção interna sem evidência. |
| `unavailable-media` | Falha/indisponibilidade de mídia apenas se visível em captura, referência ou acesso público estático efetivamente observado; não presumir falha por ausência de arquivo no material parcial. |
| `performance` | Registrar apenas sinais estáticos diretamente observáveis e medições já existentes/fornecidas, com origem, snapshot, cenário, ambiente, ferramenta, unidade e método quando conhecidos. Não iniciar carregamento de teste, profiler, benchmark, build ou execução do alvo; sem sinal ou medição, usar `not_observed`. |

Não autenticar, submeter formulários nem acionar contato/compra/conversão. Não executar código ou iniciar medições dinâmicas no alvo. Quando um método seguro não estiver disponível, declarar `not_observed` com o motivo em vez de inferir resultado.

## Notas e findings

Nota opcional de 1 a 5 exige critério e observação localizada; é diagnóstico profissional, não pesquisa com usuários/recrutadores, benchmark ou certificação. Prioridades P0–P3; cada finding tem ID, evidência/localização, impacto, recomendação, esforço relativo, dependência/risco e confiança. Comparações avaliam descoberta, scanabilidade, profundidade, mobile, acessibilidade, manutenção e brief; não prescrevem carrossel, autoplay, layout, filtro ou tokens sem rationale.

## Síntese

No mesmo Markdown canônico, incluir resumo executivo, scorecard com uma linha por cada identificador acima (status, nota/critério/confiança quando aplicáveis, evidência/localização, impacto e limite), percurso conciso do visitante, findings priorizados, arquitetura/direção recomendada, gaps de conteúdo/evidência, plano por fases, decisões/perguntas pendentes e limitações. As recomendações devem apontar rationale e evidência e permanecer distintas de decisão/aprovação humana. Pesquisa externa só se decisão aberta exigir; registrar título, link direto, data e separar achado da fonte de julgamento. Sem acesso, manter cada lacuna como `not_observed` e continuar análise de conteúdo/repositório.

A revisão não é pesquisa de usuário, teste com recrutadores, validação dinâmica, certificação de acessibilidade, benchmark de performance ou aprovação de design/conteúdo.
