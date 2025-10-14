{{ config(materialized='table') }}

-- Grain: one row per player_sk (current attributes)
select
    p.player_sk,
    p.player_id,
    p.player_name,
    p.date_of_birth,
    p.nationality,
    p.position,
    p.foot,
    p.height_cm,
    c.country_sk as nationality_country_sk
from {{ ref('stg_players') }} p
left join {{ ref('dim_countries') }} c
  on c.country_name = p.nationality
