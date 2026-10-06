# Quickstart: Cenários de validação planejados

Esta página define cenários que a futura skill deve suportar. Eles não foram executados durante o planejamento.

**Extensão prevista**: schema 2.1.0 amplia o mesmo Markdown para tags, ocorrências e contribuidores; os casos novos abaixo também não foram executados nesta etapa.

## Requisitos

- Checkout RepoDNA com skill Codex disponível.
- Repositório selecionado em target-repos/.
- Host capaz de assegurar que o processo não escreva nos caminhos do alvo.
- Sem dependência de instalar pacotes no alvo ou acessar serviço remoto.

**Estado atual da plataforma:** os perfis Codex listados na matriz permanecem `unverified`. A auditoria pode começar com aviso; não há garantia preventiva de que o host impeça escrita acidental e o relatório não pode afirmar preservação garantida. Testes multiplataforma de fixtures não alteram esse estado.

## Fluxo feliz

1. Colocar uma cópia do repositório em target-repos/demo-repo/.
2. Abrir Codex no RepoDNA e iniciar a skill principal de auditoria.
3. Selecionar demo-repo, confirmar produto/escopo e identificar pessoa se necessário.
4. Percorrer A1 e os aprofundamentos aplicáveis sem executar conteúdo do alvo nem escrever nele intencionalmente.
5. Se o host não comprovar bloqueio de escrita, informar o risco e continuar; registrar cobertura, checkpoints e preservação como não verificada até comparação final.
6. Abrir analysis-output/<safe-product-slug>.md.

**Esperado**: exatamente um Markdown canônico com status/baseline, cobertura, Start Here, evidências/limites, estado das fases e perguntas. Nenhuma alteração no alvo.

## Cenários de validação

