# Diggy, the dog

> Documento: schema 2.1.0 | Estado: partial | Atualizado: 2026-10-05
> Método: RepoDNA Audit, metodologia local incorporada | Baseline escolhida para esta auditoria: LudumDare-48/feature/project-update@d14c3b639696c20fa5dcce2e2908970d2332e7e1

## Start Here

Este documento consolida a análise do repositório selecionado pelo usuário como LudumDare-48, produto identificado nos Player Settings como Diggy, the dog. A baseline escolhida pelo usuário é o commit d14c3b6, na branch feature/project-update, derivada de develop. Na checagem final, o checkout do caminho estava em develop@d93bbec; as conclusões deste relatório permanecem explicitamente limitadas à árvore do commit d14c3b6. O histórico acessível inclui trabalho de abril de 2021 e duas atualizações em outubro de 2026. O alvo não foi aberto em Unity/IDE, executado, compilado, testado ou perfilado. As conclusões técnicas são estáticas.

O Git atribui ao nome informado pelo usuário contribuições no protótipo, movimento, obstáculos, progressão/distância, composição de cena, áudio/transições, configuração WebGL e uma atualização recente para Unity 6.6. A atualização mais recente é agora um commit atribuído à mesma identidade Git observada nos commits anteriores e confirmada pelo nome fornecido. Isso sustenta autoria registrada desses diffs, mas não autoria exclusiva do jogo, de conteúdo visual/sonoro, nem validação da atualização.

**Bloqueio de compartilhamento:** ProjectSettings/ProjectSettings.asset contém um campo chamado ps4Passcode com valor preenchido na baseline atual; ele também aparece preenchido em quatro revisões Git localmente acessíveis. O valor foi deliberadamente omitido deste documento. Não foi possível confirmar validade, titularidade ou se essas revisões foram enviadas ao servidor remoto. Não compartilhar/publicar a configuração ou o histórico antes de verificar esse campo por processo autorizado e, se for credencial real, invalidá-la/substituí-la e avaliar a exposição do histórico.

O perfil Windows/Codex/PowerShell não oferece enforcement preventivo comprovado contra escrita no alvo. Uma diferença de inventário apareceu durante a primeira comparação. Após autorização do usuário, não foi encontrado processo Unity/IDE associado ao projeto; a baseline feature/project-update@d14c3b6 foi recapturada e duas leituras consecutivas ficaram estáveis. Na checagem final, porém, o checkout observado já estava em develop@d93bbec, com 1.574 arquivos rastreados e 6 refs locais; a baseline escolhida pelo usuário continua sendo o commit d14c3b6, cuja árvore contém 1.584 paths e permanece localmente disponível. A mudança do checkout não foi atribuída. Portanto, a auditoria fica ancorada ao commit escolhido, mas a preservação do estado mutável do alvo é partial/changed. Arquivos ignorados não receberam fingerprint de conteúdo completo.

**Limites editoriais:** a origem/licença de vários assets não está determinada; o artefato publicado não está ligado a um commit; não há medições de runtime ou playtest com procedência. Estado parcial não significa aprovação para publicar ou autorização para reutilizar mídia.

## At a Glance

| Tema | Resposta atual | Estado / limite |
|---|---|---|
| Produto | Jogo Unity 2D chamado Diggy, the dog; contexto indicado pelo nome LudumDare-48 | Fato sobre configuração e seleção; empresa/cargo ou participação formal no evento não inferidos [E-001, E-010, E-032] |
| Baseline analisada | feature/project-update@d14c3b6, Unity 6.6.0f1; 1.584 paths rastreados | O checkout estava em develop@d93bbec no fechamento; build e runtime não observados [E-032–E-034, E-039] |
| Loop observado estaticamente | Intro, movimento do cão, obstáculos, distância/limite, encontro com toupeira e telas de resultado | Código e cena/configuração sustentam o fluxo; execução não verificada [E-013, E-014, E-036] |
| Stack demonstrada | Unity, C#, física 2D, Cinemachine, DOTween, TextMesh Pro e composição por cenas/prefabs | Estado estático; package declarado não prova exercício runtime [E-034, E-036] |
| Contribuição de Phillipe Augusto | Trabalho em sistemas de jogo em 2021 e atualização/migração Unity 6.6 em 2026 | Autoria Git ligada à identidade confirmada; sem alegação de autoria exclusiva, cargo ou impacto [E-003–E-009, E-033] |
| Outros contribuidores | Git registra outros autores e integrações | Roster incompleto por limite de fontes; divulgação de nomes/aliases de terceiros não autorizada neste estudo [E-002, E-003] |
| Dado sensível | Campo ps4Passcode preenchido na baseline e em quatro commits locais | Bloqueador para compartilhar configuração/histórico até validar e, se real, invalidar/rotacionar; conteúdo suprimido [E-035, F-006, Q-003] |
| Privacidade adicional | Metadados Git incluem endereços associados a autores; UserSettings e configuração de IDE estão versionados | Endereços omitidos; avaliar histórico e preferências locais antes de distribuição [E-037, F-012] |
| Release | Página itch.io foi identificada em uma consulta anterior; source/build não correlacionados | Contexto retido, não revalidado nesta retomada; versão pública continua unresolved [E-021, F-007] |
| Performance/QA | Sem medições nem testes de produto observados | not_measured; não alegar performance, estabilidade ou playtest [E-031, F-008] |
| Preservação | Duas leituras após recaptura d14c3b6 foram estáveis; uma checagem posterior encontrou o checkout em develop@d93bbec | changed/partial; origem da troca e do delta de inventário desconhecida; arquivos ignorados sem fingerprint integral [E-032, E-038, E-039] |

## Study Map

- A1 — identidade, timeline e contribuições: Roster, identidade e papel/equipe.
- B1 — sistema, arquitetura, configuração e tecnologias: Índice técnico e Sistemas e arquitetura.
- B2 — riscos estáticos e medições: Decisões e trade-offs e Apêndice B2.
- B3 — source, artefato e destino: Timeline e releases.
- B4 — claims, créditos, privacidade e mídia: Projeção pública e prontidão editorial.
- Evidências recuperáveis e baseline: Evidências e índice; Baseline e preservação.
- Questões em aberto: validação do campo potencialmente sensível, proveniência de assets, release e brief editorial.

## Índice técnico de tags

Vocabulário RepoDNA Audit / schema 2.1.0. O estado registra evidência estática no baseline d14c3b6; não prova execução em runtime. Declaração/resolução, consumidor, configuração, origem e exercício são dimensões separadas.

