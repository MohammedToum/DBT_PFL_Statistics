l{% snapshot players_snapshot %}

{{
  config(
    target_schema='snapshots',
    unique_key='player_id',
    strategy='check',
    check_cols=[
      'player_name', 'date_of_birth', 'nationality', 'position', 'foot', 'height_cm'
    ]
  )
}}

select
  player_id,
  player_name,
  date_of_birth,
  nationality,
  position,
  foot,
  height_cm
from {{ ref('stg_players') }}

{% endsnapshot %}