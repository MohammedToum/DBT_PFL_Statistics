{{ config(materialized='table') }}

with clubs as (
  -- replace this with your actual source of canonical club names
  select distinct club_name
  from {{ ref('stg_transfers') }}
),

clubs_norm as (
  select
    club_name,
    {{ normalize_club('club_name') }} as club_key
  from clubs
)

select
  c.club_name,
  cc.club_involved_country as club_country
from clubs_norm c
left join {{ ref('stg_club_countries') }} cc
  on c.club_key = cc.club_key
