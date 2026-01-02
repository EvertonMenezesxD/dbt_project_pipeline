{{ config(materialized='table') }} 

-- Parte 1: Definindo a CTE
WITH raw_data AS (
    -- Certifique-se que o nome da fonte é o mesmo do seu _sor__fontes.yml
    SELECT * FROM {{ source('main', 'raw_boston_311') }}
)

-- Parte 2: O SELECT final que estava faltando!
SELECT * FROM raw_data
