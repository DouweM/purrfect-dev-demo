import os

def password_from_env(url):
    return os.getenv("TARGET_SNOWFLAKE_PASSWORD")

SQLALCHEMY_CUSTOM_PASSWORD_STORE = password_from_env
