#!/usr/bin/env bash
# Controlled Markdown contract validation only; no target/live output readers.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python - "$ROOT_DIR" "$@" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1]).resolve()
fixture = root / 'tests/fixtures/readonly-audit/presentation-model/sample-product.md'
args = sys.argv[2:]
# Reject paths before touching their contents, including symlinks outside fixture.
if len(args) > 1 or (args and Path(args[0]).resolve() != fixture.resolve()):
    raise SystemExit('FAIL: only the exact controlled presentation fixture is allowed')
if fixture.is_symlink() or not fixture.resolve().is_relative_to(root/'tests/fixtures'):
    raise SystemExit('FAIL: fixture escapes the controlled framework boundary')

class Invalid(ValueError):
    pass

def require(condition, message):
    if not condition:
        raise Invalid(message)

def table(text, header):
    lines = text.splitlines()
    for i, line in enumerate(lines):
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if line.startswith('|') and cells == header:
            result = []
            for row in lines[i+2:]:
                if not row.startswith('|'):
                    break
                values = [c.strip() for c in row.strip().strip('|').split('|')]
                require(len(values) == len(header), 'malformed table row')
                result.append(dict(zip(header, values)))
            return result
    raise Invalid('missing table: '+str(header))

def ids(value, prefix):
    return set(re.findall(r'\b'+prefix+r'-\d{3}\b', value))

