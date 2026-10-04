# B1 — Produção, arquitetura e configuração

## Propósito e entrada

Descrever o que existe no snapshot selecionado, como sistemas se conectam e quais configurações/tooling podem afetar produção. Fazer inspeção estática com baseline readonly aprovada; nunca abrir/importar o alvo em IDE ou ferramenta que possa executar código.

## Núcleo genérico

Inventariar entrypoints, módulos, limites, dados/eventos/estado, UI/entrada, persistência, serviços, dependências, configuração ativa, compilação/build/release declarados, conteúdo/assets, QA/testes existentes e observabilidade. Separar existência do arquivo, configuração ativa, possibilidade de uso e uso observado. Declarar fontes/formatos não cobertos.

## Especialização condicional — jogos

Avaliar apenas se a stack e os arquivos sustentarem aplicabilidade:

- Engine/versão, pipeline/rendering, qualidade, player/time, resolução, input, timestep, layers/tags/collision matrix e target frame/VSync.
- Cenas, prefabs, referências serializadas, composição, assets/import settings, endereço/carregamento e organização runtime/editor.
- UI, áudio/mixers, animação/VFX, física/navegação, save/load e integração de serviços.
- Packages/plug-ins instalados versus código/configuração realmente referenciados; build profiles e plataforma configurada versus executada.

## Especialização condicional — apps e serviços

Mapear cliente/servidor, entrypoints, contratos, schemas/serialização, armazenamento, integrações externas, autenticação configurada, jobs/eventos, deployment/infra, flags e observabilidade. Segredos nunca entram no documento. Não inferir deploy ativo de arquivos IaC.

## Saída e checkpoint

Mapa de sistemas e dependências por repo/baseline, configuração efetiva com evidência, domínios não aplicáveis, achados `F-###`, limitações e perguntas. Não declarar comportamento runtime sem medição ou execução externa fornecida como evidência.
