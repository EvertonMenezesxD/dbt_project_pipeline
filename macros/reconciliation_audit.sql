{% macro reconciliation_audit(meta) %}
    {% set contract = meta.get('reconciliation') %}

    {% if contract is none %}
        {{ exceptions.raise_compiler_error(
            "O modelo de auditoria deve declarar config.meta.reconciliation no YAML."
        ) }}
    {% endif %}

    {% set golden_source = source(
        contract['golden_source']['source_name'],
        contract['golden_source']['table_name']
    ) %}
    {% set consumption = ref(contract['consumption_model']) %}
    {% set golden_key = adapter.quote(contract['golden_key']) %}
    {% set consumption_key = adapter.quote(contract['consumption_key']) %}
    {% set reconciliation_name = dbt.string_literal(contract['name']) %}

    with golden_source_counts as (
        select
            cast({{ golden_key }} as varchar) as reconciliation_key,
            count(*) as row_count
        from {{ golden_source }}
        where {{ golden_key }} is not null
        group by 1
    ),

    consumption_counts as (
        select
            cast({{ consumption_key }} as varchar) as reconciliation_key,
            count(*) as row_count
        from {{ consumption }}
        where {{ consumption_key }} is not null
        group by 1
    ),

    key_count_differences as (
        select
            coalesce(golden.reconciliation_key, consumed.reconciliation_key) as reconciliation_key,
            coalesce(golden.row_count, 0) as golden_source_count,
            coalesce(consumed.row_count, 0) as consumption_count
        from golden_source_counts as golden
        full outer join consumption_counts as consumed
            on golden.reconciliation_key = consumed.reconciliation_key
        where coalesce(golden.row_count, 0) != coalesce(consumed.row_count, 0)
    )

    select
        {{ reconciliation_name }} as reconciliation_name,
        'key_count_mismatch' as issue_type,
        reconciliation_key,
        golden_source_count,
        consumption_count
    from key_count_differences

    union all

    select
        {{ reconciliation_name }} as reconciliation_name,
        'null_key_in_golden_source' as issue_type,
        cast(null as varchar) as reconciliation_key,
        count(*) as golden_source_count,
        0 as consumption_count
    from {{ golden_source }}
    where {{ golden_key }} is null
    having count(*) > 0

    union all

    select
        {{ reconciliation_name }} as reconciliation_name,
        'null_key_in_consumption' as issue_type,
        cast(null as varchar) as reconciliation_key,
        0 as golden_source_count,
        count(*) as consumption_count
    from {{ consumption }}
    where {{ consumption_key }} is null
    having count(*) > 0
{% endmacro %}

{% test reconciliation_has_no_differences(model) %}
    select *
    from {{ model }}
{% endtest %}
