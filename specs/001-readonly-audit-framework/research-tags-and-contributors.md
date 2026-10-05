# Pesquisa: tecnologias, padrões, IA, tags e contribuidores

**Data da pesquisa:** 2026-10-05
**Feature existente:** [001-readonly-audit-framework](spec.md)
**Estado:** proposta de complemento para futura especificação; sem alteração do contrato atual.
**Objetivo:** permitir que o Markdown canônico responda quais tecnologias e práticas aparecem no projeto, como e onde são usadas, qual evidência sustenta cada conclusão e quem contribuiu para cada área.

Este documento consolida pesquisa online em fontes primárias e recomendações de desenho para o RepoDNA. As recomendações são síntese deste estudo, não funcionalidades já implementadas nem exigências das fontes externas. Os exemplos de caminhos, sistemas e pessoas são fictícios. Fontes externas fundamentam o desenho; a futura auditoria continua podendo operar com o método local, sem Notion, serviços externos ou instalação de ferramentas.

## 1. Recomendação principal

Adicionar ao único Markdown em `analysis-output/` três áreas conectadas:

1. **Tags e índice de tecnologias:** vocabulário normalizado e resumo para filtros, com estado explícito e links para os registros detalhados.
2. **Tecnologias, padrões e uso de IA:** inventário qualificado, ocorrências por sistema/repositório/baseline, finalidade, evidências, limites e relevância técnica.
3. **Pessoas e contribuições:** lista de identidades observadas, contribuição demonstrada ou declarada, sistemas relacionados, período observado, fontes e restrições de divulgação. Automações e assistência por IA ficam identificadas separadamente.

A relação central deve ser:

`tag → registro técnico → ocorrência → sistema/repositório/baseline → evidência`

Quando houver atribuição suficiente:

`pessoa → contribuição → ocorrência/sistema → evidência de autoria ou crédito`

Uma tag isolada informa muito pouco. A mesma tecnologia pode estar somente declarada, aparecer em exemplos, ser dependência transitiva, integrar uma ferramenta de desenvolvimento ou estar diretamente conectada ao produto. O índice deve preservar essas diferenças para que um filtro não transforme presença de arquivos em experiência profissional comprovada.

**Decisões recomendadas:**

| Tema | Recomendação | Motivo |
|---|---|---|
| Formato | Tabelas e registros com IDs dentro do Markdown existente | Preserva a saída única e permite leitura humana e recuperação por agentes. |
| Tags | Facetas com chaves estáveis, rótulos e aliases | Evita fragmentar `C#`, `CSharp` e `csharp` ou confundir ferramenta com padrão. |
| Evidência | Reutilizar `E-###`, findings, sistemas e contribuições existentes | Evita uma segunda fonte de verdade. |
| Uso | Preservar `installed`, `possible_use`, `observed_use`, `active_configuration` | Mantém compatibilidade com o vocabulário atual. |
| Filtros | Perfis explícitos para uso observado, configuração, candidatos e histórico | Quem consulta consegue escolher o significado da busca. |
| IA | Separar assistência ao desenvolvimento, integração no produto e técnicas/modelos | Um projeto com instruções para agente não necessariamente oferece IA ao usuário. |
| Pessoas | Listar contribuições de código e também design, arte, áudio, documentação, QA e outras | Git é uma fonte parcial de créditos. |
| Atualização | IDs estáveis; ocorrências antigas ficam históricas ou stale | Mudanças de stack não devem apagar a experiência passada nem inflar a atual. |
| Privacidade | Método público genérico; dados de projetos/pessoas somente no relatório local autorizado | Preserva a separação já definida entre framework e contexto particular. |

## 2. O que a pesquisa sustenta

### 2.1 Linguagem de arquivo não equivale a stack ou domínio pessoal

