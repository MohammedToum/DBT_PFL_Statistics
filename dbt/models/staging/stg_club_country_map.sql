{{ config(materialized='view') }}

with src as (
    select
    {{ normalise_club('club_involved_name') }} as club_key,
        club_involved_name,
        club_involved_country as country
    from {{ ref('country_of_clubs') }}
    where
        club_involved_name is not null
        and trim(club_involved_name) <> ''
        and club_involved_country is not null
        and trim(club_involved_country) <> ''
)

select * from src
