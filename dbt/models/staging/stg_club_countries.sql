{{ config(materialized='view') }}

with base as (
  select
    club_involved_name,
    club_involved_country,
    {{ normalise_club('club_involved_name') }} as club_key
  from {{ ref('country_of_clubs') }}
)

select * from base
