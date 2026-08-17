{{ config(
    materialized='incremental',
    unique_key='ISSUE_ID'
) }}

SELECT
    ISSUE_ID,
    ISSUE_NUMBER,
    REPOSITORY,
    TITLE,
    BODY,
    STATE,
    STATE_REASON,
    COMMENTS_COUNT,
    AUTHOR_ID,
    AUTHOR_LOGIN,
    CREATED_AT,
    UPDATED_AT,
    CLOSED_AT,
    INGESTED_AT
FROM {{ ref("stg_git_raw") }}

{% if is_incremental() %}

WHERE UPDATED_AT >= (
    SELECT COALESCE(
        MAX(UPDATED_AT),
        '1900-01-01'::TIMESTAMP_TZ
    )
    FROM {{ this }}
)

{% endif %}

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY ISSUE_ID
    ORDER BY UPDATED_AT DESC, INGESTED_AT DESC
) = 1