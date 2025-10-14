{{ config(materialized='view') }}

-- Grain: one row per player_id (latest known attributes per player)
with src as (
    select
        -- Rename to your actual raw columns
        cast(player_id as varchar) as player_id,
        trim(player_name)           as player_name,
        try_cast(player_dob as date) as date_of_birth,
        initcap(trim(nationality))  as nationality,
        trim(position)              as position,
        trim(foot)                  as foot,
        try_cast(height_cm as integer) as height_cm
    from {{ source('raw', 'raw_transfers') }}
    where player_id is not null
),

latest as (
    -- If the raw has multiple rows per player across seasons/transfers,
    -- pick a deterministic latest snapshot for "current" attributes.
    select *
    from (
        select
            *,
            row_number() over (partition by player_id order by coalesce(try_cast(transfer_date as date), date '1900-01-01') desc) as rn
        from {{ source('raw', 'raw_transfers') }}
    ) t
    where rn = 1
),

merged as (
    select
        cast(player_id as varchar) as player_id,
        trim(player_name) as player_name,
        try_cast(player_dob as date) as date_of_birth,
        initcap(trim(nationality)) as nationality,
        trim(position) as position,
        trim(foot) as foot,
        try_cast(height_cm as integer) as height_cm
    from latest
)

select
    {{ dbt_utils.generate_surrogate_key(['player_id']) }} as player_sk,
    player_id,
    player_name,
    date_of_birth,
    nationality,
    position,
    foot,
    height_cm
from merged
