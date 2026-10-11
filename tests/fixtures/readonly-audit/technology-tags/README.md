# Fixture sintética: tecnologias, padrões, IA, codecs e migração

Todos os nomes e caminhos deste documento são fictícios. A matriz descreve apenas o que o contrato deve registrar; não representa alvo real, runtime executado ou benchmark.

| Caso | Fonte sintética | Estado/contexto esperado | Limite/assertiva proibida |
|---|---|---|---|
| `declared-only` | Manifest declara `sample-ui` 4.x sem lock nem consumidor | `declared`, versão resolvida/instalada desconhecida; contexto exploratório | Não dizer instalado, integrado ou usado |
| `resolved-not-available` | Lock resolve `sample-core` 1.2.0 mas árvore do pacote não está no escopo | `resolved`; disponibilidade `unknown` | Não dizer instalado ou exercitado |
| `transitive-consumer` | Lock indica dependência transitiva; fonte própria importa seu símbolo | Registrar relação `transitive`, consumidor/localização e `observed_use` estático no contexto observado | Não reclassificar como dependência direta ou runtime exercitado |
| `test-editor-example` | Pacote aparece somente em teste, extensão do editor ou sample | Cada ocorrência mantém contexto `test`, `editor` ou `sample` | Não misturar no perfil padrão de runtime |
| `version-conflict` | Manifest e lock têm versões diferentes ou lock ausente | Preservar as duas fontes e conflito/unknown | Não escolher versão por popularidade |
| `alias-unambiguous` | `sample-js` é alias explícito de `sample-javascript` | Ambos resolvem à chave canônica `language:sample-javascript` | Não criar dois conceitos por sinônimo |
| `alias-ambiguous` | `sample-kit` pode nomear dois conceitos distintos | Manter candidatos separados e `unresolved` | Não fundir por semelhança textual |
| `conditional-feature` | Consumer protegido por flag opcional | Registrar possível uso/configuração e o estado da flag por ocorrência | Não afirmar configuração ativa sem seleção sustentada |
| `stale-reference` | Evidência aponta a arquivo removido de baseline anterior | Manter ocorrência histórica e marcar finding atual como `stale` | Não incluir como uso atual sem revalidação |
| `pattern-false-positive` | Classe chama-se `Factory`, sem criação encapsulada/participantes | Registrar nome como pista ou descrever estrutura observada | Não afirmar Factory por nome |
| `pattern-partial` | Relações parecidas com Strategy em um subsistema, com evidência de participantes | Registrar natureza/inferência, participantes, escopo local, baseline e limite | Não generalizar padrão ao produto inteiro |
| `pattern-third-party` | Biblioteca contém padrão internamente | Origem third-party e integração ficam tipadas | Não atribuir implementação à equipe do alvo |
| `ai-instructions-only` | `AGENTS.md` contém orientação para agente | Sinal de instrução/configuração; atividade `unknown` | Não inferir ferramenta/tarefa/percentual de código |
| `ai-sdk-no-consumer` | Manifest declara SDK fictício sem caminho consumidor | Dependência declarada; integração do produto não demonstrada | Não afirmar feature funcional de IA |
| `ai-integration-static` | Código conecta uma chamada a um sistema e configura modelo em fonte estática | Integrar finalidade, consumidor, configuração e fonte; execução/provider efetivo continua desconhecido | Não inferir chamada executada |
| `ai-assisted-declared` | Commit sintético declara assistência | `personal_account`/declaração atribuída com fonte | Não inferir autoria exclusiva ou fração gerada |
| `no-ai-signal` | Nenhum sinal acessível | `not_observed` dentro do escopo | Não concluir que IA nunca foi usada |
| `codec-extension-only` | Arquivo `.mp4`, sem metadata de stream | Formato/contêiner demonstrado; codec `unknown` | Extensão não comprova codec |
| `codec-metadata` | Metadata estática fornecida identifica codec fictício | Contêiner e codec em campos distintos ligados à fonte/baseline | Não executar ffprobe ou media player |

## Consultas esperadas

- Perfil padrão “uso demonstrado” retorna apenas ocorrências `observed_use` atuais/revalidadas, não stale, com sistema, repo/baseline, localização, contexto e evidência.
- Perfil exploratório inclui declarações/candidatos com qualificador; configuração ativa, histórico e IA são consultas separadas.
- Cada linha de índice aponta a `T-###` e uma ou mais `O-###`; cada ocorrência termina em fonte `E-###` recuperável.

## Migração sintética 2.0.0 → 2.1.0

Documento legado fictício `legacy-2.0.0`: preservar IDs `E-001`, `F-001`, `C-001`, `Q-001`, significados, baseline legada e histórico. Ao atualizar, registrar schema anterior/novo, versão do vocabulário, mapeamentos e seções novas ainda não avaliadas. Ocorrência removida permanece histórica; fonte cujo baseline mudou fica stale. A migração atualiza o mesmo Markdown e nunca declara cobertura por criar headings. Rede, parser e catálogo externo indisponíveis não impedem consultas offline com dados locais nem geram artefato adicional.
