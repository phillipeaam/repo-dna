# Migração de escopo: feature 002, revisão 2

**Data**: 2026-10-06 | **Identidade**: número, pasta e branch 002 preservados.

## Decisão

Substituir manutenção de perfil/catálogo pessoal e redesign de página específica por modelo de apresentação de dados já auditados, reutilizável por público/canal. A auditoria estática/autoridade factual continuam na feature 001.

Na migração de material importado, registrar origem, baseline e limites conhecidos ou desconhecidos. Evidências secundárias e registros históricos não são promovidos a fatos atuais dos produtos.

## Preservação e triagem individual

Inventário de migração, quando existente, permanece privado e registra path original, hash, classificação e decisão. Sua localização pertence ao contexto do operador, não ao método público. Ausência de acervo particular não impede usar a feature.

Preservar informações únicas antes da retirada de material fora de escopo; manter trabalho não relacionado e histórico Git. A conferência de preservação das migrações anteriores foi registrada como resultado operacional, sem distribuição dos originais. Não foi repetida nesta revisão documental. Regras de conteúdo proporcional, evidência, créditos, fallback e estados foram generalizadas; dados específicos continuam privados.

## Correspondência de requisitos

IDs antigos referem-se ao snapshot da revisão 1; IDs novos referem-se à spec revisão 2. O mesmo número textual não significa a mesma obrigação. As faixas abaixo cobrem os 40 FR e 17 SC antigos, sem herdar sua aceitação.

| Requisitos antigos | Decisão / motivo | Correspondência na revisão 2 |
|---|---|---|
| FR-001–005 | Perfil, links/curadoria pessoais fora de escopo; aprendizado de contexto/autoria generalizado | FR-004–008; sem catálogo/destaques obrigatórios |
| FR-006–008 | Retirar execução de build; conservar apenas resultados externos qualificados | FR-009/018/019 |
| FR-009–010 | Retirar aviso de projeto específico e inventário fixo; conservar lacunas/limites úteis | FR-005/009/026 |
| FR-011–013 | Incorporar fonte factual, conteúdo proporcional e público | FR-001–008/014 |
| FR-014 | Retirar piloto fixo; selecionar audit original antes de piloto real | FR-025/026 |
| FR-015–016 | Generalizar claims seguras, créditos e metadados sustentados | FR-003/008–011/014/015 |
| FR-017–020 | Retirar design/viewport/convite específicos; conservar capacidades do canal, relevância e alternativa simples | FR-005/006/010–013; sem certificação/renderização real |
| FR-021–022 | Substituir pacote por representação no canônico; preservar revisão/histórico independente | FR-002/016–018 |
| FR-023–024 | Aplicação/restauração de site fora do audit; não registrar revisão publicada por inferência | FR-018/019 |
| FR-025–028 | Generalizar método para produtos novos; retirar fila/catálogo/entrega pessoal | FR-005–008/020–026 |
| FR-029–030 | Retirar composição/identidade obrigatórias de uma página particular | FR-006/007/010 |
| FR-031–035 | Incorporar UI nativa, mídia pertinente, idioma parametrizado e claims honestas | FR-004/005/009–015 |
| FR-036 | Textura e arte entregues não pertencem ao modelo editorial | Retirado; FR-021 exclui pipeline de assets/preview |
| FR-037–040 | Generalizar fallback, revisão e identidade livre; retirar pacote CSS/HTML/restauração/sincronização | FR-006/012/016–024 |
| SC-001–004 | Métricas de inventário/perfil/destaque/piloto específico retiradas | SC-001–004/010 + fonte real como dependência |
| SC-005–008 | Qualidade, revisão e reuso generalizados; aplicação/fila pessoal retiradas | SC-001–005/009/010 |
| SC-009–011 | Métricas de aplicação/visitantes/viewport particular fora de escopo | SC-007; sem alegar validação humana/visual que não ocorreu |
| SC-012–017 | Design/texura/visitantes específicos retirados; estados/fidelidade/fallback aproveitados | SC-002/004–007 |

## Correspondência de tarefas

| Tarefas antigas | Tratamento atual |
|---|---|
| T001–T047 | Fundação, perfil, inventário, confiança, piloto, manutenção e acabamento do acervo pessoal: histórico preservado, fora do backlog ativo |
| T048–T050 | Convergência do perfil/exercícios: histórico, não aceitação do método novo |
| T051–T070 | Revisão particular, aplicação/reversão e design do piloto: retirar especificidade; aprendizados de estados/limites referenciados nos novos contratos |
| T071–T073 | Convergência de acesso/responsividade/acompanhamento: histórico, sem transportar checks [X] |

Novo backlog começa em **T074** para impedir ambiguidade histórica. Na revisão documental de 2026-10-06, todas as tarefas novas ficaram abertas; a preservação/limpeza daquela sessão não foi apresentada como implementação. A execução de 2026-10-07 é registrada em tasks/plan, sem herdar conclusões [X] da revisão 1.

## Compatibilidade e limites

Factual schema 2.1.0, IDs e significados permanecem. Extensão editorial 1.0 é opcional e implementada; sua ausência não significa avaliação negativa. Não migrar fichas particulares automaticamente para autoridade factual. As revisões 3 e 4 abaixo registram regras de armazenamento e divisão de responsabilidades, sem fixar projeto ou exemplo real obrigatório.

Preparação documental não publica, executa projetos ou prova permissões. Não houve commit de migração. Resultados históricos de preservação são observações limitadas ao recorte então registrado.

## Revisão 3 — fonte única e aplicação, 2026-10-07

FR-002/021/025 e SC-007 passam a manter o audit existente no caminho escolhido pelo usuário, sem importação obrigatória. A emenda constitucional 4.0.0 autoriza derivados privados de aplicação, sem relatório adicional. FR-027–030 / SC-011–012 / US5 registram consolidação, modelo neutro e versão validada. T074–105 permanecem histórico da implementação anterior; seu destino importado foi superado por esta revisão, não certificado como decisão vigente. Não ampliar investigação factual, publicação nem testes da página.

## Revisão 4 — separação das entradas

Canal itch.io move de `.agents/skills/repodna-audit/references/channel-itch.md` para `.agents/skills/repodna-itch-format/references/channel-itch.md`. Todas as referências ativas mudam; T084 e demais tarefas antigas mantêm caminho como histórico. Método/modelo genéricos não são copiados. T112–117 e FR-031–035/SC-013–014 acrescentam skill invocável e contextos de entrada; não repetir aplicação sobre exemplos reais. Governança 4.1.0 permite a nova organização, sem mudar fatos ou autoridade.

## Revisão 5 — neutralização da documentação

FR-036–038/SC-015 e T118–121 generalizam contexto de importação, aplicações e escolhas particulares. IDs de requisitos/tarefas e mapas das revisões anteriores são mantidos; resultados de checks e limites de revisão continuam explícitos. Nenhum dado privado é movido para o framework nem reescrito. Nomes de ferramentas/fontes, caminhos da feature e exemplos fictícios continuam legítimos, com finalidade declarada. Branch/pasta existentes não são renomeados nesta revisão.