| Cenário | Resultado |
|---|---|
| Alvo sem mudanças locais | Um Markdown; estado final compatível; sem relatório paralelo |
| Arquivos tracked alterados + untracked/ignored | Baseline local preservada/referenciada; estado final equivalente; findings separam mudanças preexistentes |
| Symlink/junction/Git externo | Escopo seguro ou bloqueio antes de leitura extensa |
| Pedido para executar script/build/test/profiling | Fora do escopo em qualquer modo; nenhum fluxo do framework inicia validação dinâmica |
| Produtos com nomes parecidos | Não funde nem sobrescreve; pede identidade/slug explícitos |
| Vários repositórios declarados como um produto | Um Markdown com cada evidência ligada ao repo/baseline de origem |
| Fonte/artefato ausente | Unavailable/not_observed; nunca falso negativo |
| Host sem garantia readonly | Preflight avisa; análise estática prossegue e preservação fica `unverified`/`observed_unchanged` |
| Medição existente incompleta ou cenário não comparável | Registrar procedência/campos ausentes; não alegar ganho ou regressão sem condições equivalentes |
| Sem medição de runtime | Distinguir tamanho de build, configuração e risco estático; propor perguntas/verificação futura sem executar o alvo |
| Mídia pública com permissão incompleta | Avaliar link, embed, cópia, crop, download/rehosting e alteração de áudio como ações separadas; manter sem suporte as permissões desconhecidas |
| Reconciliação de notas antigas | Classificar cada item relevante como incorporado, contexto retido, projeto distinto, histórico/superado ou irrelevante; registrar fonte e motivo sem editar a fonte |
| Pacote compartilhado em vários repositórios | Ligar alteração, versão, produto consumidor e release; consolidar a contribuição uma vez e apontar para cada evidência de origem |
| Brief editorial ausente/parcial | Manter público, cargo, canal e restrições sem suporte como desconhecidos; registrar origem e estado dos valores informados |
| Projetos sem inventário comparável | Avaliar aderência individual ao brief, sem ranking global; quando houver conjunto explícito, expor rationale e decisão humana/provisória |
| Case com evidência incompleta | Manter lacunas em ownership, trade-off, resultado ou reflexão; não preencher simetricamente nem promover recomendação a fato |
| Featured vs Archive/Supporting | Mostrar metas e gaps proporcionais ao papel, preservando entradas de arquivo e resumo factual seguro |
| Leitura rápida e estudo aprofundado | Com leitor sem contexto, cronometrar localização de produto/contexto e contribuição (meta ≤60 s) e a rota até prova detalhada de um case (meta ~5–10 min); registrar participante, documento, tarefa e tempos observados |
| Inventário de mídia Featured | Registrar separadamente os ativos disponíveis e os 4–7 itens significativos selecionados; se permissões/ativos faltarem, deixar o gap explícito em vez de inflar o conjunto |
| Site/protótipo explicitamente no escopo | Registrar páginas, viewports e interações vistas; cada dimensão recebe evidência ou `not_observed`; nenhuma ação muda estado |
| Alternativa visual/acessível ainda aberta | Comparar opções contra brief, descoberta, acessibilidade, manutenção e evidência; manter decisão pendente quando requer escolha humana |
| Só manifest declara um framework | Mostrar declaração exploratória e fonte; não classificar como instalado, usado ou experiência individual |
| Lock resolve uma dependência, mas arquivo não está disponível | Registrar versão resolvida segundo a fonte, com disponibilidade/instalação desconhecida |
| Package transitivo é chamado pelo código próprio | Manter relação transitiva e uso estático observado em eixos distintos, apontando para o consumidor |
| Package está no runtime, teste, editor, exemplo ou vendor | Preservar contexto/origem; o perfil de uso não mistura exemplo, dependência de teste ou terceiros com runtime próprio |
| Alias de tag versus conceito homônimo | Sinônimos apontam para uma chave; conceitos próximos ou ambíguos permanecem distintos/pendentes |
| Tipo chamado `Factory` sem criação encapsulada | Não classificar padrão sem participantes, comportamento e consumidor sustentados |
| Componentes demonstram Strategy/Observer apenas num subsistema | Registrar estrutura, evidência e escopo local; não generalizar ao sistema inteiro |
| `AGENTS.md` ou instruções específicas de assistente estão presentes | Registrar sinal de instrução/configuração e deixar atividade de ferramenta/tarefa sem prova como desconhecida |
| SDK de IA declarado, sem fluxo consumidor | Registrar package/sinal exploratório; não afirmar integração funcional do produto |
| Cliente de IA ligado a sistema e modelo configurado | Ligar integração, finalidade, configuração e ocorrências; manter execução/provedor/modelo efetivos sem prova como não verificados |
| Commit menciona assistência de IA | Identificar como declaração atribuída, sem percentuais de código ou autoria exclusiva |
| Contêiner/extensão de mídia sem metadados de stream | Identificar apenas formato demonstrado; codec desconhecido |
| Arquivo de extensão `.mp4` e metadata de codec disponível em fonte estática | Registrar contêiner e codec em campos distintos e ligar fonte/baseline |
| Autor, committer e coautor distintos | Preservar cada papel e fonte; não reduzir ao nome de quem integrou o commit |
| Mesmo nome ou email compartilhado sem confirmação | Manter identidades distintas/pendentes e roster parcial |
| CODEOWNERS ou review configurados sem prova de implementação | Registrar responsabilidade/revisão observada; não inferir autoria, cargo ou liderança |
| Designer, artista, pessoa de áudio ou QA creditados fora do Git | Listar contribuição não codificada com fonte, atribuição e escopo |
| Pessoa está listada na equipe mas não tem contribuição/ocorrência ligada | Não apresentar a stack do projeto como experiência pessoal dela |
| Bot ou autor de asset de terceiro | Registrar automação/procedência numa seção/tipo próprio; não inflar a equipe de pessoas |
| Fontes do roster incompletas, squash ou histórico raso | Dizer “contribuidores identificados no escopo”, listar fontes e lacunas; não alegar roster completo |
| Atualização remove uma tecnologia | Preservar ocorrência passada como histórica e excluir do filtro de uso atual |
| Relatório legado 2.0.0 | Na atualização, migrar para 2.1.0 no mesmo Markdown e registrar gaps/IDs preservados |
| Sem rede, parser ou catálogo externo | Completar o que fontes locais sustentarem; listar não observados e limites, sem instalar ferramenta |