def validate(text, files):
    require(files == ['sample-product.md'], 'more than one canonical product output')
    require('Documento 2.1.0' in text and 'presentation_version: 1.0' in text,
            'missing compatible factual/editorial versions')
    for heading in ['## Projeção pública e claims', '### Seleção editorial',
                    '### Representações por canal', '## Evidências e índice',
                    '## Histórico de verificação']:
        require(heading in text, 'missing canonical section '+heading)
    evidence_rows = table(text, ['ID','Tipo/origem/localização','Baseline','Suporte e limite'])
    evidence = {r['ID']: r for r in evidence_rows}
    require(len(evidence) == len(evidence_rows), 'duplicate evidence IDs')
    claims_rows = table(text, ['Claim','Natureza','Estado','Evidências','Baseline','Limite obrigatório'])
    claims = {r['Claim']:r for r in claims_rows}
    require(len(claims) == len(claims_rows), 'duplicate claim IDs')
    for c in claims.values():
        refs = ids(c['Evidências'], 'E')
        if c['Estado'] not in {'unsupported','internal_only','rejected'}:
            require(bool(refs), 'claim has no evidence')
        require(refs <= evidence.keys(), 'unrecoverable claim evidence')
        require(c['Baseline'] != 'unknown', 'fixture factual baseline missing')
    channels = {r['Canal']:r for r in table(text,['Canal','Tipo','Essenciais','Capacidades','Fontes/data'])}
    require({r['Tipo'] for r in channels.values()} == {'real','fictitious'}, 'missing real/fictitious channels')
    for c in channels.values():
        require(c['Fontes/data'] and re.search(r'\d{4}-\d{2}-\d{2}', c['Fontes/data']), 'channel lacks source/date')
    selections = table(text,['Campo','Valor','Origem','Estado'])
    for field in ['Público','Finalidade','Idioma','Canal','Voz']:
        matches=[r for r in selections if r['Campo']==field]
        require(len(matches)==1 and matches[0]['Origem'] and matches[0]['Estado'] in {'confirmed','provisional','unknown'}, 'unqualified brief/voice')
    variants = {r['Variante']:r for r in table(text,['Variante','Seleção','Canal','Versão','Baseline','Decisão','Freshness','Referência humana','Elegível como aprovada'])}
    decisions = {r['Evento']:r for r in table(text,['Evento','Responsável/data','Escopo/motivo','Versão anterior','Freshness/decisão'])}
    for v in variants.values():
        require(v['Canal'] in channels, 'unknown variant channel')
        require(v['Decisão'] in {'draft','accepted','corrected','rejected'}, 'invalid decision')
        require(v['Freshness'] in {'current','stale'}, 'invalid freshness')
        if v['Decisão'] == 'accepted':
            require(v['Referência humana'] not in {'unknown','none',''}, 'acceptance lacks human decision')
            require(v['Referência humana'] in decisions, 'acceptance reference not recoverable in history')
            decision = decisions[v['Referência humana']]
            require('aceitou' in decision['Escopo/motivo'] and decision['Freshness/decisão'].startswith('accepted/'),
                    'referenced history is not an explicit acceptance')
        eligible = v['Decisão']=='accepted' and v['Freshness']=='current'
        require((v['Elegível como aprovada']=='yes') == eligible, 'invalid current approval')
    public = dict(re.findall(r'<!-- public:([\w-]+):start -->\n(.*?)\n<!-- public:\1:end -->',text,re.S))
    require(len(public)==2, 'missing or duplicate public variants')
    route_rows = table(text,['Variante','Trecho/campo','Claim','Evidências','Baseline','Relação','Limite público'])
    selected = {}
    for name, body in public.items():
        require(name in variants, 'public variant not declared')
        require(not re.search(r'\b[CEFQPKTORH]-\d{3}\b|[A-Z]:[\\/]|TODO|SECRET|private-context|target-repos',body), 'internal/private work markers in public text')
        require('sozinho' not in body and 'liderei' not in body and 'compus' not in body,
                'unsupported individual promotion')
        require('funções completas' in body and 'compartilhado' in body,'lost shared attribution qualifier')
        routes = [r for r in route_rows if r['Variante']==name]
        require(bool(routes), 'public text lacks claim routes')
        selected[name] = set()
        for row in routes:
            require(row['Claim'] in claims, 'route points to unknown claim')
            claim = claims[row['Claim']]
            require(claim['Estado'] in {'safe','qualified'}, 'unsupported claim selected')
            refs = ids(row['Evidências'],'E')
            require(bool(refs) and refs <= evidence.keys(), 'broken route evidence')
            require(refs <= ids(claim['Evidências'],'E'), 'route evidence differs from claim support')
            require(row['Baseline']==claim['Baseline']==variants[name]['Baseline'],'stale route/claim baseline')
            require(all(evidence[e]['Baseline']==row['Baseline'] for e in refs),'stale evidence reference')
            require(row['Relação'] in {'supports','limits','context_only','contradicts'}, 'untyped route')
            require(bool(row['Limite público']) and row['Limite público'] in body, 'essential public caveat lost')
            selected[name].add(row['Claim'])
        require(body.strip().startswith('Farol de Papel') and len(body.strip().split('\n\n'))>=2,
                'fictional essential name/summary missing')
    require(len({frozenset(v) for v in selected.values()})==1,'channel variants contradict factual selection')
    for r in route_rows:
        require(r['Variante'] in public, 'route references absent public variant')
    media = table(text,['Item','Origem/era/claim','Seleção','Link','Embed','Cópia','Crop','Rehosting','Áudio','Ação'])
    require(bool(media), 'missing per-action permissions')
    for m in media:
        unknown = any(m[action]=='permission_unknown' for action in ['Link','Embed','Cópia','Crop','Rehosting','Áudio'])
        require(not unknown or 'blocked' in m['Ação'], 'unknown permission treated as allowed')
    readiness = {r['Dimensão']:r for r in table(text,['Dimensão','Estado','Motivo/próxima ação'])}
    allowed={'complete','complete_with_conditions','incomplete_blocking','incomplete_nonblocking','optional'}
    require(all(r['Estado'] in allowed for r in readiness.values()), 'invalid readiness')
    require(readiness['Mídia']['Estado']=='incomplete_blocking' and readiness['Texto']['Estado']=='complete_with_conditions',
            'media blocking incorrectly propagated to safe text')
    require('itch-v1 texto:' in text and 'invalida aprovação' in text,'lost history/invalidation')

text = fixture.read_text(encoding='utf-8')
files = sorted(p.name for p in fixture.parent.glob('sample-product*') if p.is_file())
validate(text, files)

