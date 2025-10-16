{{ config(materialized='view') }}

with names as (
  select distinct
      initcap(trim(player_name)) as player_name
  from {{ source('raw','raw_transfers') }}
  where coalesce(trim(player_name),'') <> ''
)

select
    {{ surrogate_key_v1(["player_name"]) }} as player_sk,
    player_name
from names