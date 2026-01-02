{{ config(materialized='table') }}

WITH base AS (
    SELECT * FROM {{ ref('sor_boston_311') }} -- Referenciando a SOR
)

SELECT
    CAST(case_enquiry_id AS STRING) AS chamado_id,
    CAST(open_dt AS TIMESTAMP) AS data_abertura,
    CAST(closed_dt AS TIMESTAMP) AS data_fechamento,
    UPPER(case_status) AS status_chamado,
    -- Se bairro for nulo, coloca 'Não Informado'
    COALESCE(neighborhood, 'Não Informado') AS bairro,
    -- REGEX: Substitui números no início do texto por '---'
    regexp_replace(location, '^[0-9]+', '***') AS endereco_mascarado
FROM base