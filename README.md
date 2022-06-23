Meltano project created during demo in <https://www.youtube.com/watch?v=gtDHuKj4Zfo>.

To use this:
1. Create a Snowflake account
2. Create a GitHub personal access token
3. Duplicate `.env.example` as `.env`
4. Update the Snowflake details in `meltano.yml` and `.env`
5. Update the GitHub account token in `.env`
6. Install Python and Meltano and run `meltano install` to install this project's plugins
7. Run `meltano run tap-github target-snowflake dbt-snowflake:run` to run the ELT pipeline
8. Run `meltano invoke superset:create-admin` to create an admin users
9. Run `meltano invoke superset:ui` to launch te Superset UI at http://localhost:8088
10. Create the Superset dashboard and chart as described [at the end of `script.sh`](script.sh#L141-L150)
