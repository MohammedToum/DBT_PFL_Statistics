{{ config(materialized='view') }}

with transfers as (
    select {{ normalise_club('from_club') }} as club_key
    from {{ ref('stg_transfers') }}
    union
    select {{ normalise_club('to_club') }} as club_key
    from {{ ref('stg_transfers') }}
),

mapped as (
    select club_key
    from {{ ref('stg_clubs_map') }}
    where club_key is not null and trim(club_key) <> ''
)

select t.club_key as key_norm
from transfers as t
left join mapped as m on t.club_key = m.club_key
where m.club_key is null
order by 1
