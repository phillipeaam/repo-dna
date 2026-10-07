# Workflow e fronteira de leitura

## Objetivo e entradas

Este é o fluxo normativo chamado pela skill principal. Entradas: repositório(s) selecionados explicitamente sob `target-repos/`, identidade/contexto declarado pelo usuário, perfil de host observado (se conhecido) e destino local `analysis-output/<safe-product-slug>.md`. Nunca inferir que dois projetos são um só por organização, nome ou dependência.

## Gate 0 — perfil e caminhos reais (antes da inspeção substantiva)

1. Identificar o sistema operacional e o runtime/shell do agente. Registrar o perfil na matriz quando houver evidência; `unverified` significa que a proteção do host não foi comprovada, não que o método precise bloquear.
2. Resolver caminho absoluto e canônico do alvo; resolver symlinks/junctions sem seguir para fora do escopo escolhido. Identificar submódulos e todos os metadados Git reais: arquivo `.git` de worktree, gitdir, common dir e object store externo. Não inicializar submódulos.
3. Comparar os caminhos do alvo/Git com as raízes graváveis conhecidas pelo host. Se houver interseção ou a política não for conhecida, avisar que o agente pode gravar no alvo por acidente; isso não bloqueia o método.
4. Verificar colisão de slug e identidade antes de escolher destino em `analysis-output/`. A saída deve ficar fora do alvo e do Git. Se o diretório não existir, criá-lo no checkout do framework; nunca dentro do alvo.
5. Não tente escrever no alvo real para provar proteção. A matriz de fixtures documenta evidência de host, mas é opcional para iniciar uma auditoria; sem prova, registrar preservação como `not_verified` até a comparação final.
6. Bloquear somente se o alvo for ambíguo, seu escopo real não puder ser resolvido com segurança, ou a saída conflitar com o alvo/outro produto. Não ler conteúdo substantivo até o usuário escolher claramente o alvo.

## Gate 1 — baseline reproduzível

Após passar Gate 0, registrar timestamp, identidade/caminhos, papel de cada repo, remote quando disponível, branch/HEAD, refs incluídas/excluídas, versão do método, perfil do host e escopo real. Distinguir:

- tracked staged/unstaged;
- untracked;
- ignored dentro do escopo de inventário;
- submódulos e Git externo selecionados;
- arquivos inacessíveis, binários, LFS ausente, limite de tamanho e ferramenta indisponível.

Não normalizar nem corrigir o estado. Construir snapshot de conteúdo/inventário só após o gate; usar memória ou scratch externo descartável, nunca arquivo no alvo. `GIT_OPTIONAL_LOCKS=0` deve ser aplicado a comandos de leitura Git quando disponível; evitar comandos que atualizem índice, cache ou refs. Cobertura não examinada fica `partial`, com motivo. Baseline de conteúdo e status Git são registradas separadamente.

## Gate 2 — sequência e aplicabilidade

| Fase | Entrada e foco | Saída/checkpoint |
|---|---|---|
| Preparação | Identidade, produto/repos, baseline, escopo | Perfil e enforcement informados, inventário e limitações |
| A1 Forense | Git, timeline, identidade e contribuições | Findings e atribuição qualificada |
| B1 Produção | Sistemas, arquitetura, config, conteúdo, ferramentas | Mapa estrutural/tecnológico |
| B2 Runtime | Inspeção estática e medições pré-existentes | Riscos estáticos, medidas com procedência ou plano futuro |
| B3 Procedência | refs, eventos, artefatos, versões e destinos | Elo por elo, estado e confiança |
| B4 Publicação | texto, mídia, créditos, claims e permissões | Readiness por ação e bloqueios |
| Reconstrução (US14) | Após A1 e fontes técnicas pertinentes, se solicitada/aplicável | Claims rastreáveis, alternativas, confiança e lacunas no Markdown |
| Reconciliação | Contexto externo autorizado e fontes antigas | Classificação, conflitos e motivo |
| Consolidação | Evidências e respostas por assunto | Um Markdown canônico |
| Revisão | Cobertura, links, segurança, preservação | `complete`, `partial` ou `blocked` |

Registrar para cada domínio `complete`, `partial`, `not_observed`, `not_applicable`, `unavailable` ou `not_verified`, escopo e justificativa. Etapas podem ser combinadas se todos os resultados obrigatórios continuarem explícitos.

## Falha, concorrência e retomada

- Falha de fonte/ferramenta/contexto: não converter em ausência; registrar estado parcial/bloqueado, ação necessária e checkpoint.
- Mudança concorrente: interromper novas conclusões, recapturar apenas após confirmar permissão e consentimento operacional; findings afetados ficam stale. Não atribuir a mudança automaticamente à auditoria.
- Retomada: confirmar identidade, política e baseline atuais, comparar com snapshot anterior e versão do método. Se qualquer base mudou, revalidar findings dependentes antes de reutilizar.
- Não registrar dados transitórios como autoridade separada. O Markdown canônico conserva os checkpoints necessários à retomada.

