with base as (
    select
        transfer_id,
        transfer_date,
        player_name,
        from_club,
        to_club,
        fee_amount,
        fee_currency
    from {{ ref('stg_transfers_compat') }}
    {% if is_incremental() %}
        where transfer_date >= date_trunc('month', current_date - interval 6 month)
    {% endif %}
),
-- (rest of the file unchanged)

keys as (
    select
        *,
        {{ normalise_club('from_club') }} as from_club_key,
        {{ normalise_club('to_club') }} as to_club_key
    from base
),

joined as (
    select
        k.*,

        -- From-club dimension attrs
        dc_from.club_id as from_club_id,
        dc_from.club_key as from_club_key_norm,
        dc_from.club_name as from_club_name_norm,
        dc_from.country as from_country,

        -- To-club dimension attrs
        dc_to.club_id as to_club_id,
        dc_to.club_key as to_club_key_norm,
        dc_to.club_name as to_club_name_norm,
        dc_to.country as to_country

    from keys as k
    left join {{ ref('dim_clubs') }} as dc_from
        on dc_from.club_key = k.from_club_key
    left join {{ ref('dim_clubs') }} as dc_to
        on dc_to.club_key = k.to_club_key
),

final as (
    select
        -- Stable surrogate for the row/grain
        {{ dbt_utils.generate_surrogate_key([
            "coalesce(cast(transfer_id as varchar), '')",
            "coalesce(cast(transfer_date as varchar), '')",
            "coalesce(player_name, '')",
            "coalesce(from_club_key, '')",
            "coalesce(to_club_key, '')",
            "coalesce(cast(fee_amount as varchar), '')",
            "coalesce(fee_currency, '')"
        ]) }} as transfer_sk,

        -- Natural/business key if present
        transfer_id,

        -- Grain columns
        transfer_date,
        player_name,

        -- Raw names from source (traceability)
        from_club,
        to_club,

        -- Normalized keys for joining
        from_club_key,
        to_club_key,

        -- Dimension lookups
        from_club_id,
        from_club_name_norm as from_club_name_canonical,
        from_country,

        to_club_id,
        to_club_name_norm as to_club_name_canonical,
        to_country,

        -- Measures
        fee_amount,
        fee_currency
    from joined
)

select * from final