## Validação do complemento de privacidade e autoridade

Executar `bash tests/run.sh --framework` no checkout do framework. Os casos usam
somente dados fictícios em diretório temporário. Esperado: metadados privados
sintéticos no índice bloqueiam mesmo quando o documento de trabalho está limpo;
diagnósticos não mostram valores privados; áreas locais privadas ficam ignoradas.

Executar `python scripts/check-public-context.py` antes de compartilhar. A revisão
cobre índice e arquivos atuais; se houver versão antiga no índice, preparar apenas
os arquivos sanitizados e repetir a revisão. Complementar com revisão semântica.

Percorrer o mapa local `source-inventory.md` e todas as referências obrigatórias
da skill sem acesso a fontes originais. Esperado: preparação, A1, B1–B4, evidência,
reconciliação, consolidação e revisão estão recuperáveis localmente. Isso valida
instruções e cobertura, não comprova suporte do host para uma auditoria real.

## Revisão do entregável

- Confirmar um único arquivo de saída por produto.
- Rever integridade do alvo; git status limpo sozinho não basta.
- Verificar referências, cobertura, claims e autoridade atual.
- Confirmar que não se executaram artefatos do alvo ou geraram relatórios paralelos.
- Confirmar que brief/classificação/recomendação têm origem e estado, e que as seções editoriais ou de superfície permanecem no mesmo Markdown.
- Para superfície avaliada, conferir notas justificadas, dimensões `not_observed`, escopo observado, percurso, findings priorizados e ausência de autenticação, submissão ou alteração de estado.
- Para SC-025, realizar a revisão cronometrada com leitor sem contexto e registrar tempos reais; inspeção estática do template comprova presença dos campos, mas não comprova que o limite de tempo foi atingido.
- Para SC-026, conferir um case Featured da fixture: quatro a sete itens visuais significativos selecionados ou lacunas explícitas de mídia/permissão, separados do inventário disponível.
- Para SC-028–030, verificar chaves/aliases/ocorrências, casos positivos/negativos de packages e padrões; percorrer tag até sistema, baseline e evidência.
- Para SC-031–032, cobrir instruções/declarações/atividade IA e integração do produto, mais contêiner versus codec; usar apenas fixtures sintéticas e fontes estáticas locais.
- Para SC-033–034, reconciliar identidades/fonte/cobertura e trabalho além de commits; comprovar que uma tecnologia só vira experiência individual mediante vínculo explícito sustentado.
- Para SC-035–037, atualizar fixture 2.0.0, preservar o Markdown único e sua privacidade, e simular indisponibilidade de catálogo/rede sem lacuna silenciosa.

**Estado de validação de SC-025 nesta implementação:** o roteiro e os casos sintéticos estão prontos, mas ainda não foi conduzida sessão cronometrada com leitor humano sem contexto. Portanto, a meta de 60 segundos/5–10 minutos está implementada como critério verificável, mas seu resultado empírico permanece pendente.

## Consultas de tags e tecnologias (US12)

Use os casos fictícios em `tests/fixtures/readonly-audit/technology-tags/README.md`. Para cada conceito, percorrer `faceta:slug → T-### → O-### → sistema/repo/baseline/localização → E-###`. Exemplos de perguntas reprodutíveis:

1. Quais packages têm uso estático observado em runtime próprio neste baseline? Excluir declaração isolada, testes, editor, exemplos, terceiros e ocorrências stale; retornar sistema, localização e evidência.
2. O que aparece apenas em manifest/lock e qual versão está declarada/resolvida? Não chamar disponível/instalado sem fonte local adequada.
3. Que padrões foram sustentados por participantes, relações e comportamento, e em qual escopo? Manter candidatos e falsos positivos fora da lista afirmativa.
4. Quais sinais existem para assistência de desenvolvimento, IA no produto, técnica e provedor/modelo? Mostrar cada dimensão separada e explicitar o que não pode ser verificado estaticamente.
5. Que arquivos de mídia têm codec demonstrado por metadata disponível? Separar formato/contêiner e deixar codec desconhecido se só houver extensão.

