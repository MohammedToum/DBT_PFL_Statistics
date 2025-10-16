{{ config(materialized='view') }}

with base as (
    select
        -- duckdb has no INITCAP(); keep trimmed strings
        trim(player_name)                       as player_name,
        try_cast(null as date)                  as transfer_date,  -- source has no date
        cast(year as int)                       as year,
        cast(season as varchar)                 as season,
        trim(club_name)                         as this_club,        -- the focal club
        trim(club_involved_name)                as other_club,       -- counterparty
        lower(trim(transfer_movement))          as transfer_movement, -- 'in' / 'out'
        trim(fee)                               as fee_text,
        try_cast(fee_cleaned as double)         as fee_eur_raw,
        trim(league_name)                       as league_name
    from {{ source('raw','raw_transfers') }}
),

dir as (
    select
        player_name,
        transfer_date,
        year,
        season,
        case when transfer_movement = 'out' then this_club  else other_club end as from_club,
        case when transfer_movement = 'out' then other_club else this_club  end as to_club,
        fee_text,
        fee_eur_raw,
        case
          when lower(fee_text) like '%loan%' then 'LOAN'
          when lower(fee_text) like '%free%' then 'FREE'
          when fee_text like '%?%' or fee_text like '%-%' then 'UNKNOWN'
          else 'PERM'
        end as transfer_type
    from base
)

select
    {{ surrogate_key_v1([
        "'v1'",
        "coalesce(player_name,'')",
        "coalesce(from_club,'')",
        "coalesce(to_club,'')",
        "coalesce(cast(transfer_date as varchar), season)"
    ]) }}                                          as transfer_sk,
    player_name,
    transfer_date,
    season,
    year,
    from_club,
    to_club,
    transfer_type,
    fee_text,
    case
      when transfer_type in ('LOAN','UNKNOWN') then null
      when transfer_type = 'FREE' then 0
      else fee_eur_raw
    end                                             as fee_eur
from dir