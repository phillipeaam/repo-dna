# Contrato: Página Project Source of Truth em Markdown

## Ordem de conteúdo

1. Metadados simples: versão do documento, produto, slug, data, estado, versão do método e repos/baselines cobertos.
2. Start Here: o que é, por que importa, papel/contribuições fortes, release/estado e cautela.
3. At a Glance, índice de tags técnicas e mapa de estudo. Cada linha de tag mostra faceta/conceito, estado/contexto, links aos registros e ocorrências/evidências; perfis de busca são projeções identificadas, não novas fontes de verdade.
4. Core Project Record por assunto: produto/fluxo, contexto/equipe/papel e roster de contribuidores, ownership, sistemas/arquitetura/stack, tecnologias/padrões/pacotes/IA/mídia com ocorrências, implementação planejada vs encontrada, decisões, timeline/release, evidência, claims e questões.
5. Projeção pública e readiness, quando aplicáveis.
6. Readiness editorial por produto, com papel/contexto separados, leitura rápida, histórias sustentadas, pacote proporcional de evidências e decisão humana distinta da recomendação; campos sem suporte ficam desconhecidos.
7. Revisão de superfície de portfólio, somente quando selecionada, com escopo observado, percurso, placar justificado/findings ou `not_observed`, prioridades, plano e fontes no mesmo documento.
8. Cobertura, estado das etapas, perguntas pendentes e log de verificação.
9. Apêndices A1/B1/B2/B3/B4, reconciliação de fontes, índices e histórico.

## Registros técnicos e contribuições (schema 2.1.0)

- `T-###` identifica um conceito/tecnologia no documento; `O-###` identifica uma ocorrência concreta ligada a repo, baseline, localização recuperável, sistema/finalidade, contexto, origem, versões, atualidade e evidências. Uma tecnologia pode ter ocorrências com estados diferentes; não gravar um estado global que apague essas diferenças.
- Cada tag usa `faceta:slug` estável, rótulo, definição e aliases conhecidos. Alias aponta para exatamente uma chave; homônimos ou sinônimos ambíguos permanecem separados e anotados como conflito/pendência.
- Dependência declarada, versão resolvida, disponibilidade instalada, uso estático observado e configuração ativa são campos/estados independentes. O perfil padrão de consulta de uso demonstrado inclui apenas ocorrências `observed_use` atuais/revalidadas e não stale. Perfis exploratório, configuração ativa e histórico exibem seu qualificador.
- `P-###` identifica pessoa, grupo, bot ou ferramenta de IA como tipo distinto; `K-###` identifica trabalho/contribuição com sistema, repo/baseline/intervalo, tipo de atribuição e fontes. Roster declara fontes, janela e cobertura e significa “identificados no escopo”, salvo comprovação explícita de completude.
- Experiência individual requer vínculo explícito e sustentado `P-###` → `K-###` → `O-###`/`T-###`, com evidência/limite. Não herdar stack do time. Não inferir identidade por alias ambíguo, liderança por contagem, autoria de asset a partir de crédito, ou atividade IA a partir de instruções.
- A migração `2.0.0` → `2.1.0` atualiza o mesmo arquivo; conserva IDs e significado válidos, registra baseline/vocabulário e gaps, preserva ocorrências removidas como históricas e marca evidências dependentes como stale até revalidação. Heading ausente em documento legado não equivale a avaliação concluída.
- Exemplos e fixtures versionados são fictícios. A única saída persistente continua sendo este Markdown; tabelas e índices são projeções dos registros dentro do mesmo documento, nunca catálogo/JSON/banco paralelo.

## Regras

### Reconstrução e destaques técnicos (US14)

- Uma reconstrução/destaque pode resumir evidências já registradas no mesmo Markdown; não constitui arquivo, fonte ou segunda autoridade.
- Dimensões investigativas: contexto/problema/restrições, contribuição/ownership, mecanismo/decisão/trade-off, colaboração, efeito/consequência, validação, resultado e reflexão. São prompts opcionais, não headings ou sequência obrigatórios. Registrar lacuna quando relevante; prosa concisa pode ordenar dimensões livremente.
- Cada afirmação material referencia finding/evidência e localização recuperável, baseline/escopo, relação de suporte, tipo de conclusão, limite e confiança justificada. Para conclusão reconstrutiva, tipos incluem `fact`, `inference`, `personal_account`, `hypothesis`, `conflict` e `unknown`/`not_observed`; indisponibilidade de fonte mantém `unavailable` em cobertura.
- Para cada fonte ligada a uma afirmação material, registre em `E-###` os metadados disponíveis: origem/canal, autoria/publicador, datas, baseline/snapshot/versão, localização recuperável, natureza (direta, secundária, relato ou outro tipo justificado) e atualidade. Metadados ausentes ficam `unknown`. Na ligação fonte→claim, qualifique a adequação para a dimensão específica e anote relação com outras fontes e corroboração independente quando conhecida. Fontes derivadas da mesma origem não são independentes. Esses campos descrevem a fonte e seu encaixe na dimensão, não a confiança da claim; mantenha a confiança justificada separadamente. Não estabeleça ranking universal nem exija hash ou cópia preservada. Minimize/mascare dados pessoais ou privados desnecessários.
- Para cada fonte usada por claim material, registrar procedência e adequação à dimensão sustentada separadamente da confiança da claim: origem/autoria quando conhecida, datas disponíveis, snapshot/versão, localização recuperável, natureza/tipo, atualidade e relação/corroboração independente quando disponível. Campo não conhecido recebe `unknown`; não impor hierarquia universal, hash ou cópia de preservação.
- Confiança usa a rubrica comum: `high` = suporte direto adequado ao escopo sem contradição material aberta; `medium` = suporte parcial/indireto ou limitado sem alternativa igualmente sustentada; `low` = suporte fraco/ambíguo ou alternativas igualmente plausíveis. Justificar com tipo/direção da fonte, corroboração, contradições e escopo. Claim sem suporte fica `unknown`/`unsupported`, sem nota; não é rebaixada automaticamente a `low`.
- Evidência é tipada pelo que sustenta: autoria registrada, comportamento, decisão/intenção relatada, colaboração, validação ou resultado. Nenhuma dessas relações é automaticamente herdada por outra.
- Hipótese mantém suportes, alternativas/contraevidência, justificativa e incerteza; não vira fato por revisão editorial. Um destaque conserva `draft`/`accepted`/`corrected`/`rejected` e sua procedência, sem publicação automática.
- O conjunto editorial pode conter zero a três destaques. Eles são curtos e rastreáveis; não exigem simetria nem alegação de benefício, métrica, causalidade ou contratação sem evidência adequada.
- Teste presente/configurado, execução e resultado existente são estados distintos. Resultado é limitado a snapshot, cenário e ambiente; nenhum implica qualidade global ou impacto comercial.
- Atualização no schema 2.1.0 adiciona conteúdo opcional ao mesmo documento. Leitores de documentos legados tratam ausência como não avaliada/não migrada, nunca como inexistência ou conclusão negativa.

