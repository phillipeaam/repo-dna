# Método incorporado e reconciliação com o RepoDNA

**Data:** 2026-10-03. **Feature:** [spec.md](spec.md). **Natureza:** pesquisa e contrato de conteúdo; escolhas de implementação ficam para o plano.

## 1. Intenção do produto

RepoDNA passa a estabelecer como um agente investiga um projeto, avalia evidência, reconcilia fontes e produz documentação. Coletores e métricas existentes podem apoiar o processo, mas não substituem leitura dos sistemas importantes, investigação de autoria ou julgamento de claims.

A única entrega persistente é um arquivo Markdown local por produto em `analysis-output/`. Ele reúne fonte de verdade, evidências necessárias, índice, histórico e apêndices. Um produto pode ter vários repositórios; produtos sucessores da mesma organização continuam separados. Relatórios HTML, JSON/CSV, exports Notion e arquivos auxiliares de análise não são entregues. Estado temporário de execução, se necessário, fica fora do alvo e não constitui saída do produto.

Este documento incorpora localmente o método extraído da pesquisa inicial. A constituição e a spec governam os requisitos; a skill, seus runbooks e os contratos locais aprovados governam a execução. As fontes originais são procedência opcional preservada fora do conteúdo versionado; nenhum acesso a elas é necessário para obter as instruções. Veja o [mapa local de cobertura](source-inventory.md).

## 2. Regras transferidas das fontes

1. Existência de código, autoria individual, responsabilidade formal, publicação e impacto são perguntas distintas.
2. Planos comprovam intenção; copy antiga identifica claims a verificar.
3. Diffs e histórico significativo sustentam investigação de criação/extensão/integração. Commit count, churn e blame não medem valor profissional.
4. Observação estática não comprova comportamento runtime, gargalo ou melhoria medida.
5. Configuração ativa e uso real valem mais que mera presença de pacote.
6. Um tag estabelece um snapshot de fonte; a cadeia até o binário e o destino público precisa de evidência própria.
7. Crédito é evidência de atribuição, não licença automática. Importar um asset não prova criação de seu conteúdo.
8. Conteúdo público não autoriza implicitamente download, crop, rehosting ou reutilização de áudio.
9. O único Markdown de entrega organiza a fonte de verdade por assunto; logs necessários ficam dentro dele, depois do registro principal.
10. Nova evidência atualiza a resposta canônica primeiro e identifica checkpoints anteriores como superados.
11. Lacunas não bloqueantes podem ser encerradas honestamente. Não existe obrigação de recuperar toda a história.
12. Audit tasks permanecem readonly. Findings geram backlog; o agente não corrige o projeto auditado.

## 3. Hierarquia e vocabulário

| Dimensão | Classificações e significado |
|---|---|
| Fonte | Repositório/histórico; documentação/artefato/release; contexto histórico; copy a verificar |
| Conclusão | Fato observado; inferência; relato/confirmacão pessoal; conflito; não resolvido |
| Verificação | Verificado; fortemente suportado; compartilhado; desconhecido/não resolvido |
| Feature | Implementada; parcial; protótipo; somente planejada; não encontrada no escopo |
| Tecnologia | Instalada; uso possível; uso observado; configuração ativa |
| Runtime | Fato estático; risco estático; medido; não medido |
| Release | Exato; fortemente suportado; intervalo limitado; não resolvido |
| Claim | Segura; qualificada; interna; não sustentada; rejeitada |
| Prontidão | Completa; completa com condições; incompleta bloqueante; incompleta não bloqueante; opcional |
| Questão | Resolvida; parcial; aberta bloqueante; aberta não bloqueante; encerrada com razão |
| Cobertura | Completa; parcial; não observada; não aplicável; indisponível; não verificada |

Confiança precisa explicar por que uma conclusão é defensável: evidência direta, fontes independentes, granularidade do histórico e limites. Uma contagem alta não produz automaticamente confiança alta de autoria. Escala numérica existente só pode continuar com significado documentado e separado da força de prova.

A hierarquia é contextual. Código é autoridade para implementação; uma declaração histórica pode documentar motivação pessoal; artefato/store/deployment fundamenta publicação; licença/termo/permission record fundamenta uso de mídia. Um tipo de fonte não deve responder sozinho a todas as perguntas.

