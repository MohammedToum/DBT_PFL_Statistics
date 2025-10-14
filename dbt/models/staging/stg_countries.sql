{{ config(materialized='view') }}

-- Grain: one row per country_name_normalized
with src as (
    select
        -- map/rename to your source columns here
        lower(trim(country_name)) as country_name_raw,
        upper(trim(country_iso2)) as iso2_raw
    from {{ source('raw', 'raw_transfers') }}
),

country_lookup as (
    -- If your raw has many rows per country, dedupe and pick a canonical ISO2 when available
    select
        country_name_raw,
        any_value(iso2_raw) as iso2_raw
    from src
    where country_name_raw is not null and country_name_raw <> ''
    group by country_name_raw
),

normalized as (
    select
        initcap(country_name_raw) as country_name,
        case
            when iso2_raw ~ '^[A-Z]{2}$' then iso2_raw
            else null
        end as country_iso2
    from country_lookup
)

select
    {{ dbt_utils.generate_surrogate_key(['country_name', 'country_iso2']) }} as country_sk,
    country_name,
    country_iso2
from normalized
