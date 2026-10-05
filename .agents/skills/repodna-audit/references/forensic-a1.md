# A1 — Identidade, história e contribuição

## Propósito e entrada

Reconstruir identidade do produto, período, contexto, equipe e contribuições observáveis sem converter volume de atividade em autoria. Entradas: baseline aprovada, refs/escopo, fontes públicas autorizadas e contexto pessoal fornecido. Use [evidence-vocabulary.md](evidence-vocabulary.md).

## Procedimento

1. Identificar produto atual, aliases/nome antigo, sucessores, plataformas, stack observada e estado público. Deixar fatos ausentes como `unknown`.
2. Mapear refs acessíveis, datas author/committer, merges, squashes, bots, branches e tags; declarar limites de histórico raso ou indisponível.
3. Resolver identidades por configuração Git, aliases explicitamente confirmados e continuidade sustentada. Não fundir homônimos ou emails ambíguos sem confirmação.
4. Selecionar diffs representativos por sistema/feature, não só contagens. Distinguir criar, estender, manter, integrar, revisar e trabalho compartilhado.
5. Ligar contribuição ao sistema, repo, baseline/commit e evidência. Separar contribuição individual, compartilhada, terceiros e ownership desconhecido.
6. Construir timeline em dimensões distintas: vida do produto, contribuição pessoal, emprego, release e manutenção posterior.

## Limites de interpretação

- Commit count, churn, LOC, blame, centralidade e bus factor são pistas de investigação, nunca score, ranking, liderança ou prova de impacto/autoria exclusiva.
- Código sustenta comportamento/configuração no snapshot; não prova motivação, experiência vivida, adoção ou publicação.
- Demo não prova teste; arquivo/plano não prova implementação; commit não prova criação do asset.
- Relato pessoal fica `personal_account`, com origem; não se transforma em verificação independente.
- Releases com datas próximas não estabelecem binário ou commit publicado. Delegar cadeia de procedência a B3.

## Saída e checkpoint

Findings `F-###` ligados a `E-###`, matriz sistema/contribuição, timeline com intervalos e incertezas, aliases não resolvidos e perguntas `Q-###`. Estado `partial` quando identidade/histórico ou cobertura forem limitados. Não criar documento separado.

## Matriz de sistema/feature e contribuição

Para cada sistema/feature registre nome/ID, comportamento/limite, repo e baseline, dependências, evidência, estado `implemented`, `partial`, `prototype`, `planned_only` ou `not_found_in_scope`, papel/contribuição (`created`, `extended`, `maintained`, `integrated`, `shared`, third-party, unknown), autoria verificada/compartilhada/desconhecida e wording permitido. Uma intenção documentada sem código não sai de `planned_only`; ausência só vale para o escopo efetivamente examinado.

## Prontidão editorial e histórias de engenharia

Quando a projeção para portfólio fizer parte do escopo, registrar contexto do projeto separado do brief e papel editorial. A leitura rápida deve permitir localizar identidade/contexto e contribuição individual em até 60 segundos e linkar uma rota de evidência aprofundada de cerca de 5–10 minutos sem exigir todos os apêndices. Selecionar histórias pela força da evidência e relevância, não para preencher quantidade. Usar contexto → ownership → problema → restrições → abordagem → trade-offs → evidência → resultado → reflexão; lacunas ficam explícitas e relato pessoal é atribuído.

Para cargos, separar empregador/título formal/período de responsabilidades observadas ou relatadas. Recomendações mantêm texto exato, autor, fonte, contexto e permissão; não provam cargo, liderança, autoria ou impacto além do que declaram. Preservar lineage e identidade da contribuição entre produtos para evitar dupla contagem.

## Padrões estruturais e vínculo técnico (US12)

Uma ocorrência técnica usa `O-###` e liga `T-###` a repositório/baseline, localização recuperável, sistema/finalidade, contexto, origem, temporalidade e evidências. Para um padrão, registrar participantes, relações, comportamento que realiza o propósito, escopo e natureza (intenção declarada, estrutura observada, inferência, implementação própria ou integração de terceiro). Nome de classe, pasta, dependência ou README sem esse conjunto permanece pista; preferir descrição em linguagem comum quando a classificação conhecida não for sustentável. Relevância de um package destacado requer explicação do papel no sistema, consumidor e evidência; métricas de popularidade não são evidência.

## Roster de contribuidores e atribuição (US13)

Construir `P-###` para pessoa/grupo/bot/ferramenta IA como tipos distintos e `K-###` para cada contribuição identificável. Informar quais fontes entraram (autoria Git, coautoria, diffs representativos, créditos, revisão, relato consentido), janela de histórico, baseline/refs e cobertura. Chamar a lista de “contribuidores identificados no escopo”; declarar incompletude quando houver squash, histórico raso, ausência de Git ou fontes inacessíveis.

Manter author, committer, co-author, pessoa que integrou, grupo, bot/IA, CODEOWNERS/reviewer e criador de asset de terceiro em papéis diferentes. CODEOWNERS ou estatística não prova que a pessoa implementou; crédito de asset não é autoria do código; uma revisão não é implementação. Resolver aliases apenas com evidência de continuidade suficiente; homônimos/emails compartilhados ficam separados e como questão aberta.

Contribuição pode incluir código, arquitetura/design, arte, áudio, QA, revisão, documentação, acessibilidade/localização, build e operação. Trabalho sem commit é elegível quando existe fonte identificada; relato do usuário fica `personal_account`. Para consultar experiência, criar vínculo pessoa → contribuição → ocorrência/sistema/tecnologia com prova e limite. Sem vínculo, não projetar tags do produto para a pessoa. Não inferir emprego, cargo, duração, senioridade, liderança, exclusividade ou total da equipe pelo primeiro/último commit ou volume.

Nome civil, contato e alias destinado a publicação têm autorização/divulgação separada. Usar IDs no núcleo do registro sempre que nome público não for necessário; não copiar metadados pessoais para exemplos ou fixtures do framework.