Uma taxonomia histórica de evidência distingue autoria direta, contribuição reconstruída, fato de produto/equipe, relato retrospectivo, verificação pública e necessidade de prova mais forte. O framework preserva essas distinções sem obrigar o mesmo alfabeto ou misturá-las com notas numéricas.

## 4. Etapas e contratos

| Etapa | Entrada | Trabalho e saída | Gate de saída |
|---|---|---|---|
| Preparação | Alvos selecionados, fontes e identidade quando conhecida | Limites, baseline, exclusões, política de divulgação, versão do método e mapa inicial de cobertura | Seleção inequívoca; resultados fora do alvo |
| A1 — Forense | Baseline e fontes | Identidade/timeline, autoria, arquitetura, features, planejado vs implementado, contribuições e claim ledger inicial | Findings rastreáveis; autoria separada de existência |
| B1 — Produção | A1 e domínios aplicáveis | Configuração ativa, arquitetura, build, conteúdo, dependências, tooling, QA e riscos estáticos | Domínios com evidência ou ausência qualificada |
| B2 — Runtime/performance | B1, código e medições já disponíveis | Execution/lifetime/cancelamento, concorrência, custos estáticos, medições contextualizadas e plano futuro | Estático e medido separados |
| B3 — Release/procedência | Histórico, versões e artefatos acessíveis | Cadeia fonte→artefato→publicação, original vs posterior, adoção de pacotes e limites temporais | Cada relação tem força própria; precisão não inventada |
| B4 — Créditos/publicação | Claims, assets, mídia e gaps | Créditos/licenças, uso de mídia, wording, prontidão de texto/links/mídia e fechamento de questões | Bloqueios específicos visíveis |
| Consolidação | Resultados das etapas | Um Markdown local com Start Here, Study Map, registro principal, índice e apêndices | Um arquivo entregue e uma resposta atual por tema |
| Reconciliação | Fontes autorizadas disponíveis | Busca por aliases, conflitos, incorporação de informação útil e links a contexto retido | Escopo de busca e pendências declarados |
| Revisão final | Página, evidências e baseline final | Revisão de cobertura, claims, consistência, privacidade, preservação e handoff | Pronto para revisão ou parcial com motivos |

Projetos pequenos podem combinar passos. A combinação precisa mostrar onde cada resultado foi atendido. Projetos grandes podem dividir domínios em subauditorias sem criar páginas canônicas concorrentes. Checkpoints permitem retomada e invalidação de conclusões dependentes de uma baseline que mudou.

Auditoria concluída, documentação pronta para revisão, texto publicável, mídia publicável e revisão humana concluída são estados distintos.

## 5. A1 — Investigação forense

### Identidade e escopo temporal

Examinar identidade do produto, nomes anteriores, remotes, branches/tags, versões, primeiros/últimos commits relevantes, janela de desenvolvimento, eventos de release e manutenção posterior. Registrar datas aproximadas quando precisão não for justificável.

Separar:
- cronologia do projeto;
- período de contribuição da pessoa;
- período de emprego;
- janela oficial de evento/jam;
- linhagem de versões;
- versão pública atual.

Um nome antigo no README pode ser alias histórico, não outro produto. Uma mudança de editor anos depois não demonstra desenvolvimento contínuo de gameplay.

### Identidades e trabalho por sistema

Registrar identidades observadas, aliases confirmados e candidatos não resolvidos. Examinar sequências de commits, diffs, renames, integrações e merges significativos por sistema. Não fundir pessoas por semelhança de nome.

Distinguir autoria original, extensão, manutenção, integração de pacote/conteúdo, trabalho colaborativo e ownership não recuperável. Identificar baseline criada por outro colaborador antes de atribuir uma extensão à pessoa investigada.

Anotar limitações de squash, histórico raso, contas compartilhadas, código gerado, refs quebradas e arquivos importados. Não criar ranking de pessoas.

### Produto, features e arquitetura

Reconstruir o fluxo implementado a partir de composição e chamadas:
- inicialização/onboarding;
- loop principal;
- transições de estado;
- sucesso/falha;
- saída/restart;
- persistência e integrações.