## Gate final de preservação

Após leitura, comparar conteúdo/inventário coberto e estado Git com a baseline, incluindo tracked, ignored e untracked dentro do escopo declarado. Não executar comandos de reparo. Concorrência ou cobertura incompleta impede declarar preservação observada integralmente. Sem enforcement preventivo comprovado, mesmo uma comparação sem diferenças registra apenas `observed_unchanged` no escopo verificado, não uma garantia de que o host impediu toda escrita.

## Limites de proteção do host

O método pede que o agente não escreva nem execute nada do alvo, mas não exige que o operador configure sandbox, ACL ou mount readonly antes de começar. Quando a sessão pode gravar no alvo — inclusive se `target-repos/` estiver dentro do checkout — mostrar o aviso de risco antes da leitura e marcar a proteção como não verificada. `analysis-output/` deve ficar fora do alvo e do Git associado.

No Codex, se as permissões tornam o checkout gravável, ainda é permitido analisar uma cópia em `target-repos/` após o aviso. Use leitores estáticos e evite comandos capazes de atualizar Git, caches ou arquivos. A prova de fixture continua útil para elevar confiança futura, mas sua ausência não bloqueia. Se o usuário não aceitar o risco de sessão gravável, ele pode preparar um alvo protegido por meios próprios; isso é opcional nesta fase.

## Mapeamento resumido de requisitos para fases

- FR-001–012: preparação, fronteira, baseline e privacidade.
- FR-013–021: orquestração, aplicabilidade, checkpoints e genericidade.
- FR-022–032: A1 e consolidação de findings por sistema.
- FR-033–041: B1/B2 e distinção de evidência/runtime.
- FR-042–046: B3 e procedência por elo.
- FR-047–054: B4, claims e readiness.
- FR-055–058, FR-062–064, FR-067–068: contrato canônico, reconciliação, histórias e revisão final.
- FR-059–061: reconciliação e relação multi-repo.
- FR-065–066: migração e atualização após mudança de baseline.
- FR-114–125 e SC-038–047: reconstrução evidencial opcional ligada a A1, fontes pertinentes e consolidação; limitações e confiança ficam explícitas.
- FR-069–070: orientação de uso e inventário de capacidades legadas.

Cada requisito é fechado pela correspondência de tarefas em `specs/001-readonly-audit-framework/tasks.md`; esta lista orienta a fase e não substitui aquela matriz.

## Reconstrução de engenharia (US14)

Quando o usuário solicitar reconstrução histórica/técnica ou ela for parte do objetivo editorial, executar o runbook engineering-reconstruction.md depois de A1 e das fontes B1/B2/B3 pertinentes, antes da consolidação. Reutilizar as contribuições e tecnologias já identificadas; não inferir a experiência de uma pessoa a partir da stack do projeto.

A etapa é opcional e pode resultar em not_applicable, partial ou unavailable com motivo. Limitar fontes a conteúdo local, fornecido ou público sem autenticação. Fonte privada inacessível fica unavailable/not_observed; não adiciona conexão de serviço, credencial, publicação nem etapa dinâmica. Incluir no mesmo Markdown afirmações, relações às evidências, escopo, alternativas, justificativa de confiança, desconhecidos e estado editorial draft/review.
## Produtos com vários repositórios

Antes de combinar, registrar nome/slug do produto e, por repositório: ID, caminho canônico, papel (`client`, `service`, `package`, `tooling` ou outro explicado), remote/ref/HEAD, baseline e relação confirmada por quem ou por qual evidência. Relação desconhecida bloqueia fusão. Sucessor ou produto parecido conserva slug/registro separado.

Para pacote/feature compartilhado, atribuir ID estável de contribuição no registro do produto e ligar evidências: mudança no repositório de origem → versão/tag publicada → referência/lock do consumidor → release/destino do consumidor. Manter os findings fonte em cada repo/baseline; consolidar a mesma contribuição uma vez por produto, listando cada consumidor como relação/evidência e sem recontar como contribuição nova. Tecnologia desconhecida mantém o núcleo genérico e marca especializações `not_applicable`/`not_observed` com motivo.

## Autoridade e cobertura do método local

As instruções normativas estão neste checkout. A constituição/spec governam os
requisitos; skill, runbooks e contratos locais aprovados governam a execução.
Para cada etapa, carregar as seções correspondentes do
[método incorporado](../../../../specs/001-readonly-audit-framework/methodology.md)
e consultar o [mapa local](../../../../specs/001-readonly-audit-framework/source-inventory.md).
A procedência original da pesquisa é opcional e privada. Nenhuma fonte externa
é exigida para recuperar regras; contexto externo de um alvo é evidência opcional
e não redefine o método. A ausência de rede não substitui nem relaxa o gate do host.

