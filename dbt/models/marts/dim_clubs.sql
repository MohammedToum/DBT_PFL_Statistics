{{ config(materialized='table') }}

with clubs as (
    select
        club_key,
        min(club_involved_name) as club_name,
        any_value(country) as country
    from {{ ref('stg_club_country_map') }}
    group by club_key
)

select
    {{ dbt_utils.generate_surrogate_key(['club_key']) }} as club_id,
    club_key,
    club_name,
    country
from clubs