O contrato automatizado é `bash tests/technical_tags_contract_test.sh`; usa apenas fixtures e documentos do framework. A matriz valida consulta local/offline sem parser ou catálogo obrigatório.

## Consultas de contribuidores e experiência individual (US13)

Use `tests/fixtures/readonly-audit/contributors/README.md` e pergunte: “Quais contribuidores foram identificados dentro do escopo e por quais fontes?”, “Que trabalho não codificado tem suporte?”, “Quais tecnologias aparecem ligadas às contribuições desta pessoa?” e “Quais aliases, intervalos ou créditos permanecem incertos?”. Respostas de experiência precisam percorrer `P-### → K-### → O-###/T-### → E-###`, apontando baseline e limite. Sem a relação explícita, não devolver stack coletiva como competência individual.

O contrato automatizado é `bash tests/contributor_attribution_contract_test.sh`; identidades e fontes são sintéticas. Ele valida cobertura incompleta, aliases pendentes, tipos de bot/terceiro, contribuições fora do Git e atribuição conservadora.

## Migração de schema e uso sem rede

Para `legacy-2.0.0`, atualizar o mesmo arquivo para 2.1.0, conservar IDs/fontes/histórico válidos e registrar baseline antiga, novo vocabulário, mapeamentos e campos ainda não avaliados. Ocorrências removidas seguem no histórico; evidências com baseline não revalidada ficam stale. Não concluir cobertura pelo aparecimento de headings. Repetir as consultas acima sem rede, catálogo ou parser e manter indisponibilidades explícitas; nenhum relatório adicional é criado.

**Cobertura US12/US13**: o harness `bash tests/run.sh --framework` inclui os dois contratos novos, o contrato do Markdown 2.1.0 e a revisão de privacidade com valores sintéticos de tags/contribuidores. Os casos são documentação/fixtures do framework e nunca executam conteúdo de `target-repos/`.

## Reconstrução de contribuição e narrativa técnica (US14)

Siga o [runbook de reconstrução](../../.agents/skills/repodna-audit/references/engineering-reconstruction.md) e os limites de fonte do [A1](../../.agents/skills/repodna-audit/references/forensic-a1.md). Use somente fontes locais, fornecidas ou públicas sem autenticação. A fixture sintética `tests/fixtures/readonly-audit/engineering-reconstruction/README.md` e o verificador estático cobrem os cenários abaixo; ambos passaram na suíte seletiva do framework. Nenhum exemplo usa dado pessoal, empresa ou projeto real, e nenhum conteúdo de `target-repos/` é lido ou executado por esse contrato.

| Caso | Comportamento esperado |
|---|---|
| Memória limitada + diff/documentação convergentes | Criar reconstrução parcial com claims ligados a baseline/localização e confiança justificada; motivação sem prova permanece desconhecida/inferida. |
| Fontes conflitantes ou issue/review privada indisponível | Preservar conflito/unavailable/not_observed; não alegar consulta nem ausência do evento. |
| Commit de grupo e sistema existente | Atribuir somente mudança/metadado sustentados; não inventar quem decidiu, colaborou ou possui o sistema inteiro. |
| Mecanismo plausível sem dado de resultado | Explicar efeito estático separadamente do benefício possível; sem métrica/causalidade factual. |
| Teste configurado sem resultado | Registrar configuração, sem declarar execução, aprovação ou qualidade. |
| Log com escopo delimitado | Associar resultado ao snapshot, cenário e ambiente conhecidos; não generalizar para produto/release. |
| História escrita fora da sequência FR-083 | Aceitar ordem e prosa livres, deixando dimensão sem suporte como lacuna e rastreando afirmações. |
| Evidência fraca/insuficiente | Permitir zero destaques; os que forem sustentados permanecem concisos, draft e corrigíveis sem mudar fontes/findings. |
| Leitura compreensível | Definir antes perfil, perguntas e critérios; registrar observações qualitativas sem percentual inventado ou promessa de contratação. |

