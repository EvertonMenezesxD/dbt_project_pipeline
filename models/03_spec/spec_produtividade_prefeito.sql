{{ config(materialized='table') }}

WITH produtividade AS (
        SELECT
        bairro,
        COUNT(DISTINCT chamado_id) AS total_chamados
    FROM {{ ref('sot_boston_311') }}
    GROUP BY bairro
)
SELECT
    bairro,
    total_chamados
FROM produtividade