# Especificação: reconciliação Golden Source x Consumo

## Contexto

O projeto já possui as camadas SOR, SOT e SPEC, mas ainda não tem um contrato
operacional para medir divergências entre uma Golden Source e um modelo de
consumo. Este recurso cria uma base reutilizável, com contratos configurados em
YAML do dbt e resultados auditáveis como modelos.

## Objetivo

Detectar e materializar divergências entre uma fonte de referência e um modelo
de consumo, permitindo que os testes dbt falhem quando o contrato não for
atendido.

## Decisões

- Cada modelo de auditoria declara seu contrato em `config.meta.reconciliation`
  no YAML do dbt.
- O SQL de cada auditoria declara com `depends_on` as dependências do grafo dbt,
  alinhadas às relações do contrato YAML.
- A primeira etapa compara a contagem de registros por chave, incluindo chaves
  presentes somente em um dos lados e diferenças de duplicidade.
- Chaves nulas em qualquer lado são divergências explícitas.
- O modelo de auditoria persiste somente as divergências. Zero linhas significa
  que a reconciliação passou.
- Um teste dbt genérico falha quando o modelo de auditoria contém qualquer
  divergência.
- O primeiro contrato usa `main.raw_boston_311` como Golden Source e
  `sot_boston_311` como consumo, comparando `case_enquiry_id` com `chamado_id`.

## Requisitos

1. A fonte, o modelo de consumo, o nome do contrato e as chaves devem ser
   configuráveis por YAML por modelo.
2. O resultado deve identificar o contrato, o tipo da divergência, a chave e a
   contagem em cada lado.
3. Uma chave ausente em um dos lados deve aparecer como divergência.
4. Contagens diferentes para a mesma chave devem aparecer como divergência,
   inclusive quando houver duplicidades.
5. Chaves nulas devem ser reportadas e não podem produzir um falso resultado de
   reconciliação bem-sucedida.
6. O teste dbt associado deve falhar se o modelo de auditoria retornar uma ou
   mais linhas.
7. As dependências dbt declaradas para o modelo de auditoria devem garantir que
   Golden Source e consumo sejam construídos antes da reconciliação.

## Fora do escopo desta etapa

- Comparação campo a campo e normalização de valores.
- Agregados de negócio, tolerâncias e limiares configuráveis.
- Ingestão automática da Golden Source ou do consumo.
- Alertas, dashboards e histórico de execuções.

## Critérios de aceitação

- O contrato Boston 311 é expresso no YAML, sem hard-code das relações ou
  nomes das chaves no macro.
- A auditoria retorna somente divergências e inclui os dois lados da contagem.
- O teste passa com auditoria vazia e falha quando houver qualquer divergência.
- `dbt build --select +audit_sot_boston_311_reconciliation` executa o modelo e
  seu teste junto das dependências.

## Próximas etapas

1. Comparar valores campo a campo para chaves conciliadas, com regras de
   normalização explicitamente configuradas.
2. Comparar agregados e totais com tolerâncias configuráveis.
3. Consolidar resultados e histórico de execuções para acompanhamento.