Mapear pastas/domínios, composition roots, fronteiras, modelos de dados, comunicação/eventos, cenas/prefabs/configuração quando pertinentes. Uma descrição genérica de Unity ou de arquitetura web não explica o alvo.

Matriz mínima: sistema → baseline → implementação → evidência → autoria → limite → relação com versão pública. Comparar designs/tasks/notas com o que foi encontrado: realizado, simplificado, parcial, removido ou não localizado.

### Contribuições e histórias

Agrupar contribuições significativas com o que foi feito, sistema/arquivo, histórico, confiança e wording possível. Manter trabalho compartilhado e origem externa explícitos.

Usar **Problema → Restrição → Abordagem → Trade-off → Resultado → Evidência**. Só declarar motivação pessoal, decisão de liderança ou lesson learned quando houver fonte; reflexão futura permanece pergunta para preparar.

Entregar sinais para onboarding, documentação e entrevista, não apenas copy de carreira. Uma história forte pode explicar integração e limites sem afirmar desempenho ou autoria total.

## 6. B1 — Produção e estrutura técnica

### Núcleo para qualquer projeto

- organização/domínios, linguagens e versões;
- entrypoints e composição;
- dependências internas/externas e ciclos;
- limites runtime/tooling/testes;
- modelos, contratos e serialização;
- configuração ativa por ambiente/plataforma;
- build, release e deployment descritos pelos arquivos;
- conteúdo/dados/assets e mecanismos de carregamento;
- observabilidade, debug tools, validação e procedimentos de QA;
- proveniência de sistemas próprios, pacotes, forks e código gerado.

Testes encontrados indicam estrutura disponível; relatório de execução compatível pode indicar uma execução. Nenhum dos dois é garantia geral de correção.

### Especialização de jogos/Unity extraída das fontes

- Rendering efetivo: Graphics/Quality, pipeline asset, renderer data/features, overrides, lighting, sombras, HDR/MSAA/render scale, Volumes, shaders/materials, batching/instancing, cameras.
- Player/time/physics: backend/stripping/API, color space, resolução, input, timestep, layers/tags/collision matrix, target frame rate/VSync.
- Build: profiles, cenas habilitadas, símbolos, plataforma, compressão/cache/template/memória/exceptions quando WebGL, development vs release.
- Conteúdo: Resources, StreamingAssets, Addressables, AssetBundles, referências diretas, data assets e imports representativos de texturas/meshes/audio/animação/fonts/localization.
- Código: namespaces, asmdefs, fronteiras runtime/editor, composition roots, eventos/interfaces, state/data patterns e acoplamento.
- UI: uGUI/UITK/mista, hierarquia, binding, eventos, lifetime, fonts e resolução.
- Áudio: mixers/grupos/snapshots, fontes espaciais/2D, import/loading, parâmetros e integração runtime.
- Animação/VFX: controllers/rigs, Timeline, particles/VFX, shaders e conteúdo externo.
- Física/navegação/AI: colliders/bodies/controllers, queries, filtros, navmesh, decisão/estados e frequência.
- Serviços: networking/topologia/autoridade, persistence/saves, backend/API, retries/offline/sync quando presentes.

Ausência de asmdefs, CI ou pooling não é automaticamente um defeito. Avaliar contra a escala e intenção evidenciadas.

### Aplicações e serviços

Aplicações e produtos compostos exigem profundidade equivalente para Flutter/Dart/Python: providers/services, configuração tipada, GraphQL/protobuf, schema/codegen, auth/parent gates, UI/state, feature flags, tarefas assíncronas, persistência/cache, jobs, backend ownership, observabilidade e release.

Não converter integração do cliente em autoria do backend/ML/speech. Distinguir consumir configuração de criar o repositório que a fornece.

## 7. B2 — Runtime, confiabilidade e performance

Mapear caminho → trigger/frequência → trabalho → estado/dados → lifetime → cancelamento → resultado/risco → evidência.

Investigar:
- startup, polling, loops e trabalho de inicialização vs recorrente;
- eventos e simetria de subscribe/unsubscribe;
- coroutines/tasks/async, cancelamento, retry e transições;
- coleção/strings/boxing/closures e alocações suspeitas;
- instantiate/destroy, pooling, handles/resources retidos;
- cache/invalidacão, estado obsoleto e concorrência;
- carregamento e mudança de tela/cena;
- persistência/offline/sync e limites de garantias;
- UI/audio/animação/physics/rendering;
- loading, footprint de conteúdo e falhas de execução existentes.