- Sources allowed for this narrative are consistent with the local, user-supplied, or anonymous-public-only boundary; private services and credentials are not a workflow dependency.

- Síntese concisa com termos técnicos necessários explicados.
- Novos documentos usam schema `2.1.0`. Registros `1.0.0`/`2.0.0` permanecem legíveis; a próxima atualização migra no mesmo Markdown para `2.1.0`, preservando IDs, significados e histórico e registrando os mapeamentos/lacunas. Seções/editoriais, superfície, tags ou pessoas ausentes em versão legada significam não avaliadas/não migradas, não inexistência, falha nem aprovação.
- Headings e identificadores estáveis MUST permitir que humanos e agentes recuperem respostas por tema e citem findings/evidências diretamente.
- Cada resposta factual destinada à consulta por agente MUST apontar a uma evidência recuperável, baseline e limitação; ausência de suporte deve permanecer explícita.
- Paths locais e URLs incluem contexto para revalidar fonte/data/versão.
- Tabelas compactas para matrizes; parágrafos/listas para explicações.
- Headers e sumário são navegação; toggles não são requisito.
- Verdade atual permanece no início/core; apêndices preservam evidência e auditoria histórica.
- Cada claim factual relevante aponta para fonte, baseline e limite/estado de confiança.
- Distinguir not_observed, not_applicable, unavailable e not_verified.
- Não incorporar código grande, credenciais, endpoints privados, e-mails ou dados pessoais desnecessários.
- Não criar representações HTML/CSV, pastas por sistema ou exports.
- A extensão editorial não exige brief, número fixo de projetos/histórias ou material visual; recomendações de pacote não são gates de elegibilidade.
- Avaliações condicionais do site/protótipo ocupam seções deste mesmo arquivo e registram somente páginas, viewports e interações realmente observados.
- `Vocabulário/tag` registra chave `faceta:slug`, rótulo, aliases, definição/relação e versão. `Registro técnico T-###` descreve o conceito; `Ocorrência O-###` localiza seu uso/configuração por sistema, contexto, repositório/baseline, estado, origem, versão, atualidade e evidências. Todos são IDs locais ao documento.
- Novos créditos usam `Pessoa P-###`, contribuição `K-###` e ligação explícita a ocorrência/sistema/evidências. Reconciliar IDs preexistentes sem renumerar evidência, finding ou claim. Nome/alias publicável e status de divulgação são campos separados de identidade observada.
- Cada tag exibida preserva seu qualificador; resultados do perfil padrão usam somente `observed_use` atual e não stale. `active_configuration`, inventário exploratório, histórico, experiência individual e assistência IA continuam filtros separados, com escopo e rotas às evidências.
- Declaração de dependência, resolução, instalação demonstrada, uso estático observado e configuração efetiva não são tratados como equivalentes. Versões, relação direta/transitiva, contexto (runtime/editor/build/test/CI/documentação/exemplo), origem e exercício são campos independentes.
- Assistência a desenvolvimento, IA integrada ao produto, técnica, provedor e modelo são registros independentes. Arquivos de instrução não provam tarefa; o agente que realizou a auditoria não estabelece uso de IA durante desenvolvimento do alvo.
- Padrão inclui participantes, relações, comportamento, propósito e escopo, mais natureza da conclusão e origem própria/terceira. Nome de classe/pasta/README não sustenta padrão sozinho.
- Extensão/contêiner não identifica codec por si só. Codec, stream metadata e configuração de processamento são apresentados separadamente; desconhecido continua desconhecido.
- Roster indica contribuidores identificados no escopo, fontes, janela observada, aliases pendentes e completude. Não é declarado total sem base; inclui trabalho não codificado quando evidenciado.
- Uma tag de projeto não vira experiência de uma pessoa sem vínculo sustentado pessoa → contribuição → ocorrência. Cargo formal, participação compartilhada, bots/agentes, responsáveis por revisão e terceiros permanecem identificados de forma distinta.
- Disponibilidade de rede, catálogo, ferramenta ou parser não é requisito; descrições externas não comprovam ocorrência no alvo. O índice técnico e suas ocorrências não criam relatório persistente, catálogo ou banco separado.