mutations = {
    'broken evidence': lambda t: t.replace('| E-001 | primary,','| E-099 | primary,'),
    'claim no source': lambda t: t.replace('| C-002 | fact | qualified | E-001 |','| C-002 | fact | qualified | none |'),
    'stale route': lambda t: t.replace('| itch-v2 | navegação por sinais | C-002 | E-001 | synthetic-b2 |','| itch-v2 | navegação por sinais | C-002 | E-001 | synthetic-b1 |'),
    'unsupported selection': lambda t: t.replace('| itch-v2 | nome e projeto fictício | C-001 |','| itch-v2 | nome e projeto fictício | C-006 |'),
    'lost caveat': lambda t: t.replace('a execução não foi verificada e o resultado não foi medido.','o resultado não foi medido.',1),
    'private ID': lambda t: t.replace('Siga a luz','E-001 Siga a luz',1),
    'false solo': lambda t: t.replace('Siga a luz','Desenvolvi sozinho. Siga a luz',1),
    'missing essential': lambda t: t.replace('<!-- public:text-v2:start -->\nFarol de Papel','<!-- public:text-v2:start -->\n',1),
    'acceptance without decision': lambda t: t.replace('| draft | current | unknown | no |','| accepted | current | unknown | yes |',1),
    'unrecoverable human decision': lambda t: t.replace('| accepted | stale | decision-synthetic-1 | no |','| accepted | stale | decision-missing | no |'),
    'stale approved': lambda t: t.replace('| accepted | stale | decision-synthetic-1 | no |','| accepted | stale | decision-synthetic-1 | yes |'),
    'unknown media allowed': lambda t: t.replace('blocked: nenhuma cópia/download/reuso','allowed: copiar'),
    'missing voice source': lambda t: t.replace('| autor fictício E-004 | confirmed |','| | confirmed |'),
    'contradictory selection': lambda t: t.replace('| text-v2 | resultado | C-004 | E-003 | synthetic-b2 | limits | resultado não foi medido |\n',''),
}
for name, mutate in mutations.items():
    candidate = mutate(text)
    require(candidate != text, 'mutation not applied: '+name)
    try:
        validate(candidate,files)
    except Invalid:
        pass
    else:
        raise SystemExit('FAIL: negative mutation was accepted: '+name)
try:
    validate(text, ['sample-product.md','sample-product-itch.md'])
except Invalid:
    pass
else:
    raise SystemExit('FAIL: second output accepted')

# Normative method is the product: verify scope gates and integration explicitly.
runbook=root/'.agents/skills/repodna-audit/references/presentation-format.md'
channel=root/'.agents/skills/repodna-itch-format/references/channel-itch.md'
method=runbook.read_text(encoding='utf-8')
for term in ['Propósito','Gate de fonte','Fonte secundária','unknown','unavailable',
             'provisional','P→K→O/T→E','personal_account','not_measured','campo/representação',
             'rascunhos','stale','accepted','decisão humana','corrected','permission_unknown',
             'texto simples','fictício','claim','não','Mídia','Falhas','concluir']:
    require(term.casefold() in method.casefold(),'missing runbook rule: '+term)
template = root/'.agents/skills/repodna-audit/references/presentation-template.md'
neutral = template.read_text(encoding='utf-8')
for term in ['Finalidade', 'Origem dos dados', 'Quando usar', 'Quando omitir', 'Cuidados',
             'Esqueleto preenchível', 'Acesso nativo', 'Controles', 'Mecânicas', 'Contexto',
             'Créditos', 'Links', 'Mídia', 'sem CSS', 'Notas subjetivas']:
    require(term.casefold() in neutral.casefold(), 'missing neutral model responsibility: '+term)
require('presentation-template.md' in method and 'derivados privados' in method,
        'neutral model/application not integrated')
require('conferir informações únicas antes de remover' in method,
        'redundant copy removal lacks preservation gate')
profile=channel.read_text(encoding='utf-8')
for url in ['https://itch.io/docs/creators/design','https://itch.io/docs/creators/quality-guidelines','https://itch.io/docs/creators/css-guide']:
    require(url in profile,'missing official source')
require('2026-10-07' in profile and 'unknown' in profile,'undated/unqualified channel profile')
for name in ['SKILL.md','references/workflow.md','references/consolidation.md','references/publication-b4.md']:
    require('presentation-format.md' in (root/'.agents/skills/repodna-audit'/name).read_text(encoding='utf-8'), 'missing skill integration: '+name)
print(f'PASS: single-source routes, two channels, voice, attribution, caveats, recoverable decisions, freshness and per-action media gates; {len(mutations)+1} negative mutations rejected.')
PY