Registrar sinais positivos concretos e riscos estáticos. Não dizer “race-free”, “exactly once”, “zero GC”, “optimized”, “all leaks fixed” ou “robust” sem prova adequada.

Medições requerem cenário, baseline, ambiente, plataforma, resolução/qualidade quando cabíveis, ferramenta, unidade e método. Diferenciar:
- tamanho comprimido vs textura/memória runtime;
- GC alocado vs memória retida;
- presença de instrumentação vs captura;
- settings caros vs gargalo medido;
- build que compila vs execução funcional;
- cena demo vs testes automatizados;
- Editor vs target build;
- cópia de validação atual vs binário histórico.

O agente produz perguntas e um plano de profiling/validação para eventual trabalho futuro. Esta feature não executa, inicia nem orquestra validação dinâmica, mesmo quando solicitada; qualquer experimento dinâmico pertence a um processo externo independente, fora dos fluxos e entregáveis do framework. Resultados externos só podem ser considerados se forem fornecidos como evidência com procedência, snapshot, cenário, ambiente, ferramenta, unidade, método e limitações registrados.

## 8. B3 — Release e procedência

Construir uma cadeia com força por relação:

**Evento/deadline → snapshot de fonte → build/artefato → upload/store/destino → feature efetivamente disponibilizada.**

Datas de commit e tag não comprovam upload. Build introduzido depois de deadline pode ter sido produzido antes, ou ser rebuild; manter dúvida até existir fonte.

Comparar release original, primeiro pós-release, janela posterior, HEAD e mídia pública atual. Usar comparação por sistema, não apenas contagem de arquivos.

Registrar hash/manifest/version string quando disponível, sabendo que mesma version string não prova igualdade binária. Uma associação forte não é match exato.

Adoção de pacote precisa de cadeia própria: patch → release/versionamento do pacote → dependência consumida pelo cliente → release do produto → rollout público. Evidência de uma etapa não cobre as demais.

Encerrar recuperação quando a evidência acessível foi inspecionada e a lacuna não bloqueia wording qualificado. Não criar rebuild histórico e chamá-lo de artefato original.

## 9. B4 — Créditos, assets e publicação

### Conteúdo e integração

Para art/audio/animação/fonts/UI/VFX e pacotes, registrar:
- asset e uso relevante;
- criador/vendor/source;
- origem comprovada ou candidata;
- licença/termo/permission record;
- crédito exigido e crédito observado;
- quem criou conteúdo vs quem importou/integrou ou modificou;
- restrições de distribuição e apresentação conhecidas;
- limitações não resolvidas.

Créditos podem estar em README/NOTICE/LICENSE, cenas/UI, localization tables, data assets ou código. Comparar crédito com conteúdo realmente utilizado.

### Mídia e claim demonstrada

Cada mídia registra era/versão, captura/source, data, behavior demonstrado, limite de autoria, conteúdo de terceiros e ações avaliadas:
- link;
- embed oficial;
- cópia/crop/rehosting;
- áudio;
- legenda e atribuição.

Não assumir que “silenciar áudio” libera a imagem. Diagramas originais abstratos podem explicar engenharia quando assets não podem ser republicados; não usar screenshots de código privado como substituto automático.

Matriz de prontidão separa texto, role/ownership, results públicos, build atual, artifact histórico, visual/audio/fonts, mídia final, attribution e performance. Texto pode estar pronto com mídia bloqueada.

Resultados de jam/store/feedback mantêm fonte, período, amostra e significado: score não é rank; reviews não são amostra representativa; métrica do produto não é impacto individual.

## 10. Markdown canônico único e autoridade

### Camada inicial

1. Status de Source of Truth, baseline/data e limites de verificação.
2. Start Here: o que é, por que importa, contexto/papel, contribuições fortes, release atual/histórico e cautela principal.
3. At a Glance: fatos compactos e caveat.
4. Study Map: rotas para contribuição, arquitetura, runtime, release, contexto e evidências.

