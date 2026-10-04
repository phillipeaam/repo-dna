# B2 — Runtime, confiabilidade e performance estáticos

## Limite

B2 desta feature é análise estática. Não executar aplicação, build, testes, profiling, benchmark ou tooling do alvo, mesmo se solicitado nesta sessão. Planejar validação futura é permitido; execução pertence a processo externo independente. Medições recebidas são dados e precisam de procedência.

## Mapa estático

Para caminhos relevantes, identificar trigger/frequência, trabalho recorrente, lifetime/ownership, alocação/carregamento, eventos e assinaturas, cancelamento, concorrência, persistência/rede, tratamento de erro/retry, cleanup e degradação. Registrar fato observável separado de risco/hipótese. Instrumentação configurada não é resultado medido.

## Contrato de medição

Para cada medição recebida, registrar: origem/procedência, snapshot/ref, cenário e workload, ambiente/dispositivo/OS, build/configuração, ferramenta/versão, unidade, método, amostra/limites e limitações. Antes/depois só compara sob condições equivalentes. `measured` não significa causalidade sem controle do cenário.

Distinções obrigatórias: tamanho comprimido de arquivo/build/download não é memória/runtime; Editor não é plataforma alvo; demo não é teste; configuração ou profiling setup não é resultado observado; ausência de dado não é zero.

## Sem medição

Classificar `not_measured`. Formular pergunta verificável, métrica, cenário, ambiente e procedimento futuro sugerido, incluindo riscos e controle necessário. Não estimar ganho, regressão, SLA ou impacto sem suporte.

## Saída e checkpoint

Inventário `static_fact`/`static_risk`/`measured`/`not_measured`, cada item ligado a snapshot/evidência, limitações e plano de verificação futura. Estado parcial se caminhos ou medições não tiverem cobertura.
