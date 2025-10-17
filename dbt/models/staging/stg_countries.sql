{{ config(materialized='view') }}

with countries as (
    select distinct country as country_name
    from {{ ref('stg_club_country_map') }}
    where country is not null and trim(country) <> ''
)

select
    {{ dbt_utils.generate_surrogate_key(['country_name']) }} as country_id,
    country_name
from countries
