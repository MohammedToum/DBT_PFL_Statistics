{{ config(materialized='table') }}

-- Grain: one row per transfer_sk (a single transfer event)
with t as (
    select * from {{ ref('stg_transfers') }}
),

dim_links as (
    select
        t.transfer_sk,
        t.player_id,
        p.player_sk,
        fc.club_sk as from_club_sk,
        tc.club_sk as to_club_sk,
        t.transfer_date,
        t.season,
        t.transfer_type,
        t.fee_text,
        t.fee_eur
    from t
    left join {{ ref('dim_players') }} p
      on p.player_id = t.player_id
    left join {{ ref('dim_clubs') }} fc
      on fc.club_name = t.from_club
    left join {{ ref('dim_clubs') }} tc
      on tc.club_name = t.to_club
)

select
    transfer_sk,
    player_sk,
    from_club_sk,
    to_club_sk,
    transfer_date,
    season,
    transfer_type,
    fee_eur,
    fee_text
from dim_links