Para cada afirmação material, valide localização recuperável, baseline/escopo, relação (`supports`, `limits`, `contradicts`, `context_only`), tipo (`fact`, `inference`, `personal_account`, `hypothesis`, `conflict`, `unknown`/`not_observed`), caveat e rationale de confiança. `high` requer suporte direto sem contradição material aberta; `medium` representa suporte parcial/indireto ou limitado sem alternativa igualmente sustentada; `low` representa suporte fraco/ambíguo ou alternativas igualmente plausíveis. Sem suporte suficiente, mantenha `unknown`/`unsupported` sem nota. Justifique pela direção/tipo de fonte, corroboração, contradições e escopo. Não confunda teste/configuração com resultado nem autoria registrada com decisão/colaboração. Separe consequência estática de impacto.

Antes de avaliar compreensibilidade, defina perfil do leitor, perguntas e critérios de rastreabilidade/clareza. Registre tarefa, observações, lacunas e limitações qualitativas; não invente percentuais ou promessa de contratação. Essa avaliação é diferente da validação cronometrada SC-025, que continua reservada à T105 como última validação humana. O fluxo permanece offline e não executa conteúdo de `target-repos/`.

**Rastreabilidade revisada para US14:** FR-114–116 e SC-038–040 cobrem fontes permitidas e dimensões que cada fonte sustenta; FR-117–120 e SC-040/043 limitam inferências sobre pessoa, decisão e desafio; FR-121–122 e SC-041–042 separam consequência, validação e resultado; FR-123–124 e SC-044–045 mantêm prosa flexível e drafts revisáveis; FR-125 e SC-046 definem revisão qualitativa com critérios prévios. SC-039/047 são cobertos pela rota de evidência e rubrica desta seção. T132–T133 criam fixtures e verificador; T142–T143 integram o contrato ao harness e cobrem campos de reconstrução no guard de privacidade. Os 16 contratos do harness seletivo passaram. Essa automação não substitui a revisão humana cronometrada SC-025/T105, que permanece pendente e será a validação final.

## Consulta por agente de IA

1. Fornecer ao agente somente o Markdown canônico gerado para o produto e usar os casos registrados em `tests/fixtures/readonly-audit/ai-retrieval-cases.md`.
2. Fazer as perguntas predefinidas sobre identidade, contribuições, arquitetura, release atual/histórico e principal limite sem fornecer as respostas esperadas.
3. Para cada caso, anotar se cada afirmação factual inclui referência recuperável ao finding/evidência, baseline e limite pertinente; registrar IDs citados e qualquer extrapolação.
4. Confirmar que informação ausente é declarada desconhecida e não preenchida por inferência sem suporte. Aprovação exige citações em 100% das afirmações factuais e unknown preservado nos casos sem suporte.

**Esperado**: todas as respostas factuais do conjunto têm evidência rastreável; nenhuma afirmação sem suporte é promovida a fato. A cópia posterior para Notion/Docs é feita pelo usuário e não integra o fluxo do framework.

## Primeiro uso: encontrar como iniciar

1. Usar uma pessoa que ainda não conhece o RepoDNA nem a skill de auditoria.
2. Fornecer o checkout do RepoDNA e uma fixture pronta em `target-repos/`; iniciar a contagem.
3. Pedir que encontre a instrução de início, inicie a skill e identifique o aviso de proteção do host e o primeiro passo de seleção do alvo.
4. Parar a contagem quando a pessoa chegar ao preflight sem inspecionar o conteúdo do alvo.

**Esperado**: a pessoa encontra como iniciar em até cinco minutos. Registrar perfil do participante, fixture e tempo observado.
