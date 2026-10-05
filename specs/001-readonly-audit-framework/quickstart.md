# Quickstart: Cenários de validação planejados

Esta página define cenários que a futura skill deve suportar. Eles não foram executados durante o planejamento.

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

**Estado de validação de SC-025 nesta implementação:** o roteiro e os casos sintéticos estão prontos, mas ainda não foi conduzida sessão cronometrada com leitor humano sem contexto. Portanto, a meta de 60 segundos/5–10 minutos está implementada como critério verificável, mas seu resultado empírico permanece pendente.

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
