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
- FR-069–070: orientação de uso e inventário de capacidades legadas.

Cada requisito é fechado pela correspondência de tarefas em `specs/001-readonly-audit-framework/tasks.md`; esta lista orienta a fase e não substitui aquela matriz.

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
