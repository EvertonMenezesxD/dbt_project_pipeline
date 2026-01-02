# 🏛️ Projeto dbt Boston 311 (Data Mesh Architecture)

Este projeto transforma e organiza dados públicos de chamados de serviço (311) da cidade de Boston utilizando **dbt** e **DuckDB**.

## 🏗️ Arquitetura do Projeto
O projeto segue o conceito de camadas para garantir governança e qualidade:
- **01_SOR (Source of Record):** Espelhamento dos dados brutos com tipagem básica.
- **02_SOT (Source of Truth):** Limpeza, tratamento de nulos e mascaramento de dados sensíveis (PII).
- **03_SPEC (Specialized):** Tabelas agregadas para suporte à decisão (ex: Produtividade por Bairro).

## 🛠️ Tecnologias Utilizadas
- **dbt-core**: Transformação e linhagem.
- **DuckDB**: Engine de processamento local de alta performance.
- **YAML**: Documentação e Testes de Qualidade.

## 🚀 Como rodar o projeto
1. Clone o repositório.
2. Certifique-se de ter o `dbt-duckdb` instalado.
3. Execute as transformações:
   ```bash
   dbt run