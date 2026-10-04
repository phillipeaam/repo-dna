# B3 — Release e procedência de artefatos

## Propósito

Reconstruir o que pode ser ligado entre evento de release, fonte, commit/ref, artefato/versionamento e destino público. Cada relação tem seu próprio suporte e confiança; proximidade temporal não fecha um elo.

## Procedimento

1. Registrar evento/deadline e timezone como contexto, sem presumir que determinam snapshot.
2. Inventariar refs, tags, manifests/lockfiles, metadados de build assinados, checksums, releases e arquivos públicos acessíveis sem login ou autorização não concedida.
3. Relacionar candidato de source snapshot com binário por hash, build metadata, reproducibilidade documentada ou outro vínculo direto. Marcar tentativa razoável de recuperação e seu resultado.
4. Separar artefato histórico original recuperado de rebuild posterior, HEAD atual e versão pública atual; diferenças de capability ficam claras.
5. Para dependência compartilhada, ligar alteração do pacote → versão distribuída → produto consumidor → release; adoção pelo consumidor exige evidência em cada elo.

## Estados por relação

Use `exact`, `strongly_supported`, `bounded_range` ou `unresolved` e explique o porquê. Tag/data sem binário correlacionado não prova conteúdo distribuído. LFS ausente, artefato removido e fonte inacessível geram gap, não certeza inventada.

## Saída

Timeline de evento/snapshot/artefato/destino com `E-###`, confiança e limitações por elo; findings e questões de recuperação. Não consolidar releases de repositórios ou produtos distintos automaticamente.
