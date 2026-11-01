{{ config(materialized='table') }}

-- depends_on: {{ source('main', 'raw_boston_311') }}
-- depends_on: {{ ref('sot_boston_311') }}
{% if execute %}
    {{ reconciliation_audit(model.config.meta) }}
{% else %}
    select
        cast(null as varchar) as reconciliation_name,
        cast(null as varchar) as issue_type,
        cast(null as varchar) as reconciliation_key,
        cast(null as bigint) as golden_source_count,
        cast(null as bigint) as consumption_count
    where false
{% endif %}
