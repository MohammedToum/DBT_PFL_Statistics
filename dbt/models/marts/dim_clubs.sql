{{ config(materialized='table') }}

-- Grain: one row per unique club_name (normalized)
with clubs as (
    select
        initcap(trim(from_club)) as club_name
    from {{ source('raw', 'raw_transfers') }}
    where from_club is not null and trim(from_club) <> ''
    union
    select
        initcap(trim(to_club)) as club_name
    from {{ source('raw', 'raw_transfers') }}
    where to_club is not null and trim(to_club) <> ''
),

dedup as (
    select club_name
    from clubs
    group by club_name
)

select
    {{ dbt_utils.generate_surrogate_key(['club_name']) }} as club_sk,
    club_name
from dedup