| Faceta:slug / T-ID | Conceito | Perfil atual | Ocorrências |
|---|---|---|---|
| engine:unity / T-001 | Unity Editor/engine | observed_use; 6.6.0f1 configurado | O-001 |
| language:csharp / T-002 | C# | observed_use em scripts próprios e de terceiros | O-002 |
| package:cinemachine / T-003 | Unity Cinemachine | package 6.6.0 declarado/resolvido e consumidor referenciado | O-003 |
| package:dotween / T-004 | DOTween / Demigiant | código vendorizado e chamadas DG.Tweening; versão exata não confirmada | O-004 |
| framework:textmesh-pro / T-005 | TextMesh Pro | recursos e consumidor TMPro no projeto | O-005 |
| engine-feature:unity-2d-physics / T-006 | Física 2D Unity | Rigidbody2D, Collider2D e interações por trigger | O-006 |
| engine-feature:unity-tilemap / T-007 | Unity Tilemap | assets e conteúdo serializado presentes | O-007 |
| platform:webgl / T-008 | WebGL | template e configuração histórica presentes; build atual não observado | O-008 |
| package:unity-recorder / T-009 | Unity Recorder | 5.1.7 declarado/resolvido; consumidor não observado | O-009 |
| package:unity-test-framework / T-010 | Unity Test Framework | 1.8.0 declarado/resolvido; suite do produto não observada | O-010 |
| package:unity-ai-navigation / T-011 | AI Navigation | 2.0.14 declarado/resolvido; consumidor não observado | O-011 |
| pattern:singleton / T-012 | Estrutura de instância única | inference localizada em managers; sem alegação de implementação canônica | O-012 |
| pattern:observer-events / T-013 | Delegates/callbacks | estrutura de eventos localizada; sem alegação de arquitetura global | O-013 |
| package:unity-timeline / T-014 | Unity Timeline | declarado/resolvido; consumidor não observado | O-014 |

Pacotes declarados incluem Animation 2D, Pixel Perfect, PSD Importer, Sprite Shape, Tilemap, AI Navigation, Cinemachine, Recorder, Test Framework, Timeline, UGUI e módulos Unity. Manifest/lock são evidência de declaração/resolução, não prova de instalação material, consumo funcional ou uso em runtime. Não se identificou integração de IA de produto, técnica/provedor/modelo de IA ou evidência local de assistência de IA durante o desenvolvimento. Esse resultado significa not_observed nos arquivos/refs examinados, não prova de que não houve uso. Há arquivos MP3/WAV; codec não foi inferido de extensão. Não foi identificada evidência suficiente para classificar padrão arquitetural global.

### Ocorrências técnicas

