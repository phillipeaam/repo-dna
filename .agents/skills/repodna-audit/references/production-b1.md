# B1 — Produção, arquitetura e configuração

## Propósito e entrada

Descrever o que existe no snapshot selecionado, como sistemas se conectam e quais configurações/tooling podem afetar produção. Fazer inspeção estática com baseline readonly aprovada; nunca abrir/importar o alvo em IDE ou ferramenta que possa executar código.

## Núcleo genérico

Inventariar entrypoints, módulos, limites, dados/eventos/estado, UI/entrada, persistência, serviços, dependências, configuração ativa, compilação/build/release declarados, conteúdo/assets, QA/testes existentes e observabilidade. Separar existência do arquivo, configuração ativa, possibilidade de uso e uso observado. Declarar fontes/formatos não cobertos.

## Especialização condicional — jogos

Avaliar apenas se a stack e os arquivos sustentarem aplicabilidade:

- Engine/versão, pipeline/rendering, qualidade, player/time, resolução, input, timestep, layers/tags/collision matrix e target frame/VSync.
- Cenas, prefabs, referências serializadas, composição, assets/import settings, endereço/carregamento e organização runtime/editor.
- UI, áudio/mixers, animação/VFX, física/navegação, save/load e integração de serviços.
- Packages/plug-ins instalados versus código/configuração realmente referenciados; build profiles e plataforma configurada versus executada.

## Especialização condicional — apps e serviços

Mapear cliente/servidor, entrypoints, contratos, schemas/serialização, armazenamento, integrações externas, autenticação configurada, jobs/eventos, deployment/infra, flags e observabilidade. Segredos nunca entram no documento. Não inferir deploy ativo de arquivos IaC.

## Saída e checkpoint

Mapa de sistemas e dependências por repo/baseline, configuração efetiva com evidência, domínios não aplicáveis, achados `F-###`, limitações e perguntas. Não declarar comportamento runtime sem medição ou execução externa fornecida como evidência.

## Inventário estático de tecnologias e tags (US12)

Para cada ocorrência potencial, procurar fontes locais disponíveis sem instalar ferramentas, acessar registry/rede ou executar o alvo: manifests e locks; imports/usos e consumidores; arquivos de configuração e flags; project/build metadata; fontes serializadas e metadados legíveis; instruções e documentação (como declaração, não atividade); histórico Git já acessível. Registrar `T-###` como conceito e `O-###` como uso/localização, usando o vocabulário local. Categorizar linguagens, engines, frameworks, packages, plataformas, serviços, ferramentas, práticas, domínios e estilos/padrões só quando aplicáveis.

Por package, preservar ecossistema, nome/namespace/origem, versão declarada e resolvida, relação no grafo (`direct`, `transitive`, `peer`, `optional`, `vendored`, `bundled`, `unknown`), contexto e consumidor. Ausência de lock/metadata ou conflito de versões fica explícita. Popularidade, downloads e vagas nunca determinam detecção, qualidade, relevância ou domínio.

Manter separados: declaração/resolução, disponibilidade material instalada (`installed`), possibilidade (`possible_use`), uso estático observado no fluxo (`observed_use`) e configuração efetiva selecionada (`active_configuration`). Uma ocorrência só é `observed_use` com referência recuperável ao consumidor, sistema/finalidade e localização; isso não prova exercício em runtime. Uso ativo exige configuração ligada ao contexto correto, não mera presença de opção/flag. Contexto `runtime`, `editor`, `build`, `test`, `ci`, `documentation`, `sample` e `asset_pipeline` não deve ser misturado. Origem distingue implementação própria, third-party, integração, gerado ou desconhecido.

Índice padrão de uso demonstrado filtra ocorrências atuais/revalidadas e não stale; consultas exploratórias mostram declarações/candidatos rotulados. Destaques selecionam função tecnicamente demonstrada e apontam para o inventário integral, sem duplicar registro.

Padrões só são nomeados se participantes, relações, comportamento e escopo forem demonstráveis; caso contrário descrever a estrutura observada ou marcar inferência/candidato. Distinguir estrutura própria de integração de terceiro.

Registrar em dimensões independentes: assistência de IA durante desenvolvimento (instrução/configuração, relato, declaração atribuída ou atividade correlacionada); IA integrada ao produto; técnica aplicada; provedor/modelo configurado ou observado. Arquivo de instruções não prova atividade de tarefa; SDK sem fluxo consumidor não prova integração funcional; estilo de código nunca detecta IA.

Mídia: registrar extensão, formato/contêiner, codec, metadata disponível e configuração de processamento em campos separados. Extensão não confirma codec. Usar apenas metadata/fontes estáticas já disponíveis; não invocar ffprobe, importador, editor, decoder ou qualquer binário/código do alvo.
