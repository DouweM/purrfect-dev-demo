WITH source AS (
    SELECT *
    FROM {{ source('github', 'commits')}}
)

SELECT
  _sdc_repository                     AS repository,
  sha                                 AS sha,
  commit['author']['date']::DATETIME  AS timestamp,
  commit['author']['name']::VARCHAR   AS author,
  commit['message']::VARCHAR          AS message
FROM source