### Registro principal, por assunto

Produto/fluxo; contexto/equipe; papel e ownership; contribuição verificada; trabalho compartilhado; stack/arquitetura; features e planejado vs implementado; decisões/trade-offs; timeline/releases; evidência pública; claims atuais e prontidão; perguntas restantes.

Um único campo autoritativo por tema. Histórias e mídias devem apontar para a mesma claim/evidência; não manter copy divergente em cada etapa.

### Apêndices e estudo profundo

A1, B1, B2, B3 e B4; histórico/planning; source reconciliation; raw indexes; verification log. Material longo usa títulos e links de navegação no mesmo Markdown; respostas atuais ficam visíveis na camada inicial e no registro principal, sem anexos de análise.

Apêndice preserva por que se confia na conclusão. Nova etapa não cria automaticamente outro resumo público.

### Seções derivadas no mesmo arquivo

A projeção pública, onboarding e talking points derivam da mesma verdade e ficam como seções no único Markdown. Relevância e profundidade determinam quantas histórias existem; não impor três histórias por case. Wording público evita jargão e detalhes privados; o índice no arquivo conserva âncoras técnicas autorizadas.

## 11. Reconciliação readonly e freeze

Buscar em fontes autorizadas por nome atual/antigo, repos, features e contexto de equipe. Ler fontes materialmente relevantes antes de classificar.

Classificações locais:
- informação incorporada e qualificada;
- contexto relacionado retido;
- produto/projeto distinto;
- processo histórico/superado;
- irrelevante;
- candidato a limpeza, somente como recomendação.

Cada fonte retida tem link e propósito. Conflitos registram afirmação antiga → finding → resolução ou dúvida. Não importar old claims automaticamente.

Reconciliação registra localmente classificação, conflitos e recomendações de organização das fontes; nenhuma página de origem é editada ou removida. O método local aprovado governa a análise, independentemente de recomendações presentes nas fontes opcionais.

Freeze exige cobertura, rastreabilidade, uma autoridade atual, questões classificadas e preservação. Lacunas legítimas continuam visíveis. Review humano e publicação são decisões posteriores.

## 13. Aprendizados específicos dos casos, generalizados

## 12. Reconstrução de contribuição e raciocínio (US14)

Use essa etapa quando houver uma necessidade de explicar trabalho, decisão ou dificuldade que não está registrada como uma narrativa pronta. Ela não substitui A1, evidência ou reconciliação; organiza interpretações derivadas de fontes locais autorizadas.

### Rota de reconstrução

1. Delimitar claim/pergunta, sistema, baseline, intervalo e pessoa/contribuição em investigação. Enumerar fontes acessíveis: diffs/commits, documentação, código/configuração, testes e resultados já existentes; usar issue/review/release somente se local, fornecida ou pública sem autenticação. Registrar indisponíveis/não observadas.
2. Fazer uma matriz claim → fonte/localização → procedência/natureza/atualidade → dimensão adequada → o que sustenta e não sustenta → relação com outras fontes. Registrar origem/autoria quando conhecida, datas, snapshot/versão, localização recuperável, natureza direta/secundária/relato e atualidade; marcar atributos ausentes como `unknown`. Distinguir a adequação da fonte para a dimensão da claim da confiança na claim. Avaliar corroboração independente quando disponível e notar origens compartilhadas; não presumir uma hierarquia global nem exigir hash/cópia preservada. A autoria em metadata prova apenas autoria registrada; código/configuração sustenta estrutura/mecanismo estático; notas/entrevistas sustentam relato atribuído; teste/log/releases sustentam somente o resultado/elo observado no escopo deles.
3. Construir cronologia e alternativas quando necessário. Separar fato observável, inferência, relato pessoal, hipótese, conflito e desconhecido. Para hipótese, registrar fontes favoráveis e contrárias, explicações alternativas, confiança qualitativa com razão e limites. Calibrar `high`/`medium`/`low` conforme a rubrica em `data-model.md`; sem suporte suficiente, usar unknown/unsupported sem nota, não `low`. Nunca atribuir motivação a partir de diff sozinho.
4. Explicar mecanismo e trade-off com vocabulário que o leitor possa entender. Descrever efeito direto estático separadamente de impacto/benefício potencial. Benefício, causalidade ou métrica exige dado apropriado com snapshot, método, unidade, cenário e ambiente; caso contrário deixar como hipótese ou pergunta.
5. Distinguir teste/configuração presente, resultado de execução existente, revisão, experimento e release. Nunca iniciar build/teste/executável no alvo. Escopo de um resultado não se amplia além do snapshot, cenário e ambiente observados.
6. Perguntar à pessoa somente se a resposta puder alterar materialmente atribuição, interpretação ou wording seguro. Ausência de resposta/memória não é evidência negativa; se não houver rota razoável de recuperação, manter unknown/not_observed e prosseguir nas demais dimensões.
7. Redigir zero a três destaques concisos, somente quando evidência e relevância justificarem. Contexto, problema, restrição, mecanismo, decisão, colaboração, consequência, validação e resultado podem aparecer em qualquer ordem; não exigir heading, preenchimento total nem história simétrica. Linkar cada afirmação material e manter limites visíveis.
8. Manter proposta em draft até revisão humana. Aceitar, corrigir ou rejeitar wording não modifica nem apaga findings e fontes; nenhuma saída é publicada automaticamente.