## Extensão de portfólio (US10/US11)

Entradas opcionais: brief editorial, inventário explicitamente comparável, referência visual aprovada e superfície selecionada. Por campo, registrar origem e estado confirmed/provisional/historical/conflicting; ausências ficam unknown. Separar contexto do produto do papel editorial (Featured candidate, Strong supporting, Supporting/Technical, Archive/Playground ou unclassified) e marcar decisão humana versus recomendação do agente. Sem conjunto comparável, avaliar somente aderência individual; nunca emitir ranking global. Archive e Supporting não são excluídos automaticamente.

A prontidão editorial inclui quick scan com produto/contexto, papel/equipe/período, plataforma/tecnologias, contribuições, aderência, estado público e ressalva, com caminho às provas detalhadas. Histórias usam contexto, ownership, problema, restrições, abordagem, trade-offs, evidência, resultado e reflexão apenas quando sustentados. Claims, media, recomendações profissionais, responsabilidades e permissões preservam fonte, estado e limites. A avaliação editorial permanece no único Markdown.

#A prontidão editorial ocorre depois de B4 e antes da reconciliação/consolidação quando o objetivo de portfólio se aplica. A revisão de superfície ocorre depois dessa prontidão somente se o usuário incluir a superfície; suas lacunas não impedem a consolidação do conteúdo. Conflitos materiais de brief, papel ou decisão de design ficam em aberto e pedem posicionamento humano.

## Revisão condicional de superfície

Ativar somente quando o usuário selecionar explicitamente um site, protótipo ou material visual. Confirmar páginas/áreas e usar somente acesso público readonly. Não autenticar, submeter formulários, acionar contato/conversão, alterar estado, editar ou publicar. Registrar páginas, viewports e interações realmente observados. Cada dimensão do runbook tem evidência/localização e limites ou not_observed. Notas de 1 a 5 explicam o critério e são diagnóstico profissional, não pesquisa com usuários, benchmark ou certificação. Findings P0–P3 incluem impacto, recomendação, esforço, risco/dependência e confiança; registrar percurso, plano por fases e decisões humanas. Indisponibilidade não bloqueia análise de conteúdo/repositório.

## Extensão técnica e de contribuições (US12/US13)

Após B1 e A1, descubra candidatos por fontes locais estáticas e qualifique cada relação sem instalar ferramenta nem executar o alvo. A sequência de consulta é `tag faceta:slug → T-### → O-### → sistema/repo/baseline/localização → E-###`; o índice e as ocorrências ficam no mesmo Markdown. Alias aponta para conceito canônico somente quando inequívoco. Preserve eixos independentes de declaração, resolução, disponibilidade, uso observado, configuração, relação de dependência, versão, contexto, origem e atualidade. Consulta padrão de uso demonstrado retorna somente `observed_use` atual/revalidado, não stale; apresente outros resultados com perfil e qualificador explícitos.

Classifique estruturas como padrão apenas com comportamento, participantes, relações e escopo; registre `inference` ou descrição comum se faltar prova. IA exige distinguir sinais de assistência de desenvolvimento, integração do produto, técnica e provedor/modelo. Codec depende de metadata apropriada já legível e nunca é deduzido da extensão.

Reconcilie roster após as fontes A1/B4: crie `P-###`/`K-###`, mantenha pessoa/grupo/bot/ferramenta IA e papéis de author/committer/co-author/reviewer separados, declare fontes/janela/completude e inclua trabalho não codificado somente com evidência ou relato identificado. Não una aliases ambíguos nem herde stack. Vínculo de experiência individual precisa ligar P→K→O/T e citar evidência. Conflitos e gaps seguem como `unresolved`/`partial`.

Na retomada/migração, mantenha `T/O/P/K` e IDs legados válidos, atualize no mesmo Markdown para 2.1.0, anote schema/baseline/vocabulário e mapeamentos, preserve removidos como históricos e marque conclusões afetadas como stale até revalidar. Heading não verificado nunca significa domínio completo.

O inventário técnico e o roster entram na reconciliação/consolidação após B1/A1; devem compartilhar evidências sem substituir os registros genéricos. A seção de tags aponta para registros/ocorrências e o roster aponta para contribuições. A projeção de experiência individual usa somente vínculos explicitamente sustentados.

## Handoff editorial (feature 002)

Ao encerrar o audit, pode indicar a [skill repodna-itch-format](../../repodna-itch-format/SKILL.md) com o relatório gerado. Não iniciar composição/aplicação automaticamente sem pedido. Investigação e registro factual pertencem ao audit; composição itch.io pertence à skill editorial. O [método compartilhado](presentation-format.md) e o [modelo neutro](presentation-template.md) continuam referências internas únicas, não formulários obrigatórios para o usuário. Fonte única, rastreabilidade e privacidade permanecem no mesmo Markdown; nenhum alvo/site é alterado pelo handoff.
