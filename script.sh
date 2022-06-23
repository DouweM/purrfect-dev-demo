# NOT an actual runnable Shell script, just called `.sh` to get syntax higlighting

# Install Python, install Pipx, `pipx install meltano`
meltano init speedrun
cd speedrun # This repo represents this speedrun directory. The init command was run one level up.

meltano add extractor tap-github

meltano config tap-github list
meltano config tap-github set repository "meltano/meltano"
meltano config tap-github set start_date 2022-06-02T00:00:00Z
meltano config tap-github list

# The only thing missing is the access token
# Not necessary if you create your own `.env` that Meltano picks up automatically
# source ../.env-github

meltano select tap-github --list --all
meltano --no-environment select tap-github commits "*"
meltano select tap-github --list

meltano add loader target-snowflake
meltano config target-snowflake list

# Replace these with your own Snowflake details
```
    config:
      account: epa06486
      dbname: USERDEV_RAW
      user: TAYLOR
      role: TMURPHY
      warehouse: CORE
      file_format: USERDEV_RAW.SPEEDRUN.TMP_CSV
      default_target_schema: SPEEDRUN
```

meltano config target-snowflake

# The only thing missing is the password
# Not necessary if you create your own `.env` that Meltano picks up automatically
# source ../.env-snowflake

meltano run tap-github target-snowflake

# Assuming you've renamed `.env.example` to `.env` and filled in your details,
# this will add them to the environment for `snowsql` to pick up
source .env

snowsql
SELECT _sdc_repository, sha, commit['author']['date']::DATETIME, commit['author']['name'], commit['message'] FROM commits LIMIT 5;
Ctrl+D

meltano add transformer dbt-snowflake

# Replace these with your own Snowflake details
```
    config:
      account: epa06486
      database: USERDEV_RAW
      user: TAYLOR
      role: TMURPHY
      warehouse: CORE
      schema: SPEEDRUN
      password: $TARGET_SNOWFLAKE_PASSWORD
```

```
# sources.yml
version: 2

# Replace these with your own Snowflake details
sources:
  - name: github
    database: USERDEV_RAW
    schema: SPEEDRUN
    quoting:
      database: true
      schema: false
      identifier: false

    tables:
      - name: commits
```

```
# github_commits.sql
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
```

```
# dbt_project.yml
models:
  my_meltano_project:
    github:
      +database: "{{ env_var('DBT_SNOWFLAKE_DATABASE') }}"
      +materialized: table
```

meltano run tap-github target-snowflake dbt-snowflake:run

snowsql
SELECT * FROM GITHUB_COMMITS LIMIT 5;
Ctrl+D

meltano add utility superset

```
pip_url: apache-superset==1.5.0 markupsafe==2.0.1 snowflake-sqlalchemy
```

meltano install utility superset
meltano invoke superset:create-admin

```
# analyze/superset/superset_config.py
import os

def password_from_env(url):
    return os.getenv("TARGET_SNOWFLAKE_PASSWORD")

SQLALCHEMY_CUSTOM_PASSWORD_STORE = password_from_env
```

meltano --no-environment config superset set _config_path analyze/superset/superset_config.py

meltano invoke superset:ui

open http://localhost:8088

# Data -> Databases -> +Database -> Snowflake -> SQLAlchemy URL
```
# Replace these with your own Snowflake details
snowflake://TAYLOR@epa06486/USERDEV_RAW?role=TMURPHY&warehouse=CORE
```
# Data -> Datasets -> +Dataset -> "Snowflake", "speedrun", "github_commits"
# Dashboards -> +Dashboard -> "Engineering" -> "Save
# Charts -> +Chart -> "github_commits" -> "Time-series Line Chart"
# Metrics: "Simple" -> Column: "sha" -> Aggregate: COUNT
# Save -> "Commits per day" -> Engineering
