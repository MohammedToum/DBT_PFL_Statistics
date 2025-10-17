{{ config(materialized='view') }}

with base as (
    select
        upper(trim(club_involved_name)) as cleaned_full_name,
        {{ normalise_club('club_involved_name') }} as club_key
    from {{ ref('country_of_clubs') }}
    where
        club_involved_name is not null
        and trim(club_involved_name) <> ''
)

select
    cleaned_full_name,
    club_key
from base
group by 1, 2
