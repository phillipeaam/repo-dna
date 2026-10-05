# Contrato: Entrada e única saída

## Entradas

- Repositório selecionado em target-repos/<repo-name>/; o usuário escolhe a cópia.
- Um produto pode abranger mais de um repositório. Relação e identidade são confirmadas antes de consolidar.
- Contexto de autoria, links e permissões é opcional e recebe origem/qualificação.
- Brief editorial, conjunto comparável de projetos e superfície/decisões visuais são entradas contextuais opcionais; nenhum serviço, Notion ou credencial é requisito.
- Para tecnologia, o agente pode ler manifests/locks, código, configurações, assets serializados, metadados locais e histórico Git já no escopo. Para pessoas, pode ler autoria/créditos locais e usar contexto fornecido voluntariamente. Ausência ou ambiguidade dessas fontes vira cobertura/atribuição limitada.
- Classificação de package e descrição/alias externos são enriquecimento opcional se já acessíveis e apropriados; conexão, registry, detector/parser instalado e envio de conteúdo do alvo não são pré-requisitos.
- Nenhum manifesto ou serviço externo é exigido na primeira versão.
- Instruções normativas são locais. Procedência privada de pesquisa é opcional e não é entrada obrigatória de auditoria; seguir o [contrato de privacidade e autoridade](privacy-local-authority.md).

## Saída

- Um arquivo Markdown persistente analysis-output/<safe-product-slug>.md por produto.
- O Markdown contém resumo, fatos atuais, análise dos domínios aplicáveis, claims/limites, evidências e índice, perguntas, cobertura, estado das etapas e verificação.
- Quando aplicável, o mesmo Markdown contém readiness editorial por projeto e, se explicitamente solicitada, avaliação da superfície de portfólio com escopo realmente observado e lacunas.
- O mesmo Markdown inclui índice/registro de tags técnicas e ocorrências vinculados a sistemas, repositórios/baselines e evidências, além de roster de contribuidores com cobertura e vínculo individual sustentado quando existente.
- Relatórios novos usam schema 2.1.0; atualizar um 2.0.0 migra o mesmo arquivo, preserva histórico/IDs válidos e registra categorias não migradas. A versão antiga permanece legível antes dessa atualização.
- Os registros no Markdown usam `T-###` (conceito técnico), `O-###` (ocorrência), `P-###` (identidade tipada) e `K-###` (contribuição). Cada vínculo referencia o escopo e as evidências locais; IDs antigos de evidência/finding/claim/questão não são renumerados.
- Fontes estáticas elegíveis incluem manifests/locks, código e símbolos, configuração/flags, assets ou metadata já legíveis, documentação como declaração, e histórico/créditos Git local. Distinção entre declarado/resolvido/instalado/observado/configurado e entre versão declarada/resolvida/exercitada permanece explícita.
- Perfis de consulta (uso observado atual, configuração ativa, exploratório, histórico, assistência IA ou experiência individual) são filtros identificados aplicados aos registros no próprio Markdown. Nenhum filtro cria persistência adicional nem usa popularidade externa como prova.
- Para migração, preservar o texto/histórico de origem relevante no documento, registrar baseline legada, schema e mapeamentos; ocorrências removidas continuam consultáveis como históricas e evidências não revalidadas ficam stale. A migração nunca declara cobertura só por criar headings.
- Nova execução do mesmo produto atualiza a mesma autoridade e mantém histórico identificável.
- Produto distinto usa arquivo distinto.
- Slugs são estáveis; colisão interrompe o fluxo para escolha explícita, sem sobrescrever outro arquivo.
- Não gerar HTML, JSON/CSV, ZIP, anexos por sistema, pastas de relatório, Notion exports ou publicação remota.
- Estado temporário pode existir, mas não se torna saída persistente e é removido ao concluir.

## Integridade

- Antes de escrever, confirmar identidade do produto e destino fora de todo alvo e de seus diretórios Git.
- Validar conteúdo Markdown integralmente antes da atualização do arquivo canônico.
- Sessão parcial/bloqueada declara causa no arquivo e não gera relatório de erro independente.
- Output existente não autoriza fundir produtos sem confirmação.