### Matriz de relação fonte → dimensão

| Fonte observada | Pode sustentar | Não sustenta automaticamente |
|---|---|---|
| Metadata/diff/histórico Git | Alteração registrada e identidade técnica conforme metadados | Motivação, decisão pessoal, colaboração, ownership total, qualidade ou impacto |
| Código/configuração/documentação | Estrutura ou intenção textual no snapshot | Execução, adoção, benefício real ou estado publicado |
| Relato pessoal identificado | Memória/explicação atribuída e passível de correção | Confirmação independente ou resultado medido |
| Arquivo de testes/CI | Verificação planejada/configurada ou instrumentação presente | Que foi executada ou passou |
| Log/resultado de teste fornecido | Resultado daquele cenário/snapshot/ambiente e limites registrados | Qualidade global, experiência real de usuário ou ganho comercial |
| Release/artefato público observado | Elo específico da cadeia de publicação | Que commit/diff candidato foi incluído sem relação de procedência |

Não combinar evidência de dimensões diferentes como se fosse uma só. Se duas fontes discordam, manter ambas e classificar conflito; resolver apenas com suporte que discrimine a divergência. `unknown`, `not_observed` e `unavailable` são resultados informativos, não falha da narrativa.

| Exemplo consultado | Aprendizado para o framework | Requisitos |
|---|---|---|
| Jogo produzido em evento com prazo | Deadline/timezone, alterações posteriores e versão pública exigem limites; créditos ampliados não provam título de liderança; artifact original ausente pode ser não bloqueante | FR-025–032, FR-042–054 |
| Jogo com migração posterior | Histórico original e migração posterior não são uma única baseline; source module não prova integração atual, teste, optimalidade ou performance; mídia pode ter direitos pendentes | FR-030–040, FR-044, FR-047–054 |
| Aplicação com pacotes compartilhados | Produto, pacotes e versionamento têm cadeias separadas; versionado não prova store rollout; cliente GraphQL não prova backend; histórias compartilhadas não viram autoria total | FR-026–032, FR-036–045, FR-061–062 |
| Produto sucessor com serviços | Sucessor é produto distinto; mesmas pessoas/empresa não fundem autoria; consumidor de configs não é autor do repo de configuração | FR-002, FR-020, FR-026, FR-036, FR-061 |
| Revisão posterior de claims | Checkpoint “locked” pode ser superseded por auditoria posterior; fonte canônica governa wording atual | FR-052–058, FR-066 |
| Documentação derivada e entrevistas | Seleção de histórias, defense matrix, diagramas e perguntas de entrevista derivam do contrato de evidência, sem forçar geometria/número fixo | FR-032, FR-049, FR-062 |
| SDD + Spec Kit | Requisitos, plano, tarefas, quality gate e convergência têm propósitos distintos; implementação não reescreve intenção silenciosamente | FR-013–019, FR-068–070 |

Esses exemplos sustentam o desenho do método. Seus commits, pessoas, datas, métricas e claims particulares não foram revalidados nos repositórios originais nesta sessão.

