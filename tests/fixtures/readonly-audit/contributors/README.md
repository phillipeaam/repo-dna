# Fixture sintética: roster e vínculos de contribuição

Todos os dados são fictícios e não representam pessoa, empresa ou projeto real.

| Caso | Fonte sintética | Resultado esperado | Limite |
|---|---|---|---|
| `author-committer-coauthor` | Commit tem author, committer e co-author distintos | Preservar os papéis e evidências individualmente | Commiter/integrador não substitui autor |
| `ambiguous-alias` | Mesmo nome ou email compartilhado sem confirmação | Identidades separadas, conflito aberto e roster parcial | Não fundir por string |
| `confirmed-alias` | Duas identidades ligadas por confirmação explícita sintética | Um `P-###` com fontes e alias observado | Não divulgar alias sem autorização |
| `codeowners-only` | CODEOWNERS nomeia responsável; nenhum diff/revisão sustentada | Responsabilidade declarada | Não afirmar implementação, cargo ou liderança |
| `bot-and-ai` | Autor de commit é bot/ferramenta de IA | Tipo `bot`/`ai_tool`; registro distinto de pessoa | Não contar como pessoa ou autoria humana |
| `third-party-media` | Asset tem crédito fictício de terceiro | Proveniência/credit separado do roster de implementação | Crédito do asset não é autoria do código |
| `shared-contribution` | Duas pessoas participam de mudança de pacote consumida por outro sistema | Uma K compartilhada ligada às evidências de origem e consumo | Não contar a mesma contribuição duas vezes |
| `non-code-work` | Fonte sintética credita design, arte, áudio, QA, revisão ou documentação | Incluir tipo, fonte, estado `reported`/`shared` e limite | Relato não vira verificação independente |
| `shallow-history` | Snapshot tem poucos commits e fontes incompletas | “contribuidores identificados no escopo”, janela/fontes e `partial` | Nunca chamar lista de equipe total |
| `individual-tech-link` | P-001 tem K-001 ligado à O-001/T-001 e E-001 | Tecnologia aparece como experiência individual qualificada | Sem essa relação, não herdar stack do produto |
| `team-stack-no-person-link` | Pessoa aparece no roster, mas sem contribuição técnica | Pessoa permanece listada sem tag de experiência | Presença na equipe não prova domínio |

## Invariantes

- `P-###` distingue person/group/bot/ai_tool; `K-###` identifica trabalho e fontes.
- Experiência individual exige `P → K → O/T → E`, baseline e limites.
- Roster reporta fontes, janela e completude; identidades conflitantes não são reconciliadas automaticamente.
- Contribuição fora do Git é elegível somente quando a fonte está identificada; `personal_account` continua atribuída.
- Names, aliases, companies, contact data and source metadata in this versioned fixture are synthetic only.