| O-ID | T-ID | Sistema/finalidade; contexto/origem | Localização no repo/baseline | Estado e limite |
|---|---|---|---|---|
| O-001 | T-001 | Engine para cenas e scripts Unity | ProjectSettings/ProjectVersion.txt | 6.6.0f1; configuração atual no commit d14c3b6; nenhuma compilação/execução [E-033, E-034] |
| O-002 | T-002 | Gameplay e editor | Assets/_Project/Scripts/*.cs | C# observado; versão da linguagem e build não verificados [E-036] |
| O-003 | T-003 | Câmeras virtuais e extensão de câmera; runtime configurado | Packages/manifest.json, packages-lock.json, GameController.cs, LockCameraX.cs | 6.6.0 declarado/resolvido e consumidor estático referenciado [E-033, E-034, E-036] |
| O-004 | T-004 | Animação/transições; terceiro vendorizado | Assets/Plugins/Demigiant/DOTween e chamadas nos scripts | Presença/uso estático; versão/licença completa não determinada [E-013, E-019, E-036] |
| O-005 | T-005 | Texto e UI; terceiro/local | Assets/TextMesh Pro e scripts/cenas com TMPro | Consumidor estático encontrado; versão/licença por ativo não totalmente determinada [E-019, E-036] |
| O-006 | T-006 | Movimento, colisão e limites | MovementController.cs, Mole.cs, EndPosition.cs e cena | Uso estático; cenário/resultado de runtime não verificado [E-013, E-014, E-036] |
| O-007 | T-007 | Organização visual do nível | Assets/_Project/Tilemap e GameplayDev.unity | Assets serializados presentes; carregamento de todos os tiles na publicação não estabelecido [E-014, E-015] |
| O-008 | T-008 | Preparação de página/build Web | Assets/WebGLTemplates/BetterMinimal e ProjectSettings | Evidência histórica de template/settings; não prova build ou release do HEAD atual [E-009, E-010, E-021] |
| O-009 | T-009 | Captura/produção de mídia; contexto editor potencial | manifest/lock | 5.1.7 declarado/resolvido; consumidor não observado [E-034, E-031] |
| O-010 | T-010 | QA; contexto test | manifest/lock e inventário de paths | 1.8.0 declarado/resolvido; nenhuma suite de testes do produto encontrada no escopo [E-034, E-031] |
| O-011 | T-011 | Navegação; runtime/editor potencial | manifest/lock e código rastreado | 2.0.14 declarado/resolvido; consumidor não observado [E-034, E-031] |
| O-012 | T-012 | Coordenação de instância | GameController, AudioManager, TransitionsController | Campos estáticos de instância e descarte de duplicatas; inference restrita a essas classes [E-013, E-036] |
| O-013 | T-013 | Intro, eventos e início de jogo | GameController, DogIntro, MoleIntro, StartPosition | Actions/callbacks observados; descrição estrutural, não padrão global [E-013, E-036] |
| O-014 | T-014 | Timeline; contexto runtime/editor potencial | Packages/manifest.json e packages-lock.json | 6.6.0 declarado/resolvido; consumidor não observado [E-034] |

## Roster de contribuidores

Escopo: author metadata, diffs e refs Git localmente acessíveis; baseline atual d14c3b6 e histórico acessível sem fetch. Janela observada: 23–26 abr. 2021 e 3–5 out. 2026. A lista é de contribuidores identificados no escopo, não uma lista total comprovada. Os identificadores de contato dos commits foram omitidos.

| P-ID | Tipo/identidade observada | Base de identificação | Divulgação |
|---|---|---|---|
| P-001 | Pessoa; Phillipe Augusto, nome declarado pelo usuário; Git também registra uma forma longa do nome e um alias curto | Continuidade fortemente sustentada por nome/contexto e identificador Git repetido; não comprova propriedade externa da conta [E-003, E-033] | Nome foi fornecido pelo usuário para esta análise; não implica autorização para divulgar contatos ou case |
| P-002 | Pessoa/alias Git Thiago Berardinelli | Nome de autor repetido; aparecem identificadores Git distintos que não foram fundidos nesta análise | Divulgação pública desconhecida |
| P-003 | Pessoa/alias Git Gabriel | Nome curto em commits | Pode ser ambíguo; não reconciliado com pessoa fora do Git |
| P-004 | Pessoa/alias Git Gabriel em formato noreply | Registro de author distinto | Não fundir com P-003 sem evidência de continuidade |

| K-ID | Trabalho e atribuição | Sistema/repo/baseline/intervalo | Vínculo e wording seguro |
|---|---|---|---|
| K-001 | Individual no registro de author Git; código/composição do protótipo e movimento | Gameplay inicial, feature/project-update; commits da janela 23–26 abr. 2021 | P-001 → K-001 → O-002/O-006. Implementou/estendeu partes do protótipo; não autoria de todos assets [E-004, E-006] |
| K-002 | Individual no registro Git; spawner e integração de prefabs de obstáculos | GameplayDev, abril de 2021 | P-001 → K-002 → O-002/O-006. Implementou o spawner; comportamento, balanceamento e arte não medidos/atribuídos [E-005, E-016] |
| K-003 | Individual no registro Git; início/fim e apresentação de distância | Scripts/cena, abril de 2021 | P-001 → K-003 → O-002/O-006. Adicionou a apresentação de distância e estendeu fluxo de fase [E-006, E-013] |
| K-004 | Individual no registro Git; apresentação, ajustes de cena, tela/template WebGL | Cena e configurações, abril de 2021 | P-001 → K-004 → O-008. Configuração presente; build/publicação não provados [E-007, E-009] |
| K-005 | Compartilhada/integração; áudio, transições e manutenção da cena | Assets e scripts de áudio, abril de 2021 | P-001 → K-005 → O-004/O-005. Configurou/integrou partes; autoria do sistema completo é compartilhada [E-008] |
| K-006 | Individual no registro Git; migração/configuração Unity 6.6, atualizações de pacotes/shaders/settings e compatibilidade de scripts de câmera, física e Editor | Commit d14c3b6, 5 out. 2026 | P-001 → K-006 → O-001/O-003/O-006. Atualizou arquivos e código; o subject do commit não prova que issues de gameplay foram resolvidas em runtime nem que a migração compila [E-033] |
| K-007 | Individual no registro Git; inclusão da thumbnail no commit d93bbec | develop, 3 out. 2026 | Author Git associado a Phillipe; inclusão não demonstra criação visual, licença ou publicação da imagem [E-011] |

Volume de commits, churn, merges e autoria Git não são score de impacto ou liderança. A atribuição de K-006 é uma reavaliação de K-006 anteriormente descrita como mudança local sem autoria: ela passou a estar em um commit e o author corresponde à identidade confirmada. Trabalho não codificado, arte/áudio, QA, revisão, decisão e operação sem fonte continuam unknown. Não herdar toda a stack do projeto para o perfil individual.

## Prontidão editorial do projeto

### Brief e papel editorial

- Brief de público/cargo/canais: unknown; não fornecido.
- Contexto sustentado: jogo colaborativo Unity 2D chamado Diggy, the dog; a associação a Ludum Dare 48 é indicada pelo nome do projeto e pela página pública indexada observada anteriormente, não por comprovante de submissão.
- Papel editorial recomendado: unclassified, agent_recommendation. Pode ser considerado Supporting/Technical se um brief futuro priorizar sistemas de gameplay em Unity. Não há inventário comparável nem decisão humana; nenhum ranking é feito.
- Quick scan em menos de 60 segundos e percurso de evidências de 5–10 minutos não foram testados com leitores.

### Case e pacote proporcional

Uma narrativa segura pode descrever contexto colaborativo → responsabilidade sustentada → mecanismo implementado → trade-offs estáticos → evidência Git → resultado limitado ao snapshot. Histórias candidatas: distribuição de obstáculos; fluxo de movimento/progresso; atualização técnica para Unity 6.6. A terceira deve dizer que uma migração foi commitada, não que compila ou corrigiu comportamento em runtime.

Não há evidência de métricas, playtest, feedback de usuários, impacto, emprego ou cargo. Claims quantitativas e de resultado estão bloqueadas até fonte com procedência. O material visual pode demonstrar o jogo, mas origem/licença de imagens, sprites, tile art, áudio, thumbnail e conteúdo de terceiros precisa ser verificada por ativo e por ação antes de copiar, embutir, recortar, baixar ou hospedar novamente.

| Dimensão editorial | Estado | Condição |
|---|---|---|
| Texto factual sobre trabalho identificado | complete_with_conditions | Wording qualificado e revisão pessoal antes de uso externo |
| Campo ps4Passcode e histórico Git | incomplete_blocking | Validar fora do relatório; se credencial válida, invalidar/rotacionar e avaliar remoção/reescrita do histórico antes de divulgar |
| Ownership e créditos de equipe | incomplete_blocking para autoria exclusiva | Múltiplos autores e origem de assets incompleta |
| Release/source/build | incomplete_blocking para alegar versão publicada | Nenhum hash ou vínculo de build |
| Mídia e permissões | incomplete_blocking para reuso | Permissão/licença de vários assets desconhecida |
| Resultados/performance | incomplete_blocking para claims quantitativas | Nenhuma medição/procedência |
| Cargo/emprego | not_observed | Configuração de empresa/commits não demonstram emprego |

## Identidade e contexto

O usuário selecionou explicitamente target-repos/LudumDare-48 e indicou Phillipe Augusto como a pessoa para investigação. Player Settings registram productName Diggy, the dog e companyName LudumDare48. O campo companyName é configuração, não evidência de empresa legal, emprego ou cargo [E-001, E-010, E-032].

Remote configurado: github.com/GabrielVianaGaming/LudumDare-48.git. Branch local selecionada: feature/project-update; HEAD d14c3b6, com origin/feature/project-update como ref de acompanhamento. Há também develop, main e branches remotas de features no repositório local. Nenhum fetch foi feito. O histórico não é raso; não há tags nem submódulos. O repositório remoto configurado não prova visibilidade pública ou que cada ref local foi enviada [E-002, E-032].

O conteúdo indica jogo de cão e toupeira com movimento, obstáculos, progressão por distância e condições de resultado. Nome/evento e página indexada anterior são contexto; não há registro local que determine exatamente o horário de submissão ou qual commit foi submetido. Um jogo homônimo de outra equipe, descrito em registro anterior como distinto, não foi relacionado a este produto [E-022].

## Papel, equipe e contribuições

As evidências de author Git ligam os dois nomes históricos de Phillipe e a forma curta recente ao nome fornecido pelo usuário, com o mesmo identificador de author. Isso sustenta continuidade da identidade investigada, sem afirmar controle legal da conta. O histórico registra outros autores; endereços foram deliberadamente suprimidos [E-002, E-003, E-033].

| ID | Conclusão | Confiança e limite | Evidência |
|---|---|---|---|
| F-001 | fact + personal_account: produto selecionado é Diggy, the dog | Alta para configuração e seleção; não declara propriedade legal | [E-001, E-010, E-032] |
| F-002 | inference: aliases Git de Phillipe correspondem à pessoa investigada | strongly_supported pelo nome declarado e identificador repetido; não verifica conta fora do Git | [E-003, E-033] |
| F-003 | fact: desenvolvimento registrado tem múltiplos autores e integrações compartilhadas | Alta para author/diffs no histórico; não mede contribuição sem commit ou trabalho de terceiros | [E-002, E-008] |
| F-011 | fact: a atualização Unity 6.6 antes vista como alteração local consta agora em commit de Phillipe | Alta para author e paths alterados; execução, compilação e motivação em detalhe não estabelecidas | [E-027–E-029, E-033] |
| F-012 | fact/risk: endereços associados a autores estão em metadados Git; preferências locais aparecem versionadas | Ocorrência sustentada; exposição no servidor e presença de identificadores dentro dos arquivos não foram integralmente determinadas | [E-037] |

| ID | Tipo e conclusão | Confiança, impacto e limite | Evidência |
|---|---|---|---|
| F-004 | static_risk: o spawn pode não terminar em limites saturados ou sem posição livre, pois usa tentativa sem limite | Risco condicional; não observado em execução | [E-014, E-016] |
| F-005 | static_risk: seleção de música pode reiniciar a faixa repetidamente dentro do loop | Depende da composição do array e execução; efeito não ouvido | [E-017] |
| F-006 | fact/security: ps4Passcode está preenchido em ProjectSettings e em quatro revisões Git locais | Valor omitido; validade/titularidade não verificadas; bloqueia compartilhar config/histórico até triagem | [E-035] |
| F-007 | unresolved: nenhum elo source commit → build → destino público foi fechado | Ausência no inventário examinado não prova que artefato nunca existiu | [E-002, E-015, E-021] |
| F-008 | not_measured: não há perfil, benchmark, teste automatizado ou resultado de runtime com procedência | Impede claims de performance/impacto | [E-031, E-036] |
| F-009 | inference/static_risk: import de UnityEditor em caminho de scripts pode afetar compilação de player | Precisa de validação externa na versão atual; falha não foi demonstrada | [E-024, E-025, E-033] |
| F-010 | static_risk: AudioManager remove chaves de preferência no Awake | Intenção e efeito em execução desconhecidos | [E-026] |
| F-013 | fact/limitation: inventário e checkout mudaram entre checkpoints | Primeiro delta de +1 arquivo/+3 diretórios/+169 bytes; depois checkout observado em develop@d93bbec, com 25 arquivos a menos que a leitura recapturada. Origem desconhecida | [E-038, E-039] |
| F-014 | static_risk: spawn testa ponto candidato e não impõe limite nem valida explicitamente volume total do collider | Possível bloqueio ou sobreposição é hipótese estática, não defeito observado | [E-016] |

**Wording seguro para experiência:** “Contribuí para sistemas de gameplay e integração de Diggy, the dog em Unity, incluindo protótipo, geração de obstáculos, apresentação de distância e composição de cena; em 2026, atualizei o projeto para Unity 6.6 e adaptei partes de código/configuração.” Acrescentar que o projeto é colaborativo. Não alegar autoria exclusiva, cargo, performance, publicação da versão atual ou impacto sem fontes adicionais [C-001–C-004, C-008].

## Sistemas e arquitetura

O projeto contém cenas Unity, prefabs, animações, tile assets, scripts C# e conteúdo de áudio/imagem. O fluxo reconstruído estaticamente é: intro com cão/toupeira → estado de jogo e liberação de movimento → deslocamento com obstáculos e exibição de distância → colisão com limite ou toupeira → transição e painel de resultado. Essa sequência é inferida de componentes e referências serializadas; não foi executada [E-013, E-014, E-036].

| Sistema | Estado | Evidência e limite |
|---|---|---|
| Movimento do cão | implemented no snapshot | Input Manager legado lido em Update; movimento/rotação aplicados em FixedUpdate via Rigidbody2D; não testado [E-013, E-036] |
| Toupeira / vitória | implemented no snapshot | Mole ajusta velocidade/animação; trigger com jogador inicia parada e transição de vitória; referências de cena não foram validadas [E-013, E-036] |
| Intro | implemented no snapshot | DogIntro/MoleIntro coordenam animação, tween, partículas e chamadas de evento; sem validação visual [E-013] |
| Obstáculos | implemented no snapshot | ObstacleSpawner instancia prefabs em posições aleatórias limitadas por collider; cena registra quantidade 80; spawn não executado [E-005, E-014, E-016] |
| Distância/falha | implemented no snapshot | EndPosition calcula distância entre ponto base da toupeira e destino e inicia fluxo de falha em trigger; comportamento serializado, não playtest [E-006, E-013] |
| Áudio/transições | implemented no snapshot | AudioManager e TransitionsController organizam fontes, música/efeitos e transições; resultado audível não medido [E-013, E-017] |
| Conteúdo de cena | presente | Game.unity e GameplayDev.unity existem; GameplayDev.unity é a cena habilitada em EditorBuildSettings; isso não demonstra que seja a cena distribuída [E-014, E-032] |
| WebGL | configuração histórica/presente em conteúdo | BetterMinimal e configurações de tela/Player Settings estão no repositório; build atual não observado [E-009, E-010] |
| Testes | not_observed | Unity Test Framework declarado; nenhum teste de produto identificado no inventário [E-031, E-034] |
| Dados/código sensível | potencialmente sensível | ps4Passcode preenchido e mantido no histórico local; conteúdo omitido. Ver F-006/Q-003 [E-035] |

## Decisões e trade-offs

- Obstáculos: posicionamento aleatório por tentativas reduz configuração manual, mas o método não limita tentativas e verifica se o ponto escolhido está contido nos colliders já existentes; não há verificação explícita de colisão integral do novo collider [E-016].
- Input: Input.GetAxisRaw usa configuração legada, enquanto Rigidbody2D é atualizado em FixedUpdate. Compatibilidade com configurações de plataforma não foi exercitada [E-010, E-013].
- Composição: cenas/prefabs armazenam referências e parâmetros; inspeção do código isolado não valida referências ou condições de execução [E-014].
- Música: CheckcurrentMusicPlaying chama PlaySound(currentsong) dentro do loop de faixas de música para cada entrada diferente; com várias faixas isso pode reiniciar música repetidamente. Efeito depende da lista configurada e não foi ouvido [E-017].
- Preferências: AudioManager.Awake apaga as chaves SfxMuted e MusicMuted quando singleton é inicializado. Intenção e efeito percebido não foram testados [E-026].
- Editor/runtime: HierarchyWindowGroupHeader.cs importa UnityEditor fora do bloco condicional que protege a classe e está sob Scripts, não pasta Editor. É um risco de compilação de player a investigar; não declaramos que o build falha sem validação externa [E-024, E-025, E-033].
- Atualização 2026: commit d14c3b6 muda configuração e APIs para Unity 6.6, mas nenhuma compilação ou teste foi realizado. Subject do commit não é prova de correção funcional [E-033].

## Reconstruções e destaques técnicos

| R-ID | Síntese candidata | Tipo/confiança/estado editorial | Suporte, alternativas e limites |
|---|---|---|---|
| R-001 | O spawner usa tentativa aleatória dentro de limites e evita aceitar um ponto contido em colliders previamente instanciados. | fact sobre código; confiança high no snapshot; draft editorial | Commits/código sustentam mecanismo. Não há limite de tentativas, prova de que o collider inteiro não sobreponha outro, nem evidência de playtest/resultado [E-005, E-016]. |
| R-002 | A atualização de 2026 adaptou o projeto Unity e partes de scripts à versão 6.6. | fact sobre alterações/author; confiança high para o diff; draft editorial | d14c3b6 altera versão/pacotes/shaders/configuração e scripts; não prova que migração compila ou resolve gameplay [E-033]. |

## Timeline e releases

| Data/ref | Evento Git ou contexto | Relação com release |
|---|---|---|
| 23 abr. 2021 | Commits iniciais observados em main/develop | Não há artefato correlacionado [E-002] |
| 23–26 abr. 2021 | Desenvolvimento do gameplay, obstáculos, UI, áudio e configuração por múltiplos autores | História de trabalho; não identifica o snapshot submetido [E-002, E-004–E-009] |
| 26 abr. 2021 | Commits de configuração/cena atribuídos à identidade Phillipe | Não prova envio ou artefato final [E-009] |
| 3 out. 2026 | d93bbec em develop adiciona thumbnail | Inclusão Git observada; autoria visual/licença/release não estabelecidas [E-011] |
| 5 out. 2026 | d14c3b6 em feature/project-update atualiza Unity para 6.6 e adapta arquivos/scripts | HEAD atual; sem build ou vínculo de publicação [E-033] |
| 5 out. 2026, consulta pública anterior | Resultado indexado do itch.io apresentou título/autoria/plataforma e tag Ludum Dare 48 | Contexto retido do estudo anterior; página direta falhou e não liga publicação a hash/commit [E-021] |

A cadeia evento → commit → build → upload → versão pública permanece unresolved. O repositório não tem tags Git ou artefato de build rastreado. A página pública indexada anteriormente descreve uma publicação, mas não identifica o source snapshot; a atualização de 2026 não deve ser apresentada como versão publicada [F-007, Q-001].

## Projeção pública e claims

| ID | Wording | Estado | Evidência/ressalva |
|---|---|---|---|
| C-001 | “Contribuí para partes do protótipo e da integração de Diggy, the dog em Unity.” | safe | Histórico e identidade de author; colaboração explícita [E-003–E-009] |
| C-002 | “Implementei um spawner que instancia obstáculos a partir de prefabs em posições aleatórias.” | qualified | Commit/código; sem afirmar balanceamento, qualidade ou teste [E-005, E-016] |
| C-003 | “Adicionei a apresentação de distância e partes da integração de início/fim da fase.” | qualified | Diffs e cena; resultado de playtest não comprovado [E-006] |
| C-004 | “Trabalhei na configuração de tela e em um template WebGL do projeto.” | qualified | Arquivos/configuração históricos; não prova produção/publicação de build [E-009, E-010] |
| C-005 | “A página de Diggy, the dog foi apresentada como jogo HTML5/Unity associado a Ludum Dare 48.” | qualified, retained_context | Metadado indexado em consulta anterior; não revalidado agora e sem vínculo de artefato [E-021] |
| C-006 | “Criei o jogo inteiro / fui o único autor / criei todos os assets.” | unsupported | Histórico multi-autoria e origem incompleta de conteúdo [E-002, E-008, E-020] |
| C-007 | “O jogo tem performance comprovada, foi otimizado ou elevou métricas.” | unsupported | Nenhum resultado medido com procedência [E-016, E-017, E-031] |
| C-008 | “Atualizei o projeto para Unity 6.6 e adaptei scripts/configuração.” | qualified | Author/diff d14c3b6 sustentam alteração; não dizer que compila, corrige o jogo ou foi publicada [E-033] |
| C-009 | “A configuração do projeto está livre de segredos e pronta para divulgação.” | rejected | Campo de passcode preenchido na baseline/histórico local; validade/exposição não resolvidas [E-035, F-006, Q-003] |

## Evidências e índice

| ID | Fonte/localização recuperável | Síntese e limite |
|---|---|---|
| E-001 | target-repos/LudumDare-48; caminho canônico, remotes e settings | Alvo escolhido pelo usuário; title/settings não provam propriedade legal |
| E-002 | refs e git log --all, local, sem fetch | Histórico, aliases, autores, branches e ausência de tags/submódulos |
| E-003 | Git author/committer names e identificadores mascarados; shortlog | Identidade Phillipe fortemente correlacionada ao nome informado; contatos omitidos |
| E-004 | Commit 0d584df; GameplayDev.unity, Mole.cs, StartPosition.cs, EndPosition.cs, MovementController.cs | Cena/lógica inicial de jogo atribuídas no Git |
| E-005 | Commit 71bc881; ObstacleSpawner.cs, prefabs de obstáculos e cena | Spawner e integração serializada |
| E-006 | Commit b2878fb e 218ef6d; EndPosition, StartPosition, Mole e cena | Progressão/distância e limites |
| E-007 | Commit 2651fe6 e 338f59a; PulseScale e GameplayDev.unity | Botão/apresentação e ajustes de cena |
| E-008 | Commits de áudio c06c82f/86cdc40 e refs de feature correspondentes | Integração compartilhada de áudio/transições; contatos omitidos |
| E-009 | Commits b6f6297 e 338f59a; template BetterMinimal e settings | Configuração WebGL/tela; build não provado |
| E-010 | ProjectVersion/ProjectSettings históricos em develop@d93bbec | Unity 2020.3.1f1/settings antigas; supersedidas pelo HEAD Unity 6.6 para estado atual |
| E-011 | Commit d93bbec; Assets/_Project/Sprites/thumb.png | Inclusão de thumbnail; origem/criação/licença não estabelecidas |
| E-012 | Packages manifest/lock em develop@d93bbec | Baseline histórica de pacotes |
| E-013 | Scripts de GameController, MovementController, Mole, DogIntro, MoleIntro, EndPosition, StartPosition, AudioManager, TransitionsController e ObstacleSpawner | Fluxos estáticos descritos; não prova execução |
| E-014 | GameplayDev.unity, EditorBuildSettings, campos serializados | Configuração de cena/spawn; não valida referências em runtime |
| E-015 | Inventário rastreado histórico de assets de imagem/animação/áudio/fonte/tilemap | Conteúdo sem autoria individual presumida |
| E-016 | ObstacleSpawner.GetOpenRandomPosition | Loop sem limite e verificação de ponto candidato |
| E-017 | AudioManager.CheckcurrentMusicPlaying | Chamada de PlaySound dentro do loop de faixas; efeito runtime não medido |
| E-018 | ProjectSettings da baseline antiga | Observação de campo de passcode preenchido no snapshot de auditoria anterior; valor nunca registrado no relatório |
| E-019 | DOTween readme; TextMesh Pro EmojiOne Attribution e licença OFL de fonte | Atribuição/licença local para alguns componentes, não para todo conteúdo |
| E-020 | Inventário de Assets, Packages e ProjectSettings | Licenças/origem incompletas para várias mídias |
| E-021 | Resultado indexado de página itch.io consultado no estudo anterior | Contexto de título/plataforma/tag; página direta falhou; source/build não correlacionados; não foi revalidado nesta retomada |
| E-022 | Referência anterior à página homônima de outra equipe | Produto distinto, excluído |
| E-023 | Busca anterior por entrada Ludum Dare | Não retornou resultado naquela consulta; não prova inexistência |
| E-024 | HierarchyWindowGroupHeader.cs | using UnityEditor está fora do bloco condicional da classe |
| E-025 | Documentação Unity 2020.3 registrada no relatório anterior | Explica risco histórico; não é documentação da versão Unity 6.6 atual |
| E-026 | AudioManager.Awake | Remove chaves SfxMuted e MusicMuted; intenção/efeito não verificados |
| E-027 | Baseline anterior de 2026-10-05 em develop, HEAD d93bbec | 1.574 paths e 81 mudanças locais naquela sessão; histórico preservado como checkpoint, não descreve baseline atual |
| E-028 | Configuração local examinada no checkpoint anterior | Unity 6.6 e pacotes; atribuição então desconhecida e passcode potencialmente preenchido; status agora superado por commit d14c3b6 |
| E-029 | Diff local do checkpoint anterior | Mudanças em quatro scripts então sem atribuição; conteúdo atualizado/commitado em d14c3b6 |
| E-030 | Diretórios DOTween/TextMesh Pro e scripts consumidores | Uso estático e versões/licenças incompletas |
| E-031 | Inventário Git/testes e busca textual no checkpoint anterior | Sem suite de teste do produto nem sinais locais suficientes de IA; ausência não prova inexistência |
| E-032 | Baseline recapturada em 2026-10-06 01:56 UTC; feature/project-update@d14c3b6; GIT_OPTIONAL_LOCKS=0 | 1.584 paths rastreados, 21 refs, sem tags/submódulos, status limpo; duas leituras estáveis de status, refs e inventário |
| E-033 | Commit d14c3b6, author/committer Phillipe Augusto; diff-tree de 47 paths | Unity 6.6.0f1, alterações de packages/shaders/settings/scripts e arquivos UserSettings; sustenta alteração atribuída, não build/runtime |
| E-034 | Packages/manifest.json, packages-lock.json, ProjectSettings/ProjectVersion.txt, EditorBuildSettings.asset, ProjectSettings.asset | Unity 6.6.0f1, pacotes declarados/resolvidos, GameplayDev habilitada; não confirma build |
| E-035 | Leitura estática de campos sensíveis sem emitir valores; ProjectSettings/ProjectSettings.asset; git log --all das revisões alcançáveis | ps4Passcode preenchido no HEAD e em quatro revisões locais; outros campos consultados estavam vazios. Valor não capturado no relatório; não confirma validade nem envio remoto |
| E-036 | 25 scripts C#; Game/GameplayDev scenes; manifests/settings; inventário de assets | Fluxos e riscos citados; não inclui validação dinâmica nem interpretação de binários por ferramenta |
| E-037 | Author metadata e inventário de paths UserSettings/, .idea/; busca textual local com valores omitidos | Emails associados a autores existem em metadados Git; arquivos de preferências IDE/Unity estão versionados; não é auditoria exaustiva de privacidade |
| E-038 | Inventário recapturado do diretório alvo, duas leituras estáveis antes da checagem final | 20.448 arquivos, 1.901 diretórios, 1.626.576.461 bytes; contagem inicial anterior era 20.447 arquivos/1.898 diretórios; diferença de +1 arquivo, +3 diretórios e +169 bytes sem causa atribuída |
| E-039 | Leitura final somente de metadados Git e inventário agregado, após a recaptura | Checkout em develop@d93bbec, 1.574 paths rastreados, 6 refs locais, status limpo; 20.423 arquivos, 1.895 diretórios, 1.626.466.095 bytes. A árvore do commit escolhido d14c3b6 continua localmente disponível com 1.584 paths; nenhuma troca de branch foi feita pelo agente |

## Cobertura e estado das etapas

| Etapa/domínio | Estado | Escopo/limite |
|---|---|---|
| Preparação, identidade e baseline | partial | Alvo sem ambiguidade; baseline de commit explicitamente escolhida; host unverified; checkout final divergiu para develop e delta de inventário sem atribuição |
| A1 forense/contribuição | complete_with_conditions | Refs Git localmente disponíveis e diffs representativos; trabalho sem commit, identidade de alguns aliases e fontes externas privadas não cobertos |
| B1 produção/arquitetura/tags | partial | Scripts, cenas, manifests/configuração e inventário de paths; assets binários não interpretados por decoder/editor |
| B2 runtime estático | partial | Riscos e configuração revisados; sem execução, testes ou medições |
| B3 release/procedência | partial | Sem tags/build/hash; metadado público é contexto anterior não revalidado |
| B4 claims, privacidade e mídia | partial | Campo sensível encontrado e conteúdo omitido; emails em metadata; licença/origem de assets e exposição remota pendentes |
| Reconstrução de engenharia | partial | R-001/R-002 são sínteses draft ligadas às fontes; motivos, validação, resultados e reflexão pessoal não inferidos |
| Revisão de superfície | not_applicable | Nenhum site/protótipo visual foi selecionado nesta solicitação |
| Consolidação e preservação | partial | Um Markdown canônico atualizado para d14c3b6; checkout observado mudou para develop ao fechamento; host sem enforcement e cobertura ignorada limitada |

## Questões, conflitos e bloqueios

| ID | Estado | Pergunta/ação que fecha a lacuna |
|---|---|---|
| Q-001 | open_nonblocking | Qual commit/build HTML5 foi submetido/publicado? Hash, build metadata ou artefato correlacionado fecharia os elos |
| Q-002 | open_nonblocking | Quem criou/forneceu cada sprite, tile set, áudio, fonte, template e thumbnail? Quais licenças cobrem as ações editoriais pretendidas? |
| Q-003 | open_blocking para compartilhar configuração/histórico | O valor do campo ps4Passcode é credencial real ou dado fictício? Verificar por processo autorizado; se real, invalidar/rotacionar e avaliar a exposição/remediação do histórico Git remoto antes de compartilhar |
| Q-004 | open_nonblocking | Há registro oficial do evento ou cópia histórica de build que identifique a submissão? |
| Q-005 | open_nonblocking | Há medições/playtest com cenário, plataforma, build e procedência para sustentar claims de qualidade/performance? |
| Q-006 | open_nonblocking | GameplayDev.unity corresponde à versão publicada ou é cena de desenvolvimento? É necessário vínculo de artefato/source |
| Q-007 | open_nonblocking | O reset de SfxMuted/MusicMuted é deliberado? Intenção não inferida do código |
| Q-008 | open_nonblocking | Qual público/cargo/canal e quais projetos comparáveis devem orientar papel editorial? Até então manter unclassified |
| Q-009 | resolved para atribuição Git | O commit d14c3b6 tem author/committer Phillipe Augusto e identificador correlacionado aos registros anteriores; autoria de atividades fora do diff continua unknown |
| Q-010 | open_nonblocking antes de distribuição ampla | Revisar arquivos UserSettings e .idea por preferências/identificadores locais e verificar qual email de author pode ser divulgado; valores não são repetidos neste relatório |
| Q-011 | open_nonblocking | Qual processo/ação explica o delta de inventário (+1 arquivo/+3 diretórios e depois -25 arquivos no inventário agregado)? Origem não determinada; status Git estava limpo |
| Q-012 | open_nonblocking | Por que o checkout/ref set mudou de feature/project-update@d14c3b6 para develop@d93bbec (21 para 6 refs observadas)? O agente não fez checkout, fetch ou alteração Git; causa não determinada |

A mudança no inventário durante a auditoria permanece sem explicação. Duas leituras após recaptura foram estáveis; isso não permite atribuir a mudança anterior ao agente, ao usuário ou a outro processo. As conclusões vinculadas a Git/HEAD se mantiveram na baseline d14c3b6; arquivos ignorados permanecem fora de comparação integral.

## Apêndices

### A1 — Forense

- Baseline atual: feature/project-update@d14c3b6; refs e history locais lidos com GIT_OPTIONAL_LOCKS=0. Nenhum fetch ou alteração de refs.
- Janela observada: 23–26 abr. 2021, 3 out. 2026 e 5 out. 2026. Não há evidência de atividade contínua entre os períodos.
- Autoria: diffs sustentam author Git registrado; merges integram trabalho de outras pessoas e não foram tratados como autoria individual.
- Identidade investigada: Phillipe Augusto conforme informado pelo usuário, correlacionado a author IDs locais. Contatos omitidos.
- Roster parcial: aliases de terceiros não fundidos quando o identificador difere ou nome é curto; sem inferir total da equipe.

### B1 — Produção e arquitetura

- Engine atual: Unity 6.6.0f1; linguagem C#; física 2D e scenes/prefabs Unity.
- Cenas: Game.unity e GameplayDev.unity; GameplayDev está habilitada em EditorBuildSettings. A Demo de Flat Screen Transitions é conteúdo de plugin.
- Sistemas: GameController coordena intro/eventos/estados; MovementController movimento; Mole/EndPosition vitória/falha/progresso; ObstacleSpawner coloca obstáculos; AudioManager/TransitionsController gerenciam som e telas.
- Stack demonstrada: Cinemachine, DOTween, TextMesh Pro, Unity UI e física 2D. Outros packages permanecem declarados/resolvidos até haver consumidor.
- Configuração e build: template BetterMinimal e histórico de configuração WebGL; branch atual não foi construída. Player Settings incluem campo de passcode que impede compartilhamento até validação.
- Conteúdo: imagem, animação, áudio, prefabs, fontes e tilemaps. Origem e permissão de uma parte do conteúdo não estão demonstradas.

### B2 — Runtime estático

| ID | Tipo | Observação | Limite |
|---|---|---|---|
| Terminação do spawn | static_risk | ObstacleSpawner.GetOpenRandomPosition usa while true procurando posição livre; cena serializa 80 obstáculos | Pode não terminar em espaço saturado/bounds inválidos; nenhuma ocorrência ou probabilidade medida [E-014, E-016] |
| Seleção de música | static_risk | CheckcurrentMusicPlaying pode chamar PlaySound repetidamente para cada outra faixa musical | Efeito depende do array/execução e não foi ouvido [E-017] |
| Medição | not_measured | Sem benchmark/perfil/resultado de runtime com procedência | Não alegar FPS, estabilidade, otimização, GC ou causalidade [E-031] |
| Import de Editor | inference/static_risk | UnityEditor importado fora do bloco condicional em script sob Scripts; risco potencial ao compilar player | Não executado; referência Unity 2020 anterior não prova comportamento em Unity 6.6 [E-024, E-025, E-033] |
| Preferências | static_risk | AudioManager.Awake chama PlayerPrefs.DeleteKey para SfxMuted e MusicMuted | Intenção/frequência e efeito no jogo não testados [E-026] |
| Colisão de obstáculos | static_risk | A rotina de spawn testa ponto candidato contra colliders já criados, não valida explicitamente o collider inteiro nem limita tentativas | Potencial sobreposição ou bloqueio; hipótese estática, não falha observada [E-016] |

Nenhuma ferramenta de build/teste/perfil foi usada. Validação futura deve ser feita por processo externo independente, com baseline e cenário explícitos.

### B3 — Release e procedência

| Elo | Estado | Evidência |
|---|---|---|
| Evento → produto | strongly_supported como contexto, não comprovante | Nome/código e página indexada anteriormente; sem registro de submissão |
| Evento → commit | unresolved | Datas coincidentes não identificam source snapshot enviado |
| Commit → build | unresolved | Sem artefato/hash/build metadata |
| Build → itch.io | unresolved | Página indexada anteriormente sem vínculo de hash; não revalidada nesta retomada |
| HEAD atual → versão pública | unresolved | d14c3b6 não tem correlação de build/publicação |

### B4 — Publicação, privacidade e créditos

| Dimensão | Readiness | Estado |
|---|---|---|
| Texto factual de contribuição | complete_with_conditions | Claims qualificados; revisão pessoal |
| Arquivo de configuração e histórico | incomplete_blocking | Campo ps4Passcode preenchido no HEAD e em quatro revisões; não divulgar até verificar/tratar |
| Dados pessoais em metadata | incomplete_nonblocking para análise local; revisar antes de publicar | Endereços author Git omitidos; confirmar configurações/visibilidade do repositório |
| Arquivos UserSettings/.idea | incomplete_nonblocking | Versionados; verificar preferência, identidade e histórico de pesquisa local antes da distribuição |
| Código e configuração | incomplete_blocking enquanto o passcode permanecer não avaliado | Remediação/autorização é decisão externa à auditoria |
| Imagens, tile art, áudio, fonte, template, thumbnail | incomplete_blocking para reuso não coberto | Crédito, origem e permissão variam por asset/ação |
| Página pública | complete_with_conditions como link/contexto | Metadado indexado anterior; embed/captura/rehosting não autorizados por esta análise |
| Métricas/performance | incomplete_blocking para claims quantitativas | Sem resultados medidos com procedência |
| Cargo/emprego | not_observed | Configuração de empresa/commits não demonstram emprego |

O relatório não concede autorização legal, licença, aprovação humana ou permissão de publicação.

### Reconciliação de fontes

| Fonte | Classificação | Motivo |
|---|---|---|
| Repositório local LudumDare-48 | incorporated | Evidência primária de baseline, código, configuração e histórico local |
| Página itch.io de Diggy, the dog observada em consulta anterior | retained_context | Metadados indexados e acesso direto indisponível naquela consulta; sem source/build correlation e sem revalidação nesta retomada |
| Página homônima de outra equipe descrita no estudo anterior | distinct_project | Autores/engine/contexto diferentes segundo registro anterior; sem fusão |
| Página oficial Ludum Dare | not_observed | Busca anterior não localizou uma entrada; não prova inexistência |
| Serviços privados, Notion ou fontes pessoais não fornecidas nesta solicitação | unavailable/not_observed | Não consultados; o método não depende deles |

### Histórias de engenharia e talking points

1. **Distribuição de obstáculos:** o código instancia prefabs em pontos aleatórios delimitados e tenta evitar posições já ocupadas. O caminho não limita tentativas nem verifica explicitamente a colisão integral do novo objeto. O spawner está presente; sucesso/qualidade em execução e playtest permanecem desconhecidos. Evidência: F-004/F-014, E-005/E-016.
2. **Progresso da fase:** EndPosition calcula a distância a partir de um ponto base da toupeira e inicia fluxo de falha no limite. Isso sustenta implementação estática e apresentação de progresso, não experiência do jogador ou equilíbrio. Evidência: C-003, E-006/E-013.
3. **Atualização técnica:** d14c3b6 atualiza o projeto para Unity 6.6, settings e pacotes, e adapta scripts relacionados à API. O diff é atribuído no Git à identidade investigada; resultado compilável/correto precisa de validação externa. Evidência: C-008, E-033/E-034.

### Histórico de verificação

- 2026-10-05: auditoria anterior do mesmo produto em develop@d93bbec e snapshot local com 81 entradas no status Git. O registro foi migrado no mesmo arquivo; findings daquele snapshot não descrevem o HEAD atual.
- 2026-10-05: o relatório anterior marcou a migração Unity 6.6 como alteração local sem autoria. Agora o commit d14c3b6 a registra com identidade Git correlacionada a Phillipe; K-006/F-011/Q-009 foram reavaliados.
- 2026-10-05: página itch.io consultada em busca indexada e não carregou diretamente. Esta retomada reteve tal observação como contexto, sem reconsulta.
- 2026-10-06 01:56 UTC: após o usuário autorizar parar processos e recapturar baseline, nenhum processo Unity/IDE com linha de comando contendo o caminho-alvo foi encontrado. Nova baseline ficou estável em duas leituras separadas por 8 segundos.
- 2026-10-06: revisão estática de refs/histórico, scripts centrais, scenes/settings, packages e padrões de privacidade. Campo ps4Passcode preenchido foi identificado sem copiar/exibir valor. Sem execução de scripts/código do alvo ou abertura em Unity/IDE.
- 2026-10-06: o inventário inicial e a baseline recapturada diferem por uma unidade de arquivo e três diretórios; a origem não foi determinada. Status Git permaneceu sem alterações. A sessão não atribui essa diferença ao agente.
- 2026-10-06: a escolha explícita do usuário confirmou que a baseline pretendida é feature/project-update@d14c3b6. A checagem final encontrou o checkout em develop@d93bbec, com seis refs locais e inventário agregado menor; a árvore d14c3b6 continua no object store local com 1.584 paths. Nenhum checkout ou fetch foi executado para restaurá-la. Preservação geral marcada partial/changed.
- 2026-10-06: documento canônico atualizado in-place; nenhum outro relatório persistente criado.

## Baseline e preservação

| Item | Baseline recapturada e comparação |
|---|---|
| Alvo | C:\Users\[perfil-local]\.codex\worktrees\7b60\repo-dna\target-repos\LudumDare-48 |
| Git associado | .git dentro do alvo; gitdir e common dir locais; sem submódulos declarados; object store não fingerprintado |
| Baseline de auditoria escolhida | LudumDare-48, feature/project-update@d14c3b639696c20fa5dcce2e2908970d2332e7e1; 1.584 paths na árvore do commit |
| Checkout na recaptura | feature/project-update@d14c3b6, ref local origin/feature/project-update; 21 refs locais; 0 tags; histórico não raso |
| Gate após recaptura | 2026-10-06 01:56 UTC; GIT_OPTIONAL_LOCKS=0 em comandos leitores; branch/HEAD/status/ref list e inventário repetidos em duas leituras |
| Working tree/index | 0 entradas em git status --porcelain=v2 --untracked-files=all nas duas leituras |
| Conteúdo rastreado | 1.584 paths segundo git ls-files; conteúdo total não recebeu hash agregado neste fechamento |
| Inventário amplo | 20.448 arquivos, 1.901 diretórios, 1.626.576.461 bytes incluindo conteúdo ignorado/gerado e metadados Git; duas leituras iguais |
| Delta pré-rebaseline | Primeira leitura: 20.447 arquivos, 1.898 diretórios, 1.626.576.292 bytes. Após autorização e recaptura: +1 arquivo, +3 diretórios, +169 bytes; origem não identificada. Git permaneceu limpo |
| Ignorados | status/lista foi observado durante a sessão; conteúdo dos diretórios Library, Temp, Logs, obj, artefatos de IDE e outros paths ignorados não foi integralmente fingerprintado; número e conteúdo podem variar |
| Proteção do host | unverified: alvo dentro de checkout gravável; nenhum bloqueio preventivo comprovado; igualdade observada não garante que o host impediu escrita |
| Ambiente | Windows, Codex exec/PowerShell; nenhuma IDE, Unity, build, script ou ferramenta do alvo foi iniciada. Na checagem pós-aviso, nenhum processo Unity/IDE associado ao caminho foi encontrado |
| Saída canônica | analysis-output/diggy-the-dog.md, fora do alvo e de seu Git; documento existente atualizado in-place |
| Fechamento | Checagem final observou develop@d93bbec, 6 refs locais, status limpo e inventário agregado de 20.423 arquivos; divergiu do checkpoint feature/project-update@d14c3b6 |
| Estado de preservação | changed/partial para o alvo mutável; observed_unchanged somente entre as duas leituras do checkpoint d14c3b6, nunca como garantia do host |
| Cobertura geral de preservação | partial: checkout/ref state mudou, delta de inventário sem causa, conteúdo ignorado sem fingerprint completo, object store/metadados internos sem comparação e host unverified |

Nenhum conteúdo do alvo foi executado, compilado ou intencionalmente alterado pelo agente. O método observou o alvo sem escrever nele; a ausência de enforcement impede chamar isso de garantia. O relatório de auditoria é o único artefato persistente atualizado.
