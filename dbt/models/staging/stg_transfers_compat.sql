select
    transfer_sk as transfer_id,
    transfer_date,
    player_name,

    -- TODO: replace these with your actual column names
    from_club,      -- e.g. source column name
    to_club,        -- e.g. source column name
    fee_eur as fee_amount,     -- e.g. source column name
    'EUR' as fee_currency

from {{ ref('stg_transfers') }}