## 14. Registro histórico da base anterior à remoção (2026-10-07)

Esta matriz descreve a implementação anterior que foi removida; não é um
inventário do checkout atual. O produto atual consiste nas duas skills RepoDNA,
seus runbooks e referências, contratos, fixtures sintéticas e ferramentas de
validação do framework. Não há runtime de análise, CLI ou instalador separado.

| Capacidade / fonte local inspecionada | Decisão de produto | Motivo / mudança exigida |
|---|---|---|
| README, repodna, install.sh e dna-analysis.sh | Removidos do checkout atual | O único fluxo mantido é guiado pelas skills |
| src/pipeline/, collectors/, renderers/ e schemas/ | Removidos do checkout atual | Os componentes pertenciam ao analisador independente descontinuado |
| Lógica de coletores e documentação técnica anterior | Removidas; ensinamentos selecionados incorporados às instruções locais | As skills não dependem de módulos do analisador legado |
| Privacidade e portfolio drafts | Preservar limites, mascaramento e confirmação identificada | Confirmação humana não torna narrativa prova de runtime/release |
| Snapshots, dashboards, charts, exports e archives | Removidos com a implementação anterior | Formatos alternativos não fazem parte do produto atual |

Esta matriz registra decisões e contexto histórico, não sugere que os arquivos listados permaneçam disponíveis.

### Governança que precisa evoluir

A constituição 1.0.0 protegia evidência, núcleo genérico, privacidade, contratos e modularidade; os princípios de evidência, genericidade e privacidade continuam adequados e foram preservados na v2.0.0.

Antes da implementação do runtime, uma atualização constitucional explícita para v2.0.0 substituiu o contrato de CLI/relatórios múltiplos pelo framework de skills readonly e pela fonte de verdade Markdown. A data de ratificação original continua TODO porque não há confirmação disponível.

## 15. Fronteiras de implementação desta sessão

Entregues para esta feature SDD: spec, síntese do método, inventário de fontes, checklists, plano, contratos, modelo e tarefas. A especificação do produto limita a futura entrega de cada auditoria a um único Markdown em `analysis-output/`.

A skill, os runbooks, contratos, template de consolidação e contratos de aceitação estão disponíveis localmente. O CLI e o analisador anteriores foram removidos do checkout em 2026-10-07. A procedência original da pesquisa é privada e opcional; o mapa público mantém correspondência temática. Perfis de host não verificados permitem auditoria estática com aviso; preservação observada não é garantia de isolamento.

Criar pasta ignorada ou escrever “readonly” em prompt não comprova isolamento. Na versão atual, o agente segue o procedimento sem escrita intencional e declara a limitação; enforcement e prova de host são melhorias futuras para elevar a garantia de preservação.

## 16. Prontidão editorial para portfólio

Brief de público, cargos, idioma, canais, provas e restrições é opcional e recebe origem/estado por campo. Separar o contexto (profissional, independente, jam, técnico ou desconhecido) do papel editorial sugerido/decidido. Só comparar seleção relativa quando existe conjunto explicitamente comparável; sem ele, registrar aderência possível sem ranking.

A leitura rápida deve orientar em cerca de um minuto e apontar ao aprofundamento no mesmo documento. Case percorre contexto, ownership, problema, restrições, abordagem, trade-offs, evidência, resultado e reflexão quando houver suporte. A quantidade de histórias acompanha evidência e relevância. Pacotes Featured apresentam metas recomendadas e gaps (incluindo papéis, contribuição, desafios, mídia e prova); Supporting/Archive permanece consultável com profundidade proporcional. Mídia demonstra uma claim concreta e registra se é captura, diagrama, proxy ou placeholder, além de proveniência e permissão por ação.

Na fixture Featured, o inventário desejável deve contemplar imagem/clipe principal, vídeo curto, 2–4 clipes/GIFs de sistemas, 3–6 screenshots, role/team/duration/platform/tech, 3–5 contribuições, 1–3 desafios, trade-offs, resultado/estado, links públicos e confidencialidade quando necessária. Registrar os itens disponíveis separadamente dos selecionados: publicação recomenda cerca de 4–7 itens visuais significativos. Assets ausentes ou sem permissão tornam-se gaps explícitos e não removem o projeto.

