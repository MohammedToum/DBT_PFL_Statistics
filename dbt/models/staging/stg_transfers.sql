{{ config(materialized='view') }}

with base as (
    select
        cast(player_id as varchar)              as player_id,
        initcap(trim(player_name))              as player_name,
        try_cast(transfer_date as date)         as transfer_date,
        initcap(trim(from_club))                as from_club,
        initcap(trim(to_club))                  as to_club,
        trim(fee)                               as fee_text,
        try_cast(fee_eur as double)             as fee_eur_raw,   -- duckdb-safe
        lower(coalesce(fee, ''))                as fee_lc,
        cast(nullif(trim(season), '') as varchar) as season
    from {{ source('raw', 'raw_transfers') }}
),

fee_clean as (
    select
        player_id,
        player_name,
        transfer_date,
        season,
        from_club,
        to_club,
        fee_text,
        case
            when fee_lc like '%loan%' then 'LOAN'
            when fee_lc like '%free%' then 'FREE'
            when fee_lc like '%?%' or fee_lc like '%-%' then 'UNKNOWN'
            else 'PERM'
        end as transfer_type,
        case
            when fee_lc like '%loan%' then null
            when fee_lc like '%free%' then 0
            when fee_lc like '%?%' or fee_lc like '%-%' then null
            else fee_eur_raw
        end as fee_eur
    from base
)

select
    {{ dbt_utils.generate_surrogate_key([
        "'v1'",
        "player_id",
        "from_club",
        "to_club",
        "coalesce(cast(transfer_date as varchar), season)"
    ]) }} as transfer_sk,
    player_id,
    player_name,
    transfer_date,
    season,
    from_club,
    to_club,
    transfer_type,
    fee_text,
    fee_eur
from fee_clean