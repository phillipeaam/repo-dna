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