Validar SC-025 com leitor não familiarizado: cronometar busca de produto/contexto e contribuição (até 60 segundos) e acesso à evidência de um case (aproximadamente 5–10 minutos). Registrar perfil, tarefa, documento e tempos observados; checklist documental ou avaliação automatizada do esqueleto não prova sucesso temporal.

Avaliar separadamente prontidão de texto, contribuição, resultados, mídia/áudio, permissões e claims. Recomendações e testemunhos profissionais são atribuídos ao autor/contexto e não comprovam sozinhos cargo, autoria ou impacto. Linhagem de produto/sucessor preserva contribuição compartilhada sem duplicação. Uma lacuna material pede decisão humana.

## 17. Revisão opcional da superfície de portfólio

Executar somente se URL, protótipo ou material de design for explicitamente incluído. Registrar URL/artefato, páginas, viewports, estados e interações efetivamente inspecionados. Percorrer posicionamento, narrativa/arquitetura, descoberta, cases e evidências, visual/legibilidade, reflow móvel/tablet, acessibilidade e controles, contato/conversão, consistência/manutenção. Pontuações 1–5 são diagnóstico profissional com critério e evidência localizada; não representam pesquisa de recrutador, benchmark ou certificação.

Cada finding recebe prioridade P0–P3, impacto, recomendação, esforço, risco/dependência e confiança; incluir rota concisa do visitante e plano por fases. Cobrir cada dimensão com observação fundamentada ou `not_observed`. Comparar alternativas abertas com descoberta, escaneabilidade, profundidade, mobile, acessibilidade, manutenção e brief fornecido. Usar apenas leitura: sem autenticação, formulários, ações de estado, edição ou publicação. Sinais ausentes não viram propriedades testadas ou medidas.

## 18. Reconstrução de contribuição e raciocínio técnico (US14)

Ativar quando a pessoa solicitar reconstrução histórica/técnica ou quando ela fizer parte da preparação editorial. A etapa é opcional, usa fontes locais, fornecidas ou públicas sem autenticação e não depende de Notion, conta privada ou serviço externo. Consultar o runbook local `engineering-reconstruction.md`; o fluxo relaciona A1, sistemas/tecnologias já observados, evidências e consolidação no mesmo Markdown.

Começar por uma pergunta e escopo: produto/sistema, baseline e janela. Reutilizar IDs e evidências existentes; para cada afirmação material, registrar localização, relação de suporte/limite/contradição/contexto, dimensão que a fonte sustenta, tipo de conclusão e limite. Separar autoria registrada, comportamento/estrutura, decisão/intenção relatada, colaboração, validação e resultado. Commit, existência de sistema, teste configurado ou mecanismo plausível não transferem prova para essas outras dimensões.

Quando fontes convergentes permitem uma explicação, redigir o menor enunciado que elas sustentam. Quando houver conflito, alternativas ou contraevidência, preservar ambos os lados e justificar a interpretação candidata. `hypothesis` é uma interpretação revisável, não evidência; `unknown`, `not_observed` e `unavailable` não provam que algo não ocorreu. A confiança (`high`, `medium`, `low`) segue a rubrica do vocabulário comum: tipo/direção de fonte, corroboração, contradição e escopo; sem suporte suficiente, não atribuir nota. Não inventar percentuais, motivação, qualidade, autoria exclusiva, causalidade, benefício ou resultado.

Perguntar à pessoa somente quando a resposta puder alterar materialmente atribuição, interpretação ou wording seguro e não houver rota razoável de recuperação. Detalhes irrecuperáveis podem permanecer desconhecidos sem bloquear o restante. Sugestões de apresentação ficam `draft`, ligadas à procedência e abertas a aceitação/correção/rejeição; revisão editorial não apaga findings ou fontes. Prosa e ordem são livres, com zero a três destaques curtos conforme suporte e relevância.

A avaliação de compreensibilidade define antes do leitor/perfil, perguntas, tarefa e critérios; depois registra observações qualitativas e limitações. Não criar taxas, limiares empíricos, previsão de contratação ou aprovação sem dados. Fixtures de aceitação são sintéticas e não executam conteúdo de `target-repos/`.