O GitHub Linguist classifica arquivos combinando sinais como nomes, extensões e heurísticas. Suas estatísticas excluem categorias como código vendorizado, gerado e documentação e podem ser ajustadas por atributos. Isso é útil para descobrir candidatos e reconhecer ruído, mas não demonstra execução nem autoria individual. [Linguist: funcionamento](https://github.com/github-linguist/linguist/blob/main/docs/how-linguist-works.md), [atributos e overrides](https://github.com/github-linguist/linguist/blob/main/docs/overrides.md).

**Aplicação proposta:** usar extensão e distribuição como descoberta inicial; confirmar linguagem nos arquivos relevantes, separar código próprio/terceiros/gerado e registrar a finalidade. Percentual de bytes não deve ser interpretado como percentual de esforço ou experiência de uma pessoa.

### 2.2 Manifests e locks documentam dependências, não comprovam todas as formas de uso

O grafo de dependências do GitHub relaciona manifests e dependências; a capacidade de identificar relações diretas/transitivas depende do ecossistema e da fonte de detecção. Portanto, um inventário deve registrar como a informação foi obtida e quais relações permanecem inconclusivas. [Ecossistemas suportados](https://docs.github.com/en/code-security/reference/supply-chain-security/dependency-graph-supported-package-ecosystems), [exploração das dependências](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/explore-dependencies).

O npm distingue campos como dependências de desenvolvimento, opcionais e pares. O manifest de projeto do Unity registra dependências utilizadas pelo Package Manager. A interpretação deve respeitar o ecossistema, sem assumir que todos os manifests representam a mesma relação. [package.json](https://docs.npmjs.com/cli/v11/configuring-npm/package-json/), [manifest de projeto Unity](https://docs.unity3d.com/Manual/upm-manifestPrj.html).

**Aplicação proposta:** diferenciar versão declarada, resolução no lock, disponibilidade material e referências no código/configuração. Um lock não prova que uma instalação ou build ocorreu nesta cópia. O estado legado `installed` precisa explicitar seu critério; só declaração deve ser descrita como tal, sem inventar instalação.

### 2.3 Identidade, ocorrência e evidência podem ser registradas separadamente

CycloneDX modela identificação de componentes e evidências, incluindo métodos de identificação e locais de ocorrência. Package URL fornece uma identificação estruturada de pacotes por ecossistema. São referências úteis para evitar ambiguidade entre pacotes de mesmo nome. [CycloneDX: componentes](https://cyclonedx.org/use-cases/software-components/), [Package URL](https://github.com/package-url/purl-spec).

**Aplicação proposta:** aproveitar esses conceitos em tabelas Markdown. Não exigir emissão de SBOM, JSON, serviço externo ou conformidade com CycloneDX. Uma tag humana e um identificador de pacote têm funções diferentes: `package:npm-example-lib` pode apoiar o filtro, enquanto a identidade estruturada preserva ecossistema, namespace e versão.

### 2.4 Vocabulário controlado ajuda a consulta

SKOS distingue rótulos preferidos, alternativos e relações entre conceitos. Esses conceitos ajudam a normalizar sinônimos e hierarquias sem depender de uma única grafia. [W3C SKOS Reference](https://www.w3.org/TR/skos-reference/).

**Aplicação proposta:** manter chave canônica, rótulo humano, aliases e categoria. Não exigir RDF. `React` não é alias de `React Native`; `Java` não é alias de `JavaScript`; `MVC` e `MVVM` não se fundem; tecnologias relacionadas conservam identidade própria.

### 2.5 Padrões exigem interpretação estrutural

Tree-sitter permite consultas que correspondem a estruturas sintáticas. O catálogo de padrões da Microsoft descreve problema, aplicação e considerações de cada padrão. Um mecanismo de busca pode encontrar estruturas candidatas; a classificação exige examinar o comportamento e o contexto. [Consultas Tree-sitter](https://tree-sitter.github.io/tree-sitter/using-parsers/queries/1-syntax.html), [Cloud Design Patterns](https://learn.microsoft.com/en-us/azure/architecture/patterns/).

**Aplicação proposta:** nomes como `Factory`, `Repository` ou `Manager` apenas iniciam a investigação. O finding deve ligar participantes, relações e propósito. O catálogo de nuvem é uma referência para sua família de padrões, não um catálogo universal nem motivo para impor Azure ao projeto.

### 2.6 Instruções de agentes não comprovam execução de IA

Claude Code utiliza arquivos de instrução como `CLAUDE.md`; a documentação também descreve contextos em que `AGENTS.md` é lido. A documentação oficial do Codex descreve `AGENTS.md` como instruções de projeto. Copilot tem instruções de repositório como `.github/copilot-instructions.md`. [Claude Code: memória e instruções](https://code.claude.com/docs/en/memory), [OpenAI: AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md), [Copilot: instruções](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions).

**Aplicação proposta:** classificar artefatos de instrução/configuração como evidência de preparação ou configuração, não como prova de uso em uma tarefa. `AGENTS.md` é compartilhado por ferramentas e, sozinho, não identifica Codex. Suporte a arquivos muda com versões; nenhum nome de arquivo deve ser um detector universal e definitivo.

### 2.7 Créditos ultrapassam o autor de commit

Git mantém informações de autor e committer e oferece `.mailmap` para normalização de identidades. GitHub documenta coautoria por trailers e limita o gráfico de contribuidores aos 100 principais, sem contar merges e commits vazios. O gráfico não é inventário completo da equipe. [git-log](https://git-scm.com/docs/git-log), [gitmailmap](https://git-scm.com/docs/gitmailmap), [coautoria](https://docs.github.com/en/pull-requests/how-tos/commit-changes/creating-a-commit-with-multiple-authors), [gráfico de contribuidores](https://docs.github.com/en/repositories/viewing-activity-and-data-for-your-repository/viewing-a-projects-contributors).

CODEOWNERS registra responsabilidades de revisão por arquivos e pode incluir equipes. Isso não substitui evidência de implementação ou autoria. All Contributors reconhece contribuições além de código. CRediT oferece papéis de contribuição voltados a pesquisa, úteis como inspiração, com adaptação explícita ao domínio de software. [CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners), [All Contributors](https://allcontributors.org/en/), [CRediT](https://credit.niso.org/contributor-roles-defined/).

**Aplicação proposta:** combinar fontes e declarar limites. Não mapear automaticamente uma responsabilidade de revisão para liderança nem uma categoria de pesquisa para cargo profissional.

### 2.8 Codex e codecs são categorias diferentes

A expressão “codecs” na solicitação pode se referir ao agente Codex ou a codecs de áudio/vídeo. A proposta cobre ambos sem presumir equivalência. Codex entra em ferramentas de assistência por IA. Codecs entram em mídia e processamento.

FFprobe documenta inspeção separada de formato e streams. Isso ajuda a distinguir contêiner de mídia e codec. [Documentação FFprobe](https://ffmpeg.org/ffprobe.html).

**Aplicação proposta:** `.mp4` não basta para afirmar H.264; extensão de áudio não demonstra o codec usado na execução. Preferir metadados existentes e configurações de importação/exportação. Esta pesquisa não autoriza executar FFprobe ou qualquer binário do alvo; uma futura inspeção de mídia precisaria respeitar o método e as permissões locais.

## 3. Lacunas no framework atual

Leitura realizada em `spec.md`, `references/evidence-vocabulary.md`, `references/consolidation.md`, `references/forensic-a1.md` e referências de produção. O mapeamento abaixo registra a diferença entre cobertura conceitual existente e contrato a acrescentar.

| Área | Base existente | Complemento proposto |
|---|---|---|
| Stack e plataformas | FR-024, FR-033 a FR-036 | Vocabulário por faceta e registros de ocorrências para localizar uso. |
| Uso real | FR-034 e quatro estados de tecnologia | Critérios por tipo de fonte, estado por ocorrência e perfis de filtro. |
| Sistemas e arquitetura | FR-028, FR-029, FR-037 | Critérios de reconhecimento de padrões; evidência estrutural e alcance local/sistêmico. |
| Identidade e autoria | FR-025 a FR-027; A1 | Lista padronizada de pessoas, grupos, identidades pendentes e automações. |
| Créditos | B4, papel/equipe/contribuições | Fontes além de Git; papéis não técnicos; vínculo pessoa–contribuição–tecnologia. |
| IA | Regras genéricas sobre agentes e dados não confiáveis | Matriz específica de assistência, integração, técnicas, modelos e procedência. |
| Recuperação por agente | FR-023, FR-056, FR-063 | Chaves estáveis, aliases, relações e semântica de filtros sem perder qualificadores. |
| Portfólio | FR-081 e FR-082 | Resumo técnico consultável com acesso direto à prova, sem inflar competência. |
| Privacidade | FR-012, FR-071 e método local | Regras de nomes, contatos, prompts, endpoints e disponibilidade para divulgação. |
| Baseline/histórico | FR-064 e FR-066 | Revalidação de tags/ocorrências/pessoas; estado histórico e stale. |

Já existe uma área de papel, equipe e contribuições. A recomendação é completá-la com uma subseção estável de pessoas e créditos, evitando outra lista concorrente. Já existe classificação de tecnologias; a proposta a torna consultável e verificável, sem substituí-la por simples palavras-chave.

## 4. Modelo de tags

### 4.1 Facetas recomendadas

| Faceta | O que representa | Exemplos de chaves |
|---|---|---|
| `language` | Linguagem de programação, consulta ou shader | `language:csharp`, `language:typescript`, `language:sql`, `language:hlsl` |
| `engine` | Engine do produto | `engine:unity`, `engine:unreal-engine`, `engine:godot` |
| `framework` | Framework de aplicação ou de subsistema | `framework:react`, `framework:aspnet-core` |
| `package` | Pacote/biblioteca com identidade de ecossistema | `package:npm-react`, `package:nuget-example-library` |
| `platform` | Plataforma alvo configurada ou observada | `platform:web`, `platform:windows`, `platform:android` |
| `architecture` | Estilo estrutural demonstrado | `architecture:layered`, `architecture:event-driven`, `architecture:client-server` |
| `pattern` | Padrão de implementação em escopo definido | `pattern:observer`, `pattern:strategy`, `pattern:object-pool` |
| `practice` | Prática de engenharia com artefatos | `practice:unit-testing`, `practice:ci`, `practice:profiling` |
| `tool` | Ferramenta de build, editor ou operação | `tool:docker`, `tool:github-actions`, `tool:ffmpeg` |
| `service` | Serviço externo integrado/configurado | `service:example-storage` |
| `domain` | Área técnica sustentada por sistemas | `domain:gameplay`, `domain:audio`, `domain:backend`, `domain:accessibility` |
| `ai-tool` | Assistente/agente no processo de trabalho | `ai-tool:claude-code`, `ai-tool:codex`, `ai-tool:github-copilot` |
| `ai-provider` | Provedor de IA integrado ao produto | `ai-provider:openai`, `ai-provider:anthropic` |
| `ai-technique` | Técnica implementada, com escopo | `ai-technique:rag`, `ai-technique:embeddings`, `ai-technique:tool-calling` |
| `ai-model` | Identificador de modelo efetivamente documentado | `ai-model:example-model` |
| `codec` | Codec de áudio/vídeo identificado | `codec:h264`, `codec:opus` |
| `media-format` | Contêiner/formato identificado | `media-format:mp4`, `media-format:ogg` |

Os exemplos são possibilidades do vocabulário, não tecnologias detectadas neste projeto. Plataforma configurada não significa versão publicada. `domain:accessibility` não significa conformidade ou certificação. Relações entre facetas devem ser registradas: framework React pode ter implementação por pacote npm React, sem se tornar duas tecnologias independentes em contagens.

### 4.2 Normalização

- Chave em ASCII minúsculo, no formato `faceta:slug`, estável entre auditorias.
- Rótulo humano preserva grafia correta, por exemplo `C#`, `ASP.NET Core` e `GitHub Actions`.
- Aliases são termos de consulta, não novas tags. Siglas ambíguas exigem categoria ou contexto.
- Identidade de pacote inclui ecossistema, namespace/nome e versão quando conhecidos. PURL é opcional; não fabricar tipo de ecossistema ou versão para conseguir preenchê-lo.
- Versão é atributo da ocorrência, não parte obrigatória da tag. Faixa declarada, versão resolvida e versão observada são campos distintos.
- Famílias e filhos mantêm relações explícitas. Busca por família pode expandir filhos somente quando o consulente solicitar; expansão deve mostrar o conceito realmente observado.
- Pacote desconhecido mantém seu nome original e identidade disponível. Não descartar por falta de popularidade ou catálogo.
- Novas tags podem ser propostas durante auditoria com definição e fonte; equivalência incerta permanece pendente. Atualização do vocabulário do framework é uma ação separada da auditoria do alvo.
- Registrar versão do vocabulário e versão do contrato do relatório. Não alterar automaticamente o schema 2.0.0 atual somente pela existência desta pesquisa.

### 4.3 Tipos de registro e relações

IDs propostos: `T-###` para registros técnicos, `O-###` para ocorrências e `P-###` para pessoas/identidades. São propostas novas, a reconciliar com o data model na próxima especificação. Não renumerar `E-###`, `F-###`, `C-###` ou contribuições existentes.

| Registro | Campos mínimos propostos |
|---|---|
| Conceito/tag | Chave, faceta, rótulo, aliases, definição, relações, versão do vocabulário. |
| Tecnologia/padrão `T` | Tag(s), identidade, categoria, finalidade, relevância justificada, resumo atual, ocorrências. |
| Ocorrência `O` | `T`, repo/componente, baseline, caminho/símbolo ou localização equivalente, sistema, estado, natureza da conclusão, evidências, limites, contexto de uso, atualidade. |
| Pacote | Ecossistema, namespace/nome, origem, versões declarada/resolvida/observada, relação direta/transitiva/etc., registro técnico. |
| Pessoa/identidade `P` | Nome/alias permitido, tipo de identidade, fontes, resolução de identidade, papel formal se conhecido, contribuições, período observado, limites, divulgação. |
| Vínculo pessoal | `P`, contribuição existente, `O`/sistema/`T`, tipo de participação, estado de atribuição, evidências e wording permitido. |

Localização não deve depender exclusivamente de números de linha, que mudam. Associar caminho relativo, símbolo/objeto/configuração, baseline e evidência. Em Unity, uma ocorrência pode precisar de cena/prefab, GUID e componente serializado; em código gerado, identificar origem e o trecho de código próprio que o utiliza.

## 5. Eixos independentes e semântica de filtros

### 5.1 Estados de uso

| Estado existente | Critério recomendado | Interpretação permitida |
|---|---|---|
| `installed` | Dependência/pacote presente segundo critério explicitado; declaração e resolução discriminadas | Inventariado como dependência; uso funcional permanece não comprovado. |
| `possible_use` | Import, nome, referência incompleta, relato ou intenção sem ligação suficiente | Candidato à investigação; não entra em filtro de uso demonstrado. |
| `observed_use` | Código/configuração serializada demonstra papel concreto e ligação em sistema identificado | Uso observado estaticamente no escopo; execução não foi necessariamente observada. |
| `active_configuration` | Configuração efetiva selecionada no baseline, com vínculo ao componente aplicável | Configuração ativa no contexto declarado; deploy ou execução permanecem eixos separados. |

Os estados podem coexistir em ocorrências distintas. Não são uma escala universal: uma biblioteca pode ser usada num módulo e apenas declarada em outro; um pipeline pode estar configurado sem haver evidência de execução. O resumo deve ser derivado das ocorrências, mostrar conflitos e explicar o critério.

### 5.2 Outros eixos

| Eixo | Valores/regras propostos |
|---|---|
| Natureza | Reutilizar `fact`, `inference`, `personal_account`, `conflict`, `unresolved`. |
| Contexto | `runtime`, `editor`, `build`, `test`, `ci`, `documentation`, `sample`, `asset_pipeline`, `unknown`; múltiplos quando evidenciados. |
| Relação do pacote | `direct`, `transitive`, `peer`, `optional`, `bundled`, `vendored`, `unknown`, conforme ecossistema. Relação e contexto não se confundem. |
| Origem | Código próprio, terceiro, gerado, integração própria de terceiro ou desconhecido. |
| Temporalidade | Atual no baseline, histórico, removido do baseline ou desconhecido; janela observada separada de emprego. |
| Atualidade da prova | Revalidada, stale ou não verificada. Não transformar stale em ausência. |
| Exercício | Observado por fonte apropriada ou não verificado; separar uso estático de execução e release. |
| Cobertura | Reutilizar estados existentes; declarar diretórios, refs, material binário e fontes não examinados. |
| Confiança | Explicação baseada em evidências e limites; sem score arbitrário de domínio pessoal. |
| Atribuição | Reutilizar os estados existentes de contribuição; vínculo de tecnologia com pessoa exige prova própria. |
| Divulgação | Permitida, restrita ou desconhecida por dado/claim; existência no Git não libera automaticamente publicação. |

### 5.3 Perfis de busca

**Perfil padrão recomendado: uso demonstrado no projeto.** Retorna ocorrências atuais e não stale com `observed_use`, evidência recuperável e sem conflito não resolvido. Mostra o estado encontrado. Padrões podem ser inferências estruturais bem sustentadas, desde que apareçam como inferências, com participantes e limites.

**Perfil de configuração ativa.** Retorna `active_configuration` com prova de seleção/ligação efetiva no contexto. Pode ser combinado com o perfil anterior, mas o resultado conserva a distinção. Arquivo de instruções meramente presente permanece candidato/configuração declarada; não recebe este estado automaticamente.

**Perfil de experiência individual.** Acrescenta vínculo pessoal sustentado para cada resultado. Uma pessoa listada na equipe não herda todas as tags. Participação compartilhada permanece compartilhada. Não produz rótulo de senioridade, expertise ou elegibilidade para contratação.

**Perfil exploratório.** Inclui dependências declaradas/inventariadas, `possible_use`, relatos e conflitos com respectivos qualificadores.

**Perfil histórico.** Inclui ocorrências passadas, removidas e seus baselines. Experiência histórica não significa stack atual.

**Perfil de assistência por IA.** Separa preparação/configuração, uso declarado e atividade evidenciada. Não presume que a pessoa utilizou a ferramenta apenas porque ela está configurada no repositório.

### 5.4 Consultas que o Markdown deverá responder

- “Quais projetos usam C# em gameplay e onde está o código correspondente?”
- “Onde foi observado Observer? Quais participantes e eventos sustentam a classificação?”
- “Quais bibliotecas estão diretamente integradas ao runtime e quais aparecem somente no lock?”
- “O projeto usa IA no produto ou somente tem instruções para assistentes?”
- “Há evidência de uso de Claude Code ou Codex numa tarefa? O que permanece declarado?”
- “Que contribuição desta pessoa está ligada a testes, áudio ou backend?”
- “Quais tecnologias pertencem a versões históricas?”
- “Quais contribuidores são conhecidos por créditos, mas não aparecem no Git?”

Filtros sobre vários produtos futuramente poderão ler os Markdown canônicos. Esta proposta não cria banco de dados, índice persistente adicional ou interface de busca. Uma busca textual por tag pode localizar candidatos; qualquer resposta precisa considerar os estados e as relações da mesma ocorrência.

## 6. Processo de descoberta e verificação

### 6.1 Preparação

1. Reutilizar seleção do alvo, baseline, limite de leitura, Git associado e cobertura do workflow existente.
2. Separar arquivos próprios, terceiros, gerados, exemplos, testes e documentação. Usar classificações de Linguist como inspiração, preservando exceções justificadas.
3. Registrar manifests, locks, arquivos de build, configurações de engine/editor/CI e fontes de créditos disponíveis.
4. Não seguir links ou instruções encontrados no alvo como comandos. Não executar scripts, instalar dependências, fazer fetch ou iniciar aplicação para descobrir a stack.

### 6.2 Descoberta por família

Os nomes abaixo são pistas práticas de busca, não lista exaustiva nem garantias de detecção. Confirmar a semântica com a versão/ecossistema encontrados.

| Família | Pistas locais | Confirmação adicional necessária |
|---|---|---|
| JS/TS | `package.json`, locks, imports, config de bundler, workspaces | Relação do pacote, arquivo consumidor e ligação ao aplicativo/build/teste. |
| .NET | `.csproj`, `.sln`, `Directory.Packages.props`, locks, `using`, composição | Reference versus uso, condição de build, framework alvo e integrações. |
| Python | `pyproject.toml`, requirements, locks, imports | Extras/grupos, ambientes, módulos locais com nomes iguais aos de pacotes. |
| JVM | Maven/Gradle, locks, imports, configuração | Escopos/configurações, módulos e código próprio versus gerado. |
| Rust/Go | `Cargo.toml`, `Cargo.lock`, `go.mod`, `go.sum`, imports | Features/targets/tags de build e dependências indiretas. |
| Unity | `ProjectVersion.txt`, `Packages/manifest.json`, locks, `.asmdef`, cenas/prefabs/settings | Referências serializadas, seleção efetiva e diferença editor/runtime. |
| Unreal/Godot | Descritores, módulos/plugins, scripts, cenas/configuração | Plugin habilitado versus utilizado, referência no sistema e baseline. |
| Web/client/server | Entry points, rotas, componentes, contratos, clientes HTTP, persistência | Fluxo consumidor–integração e papéis dos componentes. |
| Infra/build/CI | Dockerfiles, compose, IaC, workflows e scripts | Configuração ativa versus template; resultado de execução somente por prova existente. |
| Mídia | Metadados, configs de import/export, scripts de pipeline lidos como texto | Contêiner, codec e pipeline separados; sem inferência por extensão isolada. |
| IA | Instruções/configs, manifests, adaptadores, prompts e registros já autorizados | Processo versus produto; execução/atividade e autoria verificados separadamente. |

### 6.3 Verificação de ocorrências

Para cada candidato relevante:

1. Identificar o que é: linguagem, produto, pacote, padrão, serviço, ferramenta ou técnica.
2. Recuperar fonte e baseline; criar ou reutilizar `E-###`.
3. Localizar consumo: import/chamada/registro/asset/configuração e conexão ao sistema. Import isolado, código morto ou exemplo não comprova papel ativo.
4. Descrever finalidade concreta: “validação de contratos na camada de API”, por exemplo, em vez de “biblioteca moderna”.
5. Classificar contexto, relação de dependência, origem, estado e temporalidade.
6. Registrar versão conhecida e desconhecimentos, condições de compilação, flags, plataformas e conflitos.
7. Associar atribuição pessoal somente após investigação própria de histórico/diffs/créditos.
8. Derivar tags e resumo de filtro das ocorrências, preservando candidatos num inventário qualificado.

### 6.4 Ferramentas: ordem recomendada

| Método | Vantagem | Limite | Decisão proposta |
|---|---|---|---|
| Leitura de manifests/locks e busca textual | Portável e compatível com análise estática | Falsos positivos; não resolve fluxo ou uso dinâmico | Base obrigatória do método. |
| Leitura estrutural por agente | Liga código, configuração e sistemas | Depende da cobertura e precisa de prova recuperável | Confirmação principal. |
| Linguist | Descoberta de linguagem e classificação de ruído | Estatística de arquivos não comprova uso/autoria | Referência conceitual ou ferramenta já aprovada. |
| Parser/consultas AST | Identifica imports, registros e relações sintáticas | Não resolve automaticamente comportamento nem toda reflexão | Aprofundamento opcional com ferramenta confiável já disponível. |
| SBOM existente | Identidade e relação de componentes | Pode estar desatualizado ou não demonstrar consumo | Fonte adicional com baseline e procedência. |
| Registros públicos/documentação oficial | Desambigua identidade, finalidade e aliases | Não prova uso no alvo; rede pode faltar | Enriquecimento opcional, sem enviar código/dados privados. |
| Build/instalação/runtime do alvo | Poderia revelar condições dinâmicas | Contraria o escopo estático atual | Não integrar ao caminho desta proposta. |

Nenhuma instalação de detector é requisito da auditoria. Se parser ou fonte online não estiver disponível, produzir cobertura parcial e limites. Um catálogo externo pode explicar uma biblioteca; somente fontes do projeto demonstram sua ocorrência.

## 7. Packages conhecidos e relevantes

O inventário amplo e a lista principal têm funções distintas. Preservar dependências descobertas com suas classificações, mas destacar no resumo as que ajudam a compreender trabalho técnico relevante.

**Critérios para destaque, com justificativa textual:**

- Papel direto num sistema central do produto.
- Integração própria demonstrada, incluindo adaptação, extensão ou composição.
- Decisão técnica com trade-off relevante para o brief ou público.
- Participação em build, testes, observabilidade, infraestrutura ou ferramentas de produção que explique uma contribuição.
- Uso em múltiplos componentes com relação documentada, sem duplicar contribuição.
- Capacidade específica relevante, mesmo que a biblioteca seja pouco conhecida.

**Conhecida não significa importante neste projeto.** Popularidade, estrelas, downloads e presença em vagas não comprovam utilização, qualidade, segurança ou competência. Enriquecimento público opcional pode fornecer descrição e identidade, com origem/data, mas não deve definir o estado de uso.

Detalhes a preservar: nome exato, ecossistema, origem registry/Git/local/vendorizada, faixa e resolução, relação com consumidor, contexto, baseline e evidência. Um fork/modificação local precisa apontar diferença de origem quando disponível. Pacote privado pode receber identificação reduzida autorizada; não pesquisar detalhes privados na web. Não extrair contatos ou URLs com credenciais para a tabela.

Evitar duplicações: React como framework e pacote deve compartilhar um registro ou relação explícita; uma dependência transitiva consumida diretamente pelo código pode ter relação `transitive` e uso `observed_use`; nenhum desses campos substitui o outro.

## 8. Padrões de software e arquitetura

### 8.1 Critério geral

Registrar nome canônico, problema resolvido quando evidenciado, participantes, relação estrutural, comportamento, escopo, código próprio/terceiro, evidências e contraevidências. Intenção declarada num README e estrutura observada podem divergir. Se não for possível confirmar o nome conhecido, descrever a estrutura em linguagem comum.

| Candidato | Evidência mínima recomendada | Falso positivo a evitar |
|---|---|---|
| Observer / Publish–Subscribe | Produtores, assinatura/registro, emissão, consumidores e escopo do mecanismo | Toda callback ou evento isolado virar arquitetura orientada a eventos. |
| Strategy | Contrato, implementações intercambiáveis e delegação/seleção no consumidor | Qualquer interface ou classe com nome Strategy. |
| Factory | Criação encapsulada e consumidores, com variação/decisão relevante | Método chamado Create sem papel estrutural. |
| Adapter | Tradução entre interfaces/contratos e fronteira que a consome | Wrapper de logging sem adaptação demonstrada. |
| Dependency Injection | Composição/registro, dependência fornecida ao consumidor e lifetime quando recuperável | Campo global, service locator ou pacote de DI não utilizado. |
| Object Pool | Aquisição, devolução/reutilização e ciclo de vida dos objetos | Cache/lista de objetos sem política de reutilização. |
| State Machine | Estados, transições, eventos/condições e controlador/consumidores | Enum de estados sem comportamento correspondente. |
| Repository | Fronteira de acesso a dados, abstração e consumidores | Diretório Repository ou repositório Git. |
| MVC / MVVM | Papéis de apresentação/estado/comportamento e relações efetivas | Nomes de pastas ou adoção nominal de framework. |
| CQRS | Caminhos de leitura e escrita separados no escopo declarado | Métodos Get/Set ou menção em planejamento. |
| Event-driven | Relações entre componentes por eventos no nível arquitetural definido | Evento local de UI usado como prova de arquitetura inteira. |
| ECS | Entidades, componentes e processamento por sistemas com relações demonstradas | Componentes comuns de engine confundidos com ECS. |

Esta tabela é recomendação de critérios do RepoDNA, não um classificador formal validado. Padrões não são selos de qualidade. Registrar variantes, combinações, implementações parciais e custos observáveis; não buscar uma quantidade mínima de padrões por projeto.

### 8.2 Wording e filtro

- Seguro: “estrutura compatível com Strategy em `Sistema-A`, sustentada por contrato, duas implementações e consumidor; inferência estrutural”.
- Seguro: “documentação declara CQRS; estrutura correspondente não verificada no escopo”.
- Inadequado: “o projeto usa Clean Architecture” a partir de três pastas.
- Inadequado: “a pessoa domina padrões de projeto” por constar numa equipe.

Padrão implementado por biblioteca de terceiros pode ser observado no projeto, mas não atribuído como implementação própria. Separar “utiliza”, “integra”, “estende” e “implementa”.

## 9. Uso de IA: modelo específico

### 9.1 Quatro dimensões

| Dimensão | Exemplos | Evidência necessária |
|---|---|---|
| Assistência ao desenvolvimento | Claude Code, Codex, Copilot e outros | Configuração, declaração atribuída ou registro de atividade ligada a tarefa/commit. |
| Integração de IA no produto | SDK/API, inferência local, serviço de modelo | Adaptador/cliente, chamadas/fluxo, configuração efetiva, finalidade no sistema. |
| Técnica | Embeddings, recuperação, RAG, tool calling, classificação | Componentes e fluxo específicos; nome da técnica em texto não basta. |
| Modelo/provedor | Identificador configurado, alias, endpoint compatível | Fonte exata, contexto e limites; modelo configurado não comprova modelo executado. |

NPC com máquina de estados ou pathfinding não deve ser automaticamente classificado como uso de LLM. Pode entrar como técnica de IA de jogo quando definido e sustentado, em categoria distinta.

### 9.2 Matriz de sinais

| Sinal | O que permite concluir | O que permanece desconhecido |
|---|---|---|
| `CLAUDE.md`, regras ou settings específicos | Instruções/configuração compatível com Claude Code | Uso real, versão, pessoa usuária e modelo executado. |
| `AGENTS.md` | Instruções para agentes compatíveis | Qual ferramenta executou trabalho e quem a utilizou. |
| Configuração específica de Codex | Preparação/configuração para a ferramenta no escopo | Atividade em tarefa e extensão da assistência. |
| Instruções Copilot | Preparação de instruções compatíveis | Execução e autoria de alterações. |
| SDK de IA no manifest | Dependência declarada/inventariada | Funcionalidade, chamadas, provedor efetivo e execução. |
| Cliente de SDK conectado a sistema | Integração observada estaticamente | Operação em produção, volume, custo e resultado medido. |
| Endpoint compatível com API de um provedor | Protocolo/cliente configurado | Identidade real do provedor atrás de proxy. |
| Modelo identificado em configuração | Identificador configurado naquele contexto | Versão resolvida de alias e modelo realmente usado. |
| Trailer/mensagem de commit mencionando assistente | Assistência declarada no commit | Autenticidade independente e quais linhas foram produzidas. |
| Registro autorizado de tarefa com ferramenta e patch correlacionado | Atividade evidenciada no escopo correlacionado | Autoria exclusiva e trabalho fora desse escopo. |
| Relato pessoal | Uso declarado pela pessoa, com contexto | Verificação independente. |
| Ausência de arquivos de agente | Sinal não observado na cobertura | Ausência de uso de IA em toda a vida do produto. |

### 9.3 Regras recomendadas

- Nenhum detector baseado em estilo, vocabulário, formatação ou “cara de código de IA” produz atribuição.
- Não estimar percentual humano/IA nem número de linhas geradas sem fonte apropriada e limites explícitos.
- Trailer é evidência de declaração; não é certificação da atividade. Assinatura de commit também não prova utilização de ferramenta ou autoria de cada trecho.
- Assistência não elimina responsabilidade humana nem transforma o assistente em pessoa da equipe.
- A própria execução desta auditoria com IA não prova que IA foi usada no desenvolvimento do alvo.
- Não vasculhar diretórios pessoais globais, histórico de chat ou contas externas para preencher lacunas. Usar somente fontes do escopo autorizado e dados fornecidos voluntariamente.
- Sintetizar conteúdo permitido; não copiar prompts, transcrições, dados enviados a modelos, tokens, endpoints privados ou credenciais.
- Para uso no produto, separar configuração, caminho estático, exercício e release. Técnicas como RAG precisam de cadeia de recuperação/contexto/geração observada, não apenas de pacote de vetores.
- Se a fonte não identifica modelo, versão ou pessoa, registrar desconhecido. Não deduzir modelo pelo nome comercial da ferramenta.

## 10. Pessoas, equipe, créditos e automações

### 10.1 Fontes e força de atribuição

| Fonte | Utilidade | Limite |
|---|---|---|
| Autor de commit + diff | Identidade registrada e alteração associada | Commit pode integrar trabalho de terceiros, squash ou importação. |
| Committer | Quem registrou/integralizou a alteração no histórico | Não necessariamente quem criou o trabalho. |
| Coautoria | Crédito declarado de participação compartilhada | Não distribui autoria por arquivo/linha automaticamente. |
| `.mailmap` local | Mapeamento explícito de aliases no projeto | Não valida identidade civil nem todas as fusões do arquivo. |
| Créditos, README, CONTRIBUTORS/AUTHORS | Equipe e papéis declarados | Pode estar incompleto ou desatualizado. |
| Registro All Contributors disponível | Tipos de contribuições declarados | Requer fonte e janela; não prova detalhes técnicos por si só. |
| CODEOWNERS | Responsabilidade configurada de revisão | Não demonstra implementação, cargo ou liderança. |
| Revisões/issues/PRs já disponíveis e autorizadas | Review, QA, desenho de solução e coordenação | Não devem ser requisitadas externamente sem escopo/autorização. |
| Assets e créditos de arte/áudio | Trabalho criativo e procedência | Criador de asset comprado não necessariamente integrou a equipe. |
| Relato fornecido pelo usuário | Contexto que Git não contém | Identificar como `personal_account`. |

### 10.2 Identidades

1. Usar ID local estável para cada identidade observada, sem publicar email como chave de consulta.
2. Reconciliar nomes/aliases somente por mapeamento explícito ou conjunto de evidências suficiente. Mesmo nome não basta; email compartilhado também não basta.
3. Conservar conflito e aliases pendentes com referência à fonte. Não reescrever `.mailmap` do alvo.
4. Identidade pode ser pessoa, grupo/equipe, bot, ferramenta de IA ou desconhecida. Grupo não deve ser expandido em pessoas sem fonte.
5. Nome ou pseudônimo permitido é suficiente. Perfis públicos são opcionais; contatos pessoais, emails e identidades civis desnecessárias ficam fora do texto publicável.
6. Registro local autorizado e publicação externa são decisões distintas. Quando divulgação for desconhecida, marcar restrição e usar identificador/alias reduzido na projeção pública.
7. Não transferir nomes, empresas, projetos privados ou casos pessoais para exemplos/metodologia versionados.

### 10.3 Contribuições além de código

Categorias iniciais recomendadas: programação, arquitetura/desenho técnico, integração, ferramentas/build, testes/QA, revisão, documentação, design de produto/UX, arte/animação, áudio/música, narrativa/conteúdo, acessibilidade/localização, release/operação, manutenção e coordenação explicitamente evidenciada.

Categorias são descrições de contribuição, não cargos formais. Empregador, título profissional, período de emprego e período observado no projeto continuam separados. Não inferir liderança de volume Git. Referências CRediT/All Contributors inspiram a cobertura; não impor uma taxonomia de pesquisa nem exigir conta GitHub para aparecer.

### 10.4 Completude e apresentação

A lista deve informar **“contribuidores identificados no escopo”**, fontes examinadas e lacunas. Só chamar de completa se houver suporte para essa conclusão. Datas indicam primeira/última observação no escopo, não início/fim exatos do trabalho. Históricos rasos, squash, importações, assets binários e falta de créditos precisam aparecer como limites.

Organizar por nome permitido ou ID estável; não por ranking de commits. Bots e assistentes ficam em subseção própria. Autores de assets de terceiros ficam em créditos/procedência; entram como equipe somente quando houver evidência desse vínculo. Contagens Git podem ser usadas para investigação em apêndice, sem ranking de mérito.

## 11. Estrutura proposta para o Markdown canônico

Inserir **Tags e índice de tecnologias** perto de `At a Glance`. Inserir **Tecnologias, padrões e uso de IA** junto de sistemas/arquitetura. Completar **Papel, equipe e contribuições** com **Pessoas e créditos** e **Automações e assistência**. Detalhes devem reutilizar evidências, findings e sistemas existentes.

### 11.1 Exemplo sintético de índice e registros

O exemplo abaixo demonstra o contrato proposto; nenhuma linha representa observação real deste repositório. Os estados devem permanecer junto das tags em consultas e cópias.

```markdown
## Tags e índice de tecnologias

Vocabulário: proposta 1.0 | Baseline: repo-exemplo@<commit>
Perfil padrão: uso demonstrado no projeto | Cobertura: partial

| Tag | Registro | Estado e contexto | Onde | Evidências |
|---|---|---|---|---|
| language:typescript | T-001 | observed_use / runtime | Sistema API, O-001 | E-001 |
| pattern:strategy | T-002 | observed_use / inference / runtime | Sistema de regras, O-002 | E-002, E-003 |

Assistência efetivamente usada: not_verified.
Candidatos fora do perfil padrão: ai-tool:claude-code, T-003, instruções presentes;
package:npm-example-library, T-004, somente declarada.
Tags pessoais: nenhuma herdada automaticamente da stack.

## Tecnologias, padrões e uso de IA

### T-001 — TypeScript

- Tag: language:typescript; aliases de busca: TS.
- Finalidade: implementação de validação de entrada da API.
- Ocorrências: O-001. Relevância: código próprio no caminho de entrada.
- Exercício/publicação: not_verified. Versão: unknown.

#### O-001 — Validação da API

- Repositório/baseline: repo-exemplo@<commit>.
- Localização: src/api/validate.ts; símbolo validateRequest.
- Sistema: API; estado: observed_use; natureza: fact; contexto: runtime.
- Evidência: E-001; limite: leitura estática, execução não observada.
- Atribuição: contribuição K-001, P-001; shared, segundo E-005.

### T-002 — Strategy

- Tag: pattern:strategy; escopo: Sistema de regras.
- Ocorrência: O-002; natureza: inference.
- Participantes: contrato Rule, duas implementações, consumidor RuleRunner.
- Evidências: E-002, E-003; limite: seleção em runtime não exercitada.
- Implementação própria/terceiros: própria segundo fontes do escopo.

### T-003 — Claude Code

- Tag: ai-tool:claude-code; dimensão: assistência ao desenvolvimento.
- O-003: CLAUDE.md; E-004; instruções de projeto presentes.
- Estado: possible_use; instruções presentes, carregamento efetivo not_verified.
- Uso em tarefa: not_verified. Uma fonte de seleção efetiva permitiria
  active_configuration sem, por si só, comprovar atividade em tarefa.
- Pessoa usuária/modelo/versão: unknown. Não comprova IA no produto.

### T-004 — Biblioteca Exemplo

- Tag: package:npm-example-library; ecossistema: npm.
- Versão declarada: faixa fictícia; resolvida: unknown; instalada: unknown.
- Relação: direct; contexto declarado: test; uso: possible_use.
- O-004: package.json; E-006; nenhuma ligação funcional confirmada.

## Papel, equipe e contribuições

### Pessoas e créditos

| ID | Identidade permitida | Contribuição | Sistema/tecnologia | Atribuição | Evidência | Período/limites |
|---|---|---|---|---|---|---|
| P-001 | Colaborador A | K-001, validação | API, O-001 | shared | E-005 | Janela observada; equipe completa unknown |
| P-002 | Colaborador B | K-002, documentação | Documentação | personal_account / unverified | E-007 | Relato; sem autoria Git correlacionada |

### Automações e assistência

| Identidade/ferramenta | Papel | Uso/configuração | Evidência | Limite |
|---|---|---|---|---|
| T-003, Claude Code | Instruções para assistência | Configuração presente; uso not_verified | E-004 | Não é pessoa; sem tarefa correlacionada |

Lista: partial; fontes: Git e créditos locais; aliases pendentes: Q-001.
Divulgação de nomes: unknown; projeção pública usa aliases reduzidos.
```

`K-###` acima é placeholder de ID de contribuição: a implementação deve reutilizar o identificador existente ou definir o contrato faltante na spec, não introduzi-lo silenciosamente. No exemplo, `personal_account` e `unverified` representam eixos separados.

### 11.2 Integridade

- Uma ocorrência não pode apontar para registro técnico, sistema, contribuição, pessoa ou evidência inexistente.
- Toda tag do índice precisa de registro detalhado; toda conclusão detalhada precisa de evidência ou lacuna explícita.
- Resumo, índice e corpo devem ser derivados dos mesmos registros e concordar em estado e baseline.
- Dados ausentes usam estados definidos; não preencher `unknown` com hipótese implícita.
- Guardar qualificadores junto das tags. Copiar somente palavras-chave para outra superfície pode perder contexto; a projeção deve conservar ao menos estado, escopo e rota de evidência.
- Colisões de IDs, aliases ambíguos, tecnologias renomeadas e forks devem ter resolução ou questão aberta.
- Informações históricas não ocupam a resposta atual sem marcação. Revalidar vínculos quando baseline ou atribuição mudar.

## 12. Atualização, migração e compatibilidade

1. Estender a feature existente e seu contrato, mantendo IDs e a saída única.
2. Ao atualizar relatório antigo, inserir as novas áreas no mesmo arquivo e registrar migração no histórico.
3. Não marcar tags, IA ou pessoas como avaliadas somente por migrar headings. Usar cobertura parcial/não verificada quando necessário.
4. Reaproveitar evidências anteriores válidas; revisar quando caminho, versão, configuração ou autoria tiver mudado.
5. Preservar ocorrência histórica de tecnologia removida; retirar do perfil atual de filtro.
6. Registrar mudanças de aliases e conceitos; não reutilizar chave antiga para significado diferente.
7. Uma auditoria não atualiza o framework nem cria catálogo persistente auxiliar por conta própria. Novos conceitos propostos ficam no relatório até aprovação/incorporação ao método local.
8. Pesquisa externa pode ser indisponível sem bloquear a descoberta local. Descrição/alias não enriquecido não torna a tecnologia ausente.

## 13. Critérios de aceitação sugeridos para a futura spec

Estes critérios são propostas para planejar implementação e validação futura. Não foram executados neste trabalho de pesquisa.

| Caso | Resultado esperado |
|---|---|
| Pacote somente no manifest | Declaração explícita; não afirmar instalação nem uso demonstrado. |
| Pacote somente no lock | Relação e resolução quando recuperáveis; não atribuir integração pessoal. |
| Dependência transitiva consumida diretamente | Uso observado e relação transitiva coexistem. |
| Código em exemplo/teste/terceiros | Contexto/origem preservados; não inflar runtime próprio. |
| Import sem consumidor ou com flag inativa | Candidato/limite registrado; não declarar atividade incondicional. |
| Pacote desconhecido/privado | Identidade disponível preservada, enriquecimento opcional e redigido quando necessário. |
| Mesmo framework e pacote correspondente | Relação explícita; sem contagem independente enganosa. |
| Nome Factory sem estrutura correspondente | Não classificar padrão apenas pelo nome. |
| Padrão estrutural demonstrado | Participantes, escopo, natureza da inferência e evidência recuperáveis. |
| Apenas AGENTS.md | Instruções para agentes; ferramenta específica e atividade desconhecidas. |
| Apenas CLAUDE.md/config específica | Configuração presente; uso e modelo não verificados. |
| SDK de IA sem fluxo consumidor | Dependência/configuração; funcionalidade de IA não comprovada. |
| Integração de IA com fluxo estático | Finalidade e ocorrência observadas; execução/release separados. |
| Trailer de assistência por IA | Declaração atribuída, sem score de linhas ou autoria exclusiva. |
| Nenhum sinal de IA | not_observed no escopo; não afirmar ausência universal. |
| Mídia MP4 sem stream metadata | Contêiner identificado; codec desconhecido. |
| Dois aliases com mapeamento suficiente | Identidade reconciliada com procedência. |
| Mesmo nome/email compartilhado sem confirmação | Identidades pendentes, sem fusão automática. |
| CODEOWNERS com equipe | Responsabilidade configurada; não gerar autores individuais. |
| Arte/áudio documentados fora do Git | Contribuição registrada com tipo e fonte; limites explícitos. |
| Bot e humano nos commits | Registros distintos; bot não ocupa lista de pessoas. |
| Squash/histórico raso/créditos incompletos | Lista partial; completude e cronologia limitadas. |
| Pessoa sem vínculo com determinada tecnologia | Tag do projeto não vira experiência pessoal. |
| Atualização remove pacote | Ocorrência histórica preservada e fora do perfil atual. |
| Relatório legado sem novas áreas | Migração no mesmo Markdown, cobertura não presumida. |
| Tags com nomes privados ou dados de prompts | Redação/controle de divulgação; método público sem casos pessoais. |
| Parser/rede indisponível | Método local continua; cobertura/limites informados. |
| Produto com vários repos | Ocorrências preservam repo/baseline; contribuição compartilhada não duplicada. |

Também recomendar consulta humana e por agente com perguntas da seção 5.4, avaliando recuperação da evidência e preservação dos qualificadores. A validação humana SC-025/T105 já adiada para o final deve manter sua posição; esta pesquisa não a antecipa nem a considera atendida.

## 14. Sequência recomendada de incorporação

1. **Specify:** complementar a spec existente com resultados esperados, histórias/cenários e requisitos de tags, ocorrências, IA e pessoas. Reutilizar os princípios atuais de evidência/privacidade/saída única.
2. **Clarify:** avaliar somente ambiguidades materiais sem decisão suficiente; usar as recomendações deste documento como defaults propostos.
3. **Plan:** definir modelo de registros/relações, vocabulário local, contrato Markdown e migração; selecionar pontos de extensão dos runbooks.
4. **Tasks:** dividir trabalho em vocabulário, descoberta por família, padrões, IA, créditos, consolidação, migração e validações autorizadas.
5. **Analyze:** conferir compatibilidade entre estados atuais e novos, filtro individual versus projeto, privacidade, IA e saída única. Levar decisões materiais ao usuário se não houver evidência/decisão suficiente.
6. **Implement:** atualizar método local e contrato conforme aprovado. Reauditar relatórios somente quando solicitado ou incluído no escopo de implementação.

Arquivos candidatos a extensão: `spec.md`, `plan.md`, `data-model.md`, `tasks.md`, contratos locais de consolidação/vocabulário, A1, B1/B2, B4 e fixtures sintéticas. Os nomes finais e necessidade de cada mudança pertencem ao planejamento. Não criar outra feature nem outro produto persistente de auditoria.

## 15. Prompt preparado para a próxima execução de speckit-specify

```text
Complemente a feature 001-readonly-audit-framework existente usando
specs/001-readonly-audit-framework/research-tags-and-contributors.md como
pesquisa de entrada. Não crie nova feature/branch e não substitua o método
atual por uma aplicação independente.

Objetivo: tornar o único Markdown de analysis-output/ consultável por
tecnologias, padrões de software, ferramentas/práticas, packages relevantes,
uso de IA, codecs/mídia e pessoas que contribuíram. Cada resposta deve dizer
o que foi observado, como e onde foi usado, em qual repo/sistema/baseline,
com quais evidências e limitações. A documentação deve atender tanto leitura
de portfólio/recrutamento quanto consulta de agentes, sem produzir rankings
de pessoas ou inferir competência individual da stack da equipe.

Incorpore:
1. Índice de tags com facetas, chaves estáveis, rótulos, aliases e versão do
   vocabulário; registros detalhados e ocorrências com vínculos recuperáveis.
2. Descoberta estática por manifests/locks, código, configurações, assets e
   histórico, separando declaração, disponibilidade, uso observado e
   configuração ativa. Reutilize os estados normativos existentes, explicite
   condições, versões, origem, contexto e relação direta/transitiva/etc.
3. Critérios estruturais para padrões e arquitetura, com participantes,
   finalidade, escopo e contraevidência. Nomes de classes/pastas não bastam.
4. Separação de IA como assistência ao desenvolvimento, integração no
   produto, técnicas e modelos/provedores. Instruções de agentes não provam
   atividade; AGENTS.md não identifica uma ferramenta exclusiva; declarações
   e registros correlacionados têm forças diferentes. Não inferir IA pelo
   estilo do código nem calcular percentuais humano/IA sem prova apropriada.
5. Distinção de Codex e codecs de mídia; contêiner/extensão não prova codec.
6. Lista de pessoas e créditos dentro de papel/equipe/contribuições, com
   identidades/aliases, fontes, contribuição e sistemas/tecnologias ligados,
   janela observada, completude e divulgação. Incluir trabalho além de
   código; separar autor, committer, coautoria, CODEOWNERS, bots, assistentes
   e autores de assets de terceiros. Não fundir aliases sem evidência.
7. Perfis de consulta: uso demonstrado no projeto, configuração ativa,
   experiência individual sustentada, inventário exploratório, histórico
   e assistência por IA.
   Qualificadores devem acompanhar os resultados; nunca herdar todas as
   tags do projeto para uma pessoa da equipe.
8. Integração com IDs de evidência/findings/sistemas/contribuições existentes,
   sem segunda fonte de verdade, saída auxiliar persistente ou dependência
   de rede, Notion, catálogo externo, parser instalado ou runtime do alvo.
9. Migração no mesmo Markdown, preservação de IDs/histórico e revalidação
   de ocorrências/tags/vínculos stale. Dados ausentes não viram aprovação.
10. Privacidade: método público genérico; nomes/empresas/projetos particulares
    não entram nos exemplos do framework. Contatos, credenciais, prompts e
    transcrições privadas não são copiados. Divulgação externa continua
    exigindo condição apropriada.

Mapeie a cobertura já existente, acrescente somente os requisitos faltantes
e derive cenários de aceitação dos casos da pesquisa. Marque as recomendações
como decisões de produto quando forem incorporadas, sem tratar fontes
externas como prova de uso no repositório alvo. Preserve a validação humana
T105/SC-025 para as validações finais, como já decidido.

Se surgir ambiguidade que materialmente altere o resultado e não tenha
decisão sustentada, registre a questão para clarify/analyze. Não implemente
nem reaudite o alvo durante specify.
```

## 16. Fontes e limites da pesquisa

Todas as fontes abaixo foram consultadas online em **2026-10-05**. São documentação oficial ou repositórios mantidos pelos respectivos projetos. Não há alegação de auditoria completa de todas as versões das ferramentas. Páginas podem mudar; copiar a metodologia para o framework não implica exigir consulta online em cada execução.

| Fonte | Uso neste estudo |
|---|---|
| [Linguist: how it works](https://github.com/github-linguist/linguist/blob/main/docs/how-linguist-works.md) | Descoberta de linguagens e limites de estatísticas. |
| [Linguist: overrides](https://github.com/github-linguist/linguist/blob/main/docs/overrides.md) | Separação de terceiros, gerado e documentação. |
| [GitHub: ecossistemas de dependências](https://docs.github.com/en/code-security/reference/supply-chain-security/dependency-graph-supported-package-ecosystems) | Manifests/locks e cobertura dependente do ecossistema. |
| [GitHub: explorar dependências](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/explore-dependencies) | Relações e origem do inventário. |
| [npm: package.json](https://docs.npmjs.com/cli/v11/configuring-npm/package-json/) | Categorias de dependências e contexto de declaração. |
| [Unity: project manifest](https://docs.unity3d.com/Manual/upm-manifestPrj.html) | Fonte de dependências do Package Manager. |
| [CycloneDX: componentes](https://cyclonedx.org/use-cases/software-components/) | Identidade, evidência e ocorrência. |
| [Package URL specification](https://github.com/package-url/purl-spec) | Identificação estruturada de pacote. |
| [W3C SKOS Reference](https://www.w3.org/TR/skos-reference/) | Rótulos/aliases e relações de conceitos. |
| [Tree-sitter: basic query syntax](https://tree-sitter.github.io/tree-sitter/using-parsers/queries/1-syntax.html) | Busca estrutural como ferramenta de candidatos. |
| [Microsoft: Cloud Design Patterns](https://learn.microsoft.com/en-us/azure/architecture/patterns/) | Problema/contexto e considerações de padrões. |
| [Claude Code: memory](https://code.claude.com/docs/en/memory) | Instruções de agentes versus atividade. |
| [OpenAI: AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) | Contexto/instruções de Codex. A URL anterior em developers.openai.com redirecionou para esta página oficial. |
| [GitHub Copilot: repository instructions](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions) | Artefatos de instrução específicos. |
| [FFprobe](https://ffmpeg.org/ffprobe.html) | Distinção entre formato e informações de streams. |
| [Git: log](https://git-scm.com/docs/git-log) | Histórico e campos de autoria/committer. |
| [Git: mailmap](https://git-scm.com/docs/gitmailmap) | Normalização explícita de identidades. |
| [GitHub: coautoria](https://docs.github.com/en/pull-requests/how-tos/commit-changes/creating-a-commit-with-multiple-authors) | Créditos declarados por trailers. |
| [GitHub: contributors](https://docs.github.com/en/repositories/viewing-activity-and-data-for-your-repository/viewing-a-projects-contributors) | Limites do gráfico de contribuidores. |
| [GitHub: CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners) | Responsabilidade de revisão versus autoria. |
| [All Contributors](https://allcontributors.org/en/) | Reconhecimento além de código; páginas específicas de specification não ficaram acessíveis na consulta, por isso não se afirma aderência ao contrato detalhado. |
| [NISO CRediT: role descriptors](https://credit.niso.org/contributor-roles-defined/) | Inspiração de cobertura de papéis, com adaptação explícita. |

**Limites:** não foi executado detector, parser, build, instalação, teste ou reauditoria de `target-repos/`. Não foram acessadas páginas pessoais do Notion nem dados reais de contribuidores para os exemplos. A lista de candidatos por ecossistema é uma proposta inicial extensível, não cobertura universal validada. A implementação futura deve demonstrar seus critérios com fixtures e casos autorizados; esta pesquisa não comprova que tecnologias, padrões ou assistência por IA estão presentes em qualquer alvo específico.
