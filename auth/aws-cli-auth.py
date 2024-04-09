#!/usr/bin/env python3
import json
import os
import os.path
import subprocess
import argparse

VERSION = '1.1.0'
HOME_DIR = os.path.expanduser("~")
MGMT_ACCOUNT = "777764040422"
PROD_ACCOUNT = "380735047240"
DEV_ACCOUNT = "228923425684"
STAGE_ACCOUNT = "464677946080"
SSO_URL = "https://d-90678de24a.awsapps.com/start"
MGMT_ROLE_NAME = "AdministratorAccess"
STAGE_ROLE_NAME = "AdministratorAccess"
PROD_ROLE_NAME = "AdministratorAccess"
DEV_ROLE_NAME="AdministratorAccess"
ROLE_NAME="AdministratorAccess"
CREDENTIALS_FILE = HOME_DIR+"/.aws/credentials"

def setup_aws_config(region):

    config = f'''[profile default]
sso_start_url = {SSO_URL}
sso_region = {region}
sso_account_id = {DEFAULT_ACCOUNT}
sso_role_name = {DEFAULT_ROLE_NAME}
region = {region}
output = json

[profile mgmt]
sso_start_url = {SSO_URL}
sso_region = {region}
sso_account_id = {MGMT_ACCOUNT}
sso_role_name = {MGMT_ROLE_NAME}
region = {region}
output = json

[profile develop]
sso_start_url = {SSO_URL}
sso_region = {region}
sso_account_id = {DEV_ACCOUNT}
sso_role_name = {DEV_ROLE_NAME}
region = {region}
output = json

[profile staging]
sso_start_url = {SSO_URL}
sso_region = {region}
sso_account_id = {STAGE_ACCOUNT}
sso_role_name = {STAGE_ROLE_NAME}
region = {region}
output = json

[profile production]
sso_start_url = {SSO_URL}
sso_region = {region}
sso_account_id = {PROD_ACCOUNT}
sso_role_name = {PROD_ROLE_NAME}
region = {region}
output = json
'''

    with open(HOME_DIR+'/.aws/config', 'w') as fp:
        fp.write(config)

def clean_credentials_file():
    os.makedirs(f"{HOME_DIR}/.aws/sso/cache", exist_ok=True)
    with open(CREDENTIALS_FILE, 'w') as fp:
        fp.write('')

def sso_login():
    subprocess.call(f'aws sso login --profile mgmt', shell=True)

    path = HOME_DIR+'/.aws/sso/cache/'
    files = os.listdir(path)
    for filename in files:
        if 'boto' not in filename:
            with open(path+filename) as fp:
                content = fp.read()
                try:
                    print(f"Using {filename}...")
                    #Process file for all envs
                    process_file(DEFAULT_ACCOUNT, "default", "default", content)
                    process_file(PROD_ACCOUNT, "production", "production", content)
                    process_file(STAGE_ACCOUNT, "staging", 'staging', content)
                    process_file(DEV_ACCOUNT, "develop", "develop", content)
                except KeyError as e:
                    print("Error loading file, trying next.")

def process_file(account, alternative_name, profile, content):
    loaded_json = json.loads(content)
    access_token = loaded_json['accessToken']
    output = subprocess.check_output(f'aws sso get-role-credentials --region us-east-1 --account-id {account} --role-name {ROLE_NAME} --access-token "{access_token}"', shell=True)
    resp = json.loads(output)['roleCredentials']
    access_key = resp['accessKeyId']
    secret_access_key = resp['secretAccessKey']
    session_token = resp['sessionToken']
    credentials_content = f"""[{profile}]
aws_access_key_id = {access_key}
aws_secret_access_key= {secret_access_key}
aws_session_token = {session_token}

"""
    with open(CREDENTIALS_FILE, "a") as fp:
        fp.write(credentials_content + '\n')

if __name__=="__main__":
    parser = argparse.ArgumentParser(description='Log you in AWS Single Sign-On.')
    parser.add_argument(
        "--region",
        type=str,
        default="us-east-1",
        help="AWS region to log in. (default: %(default)s)"
    )
    parser.add_argument(
        "--default-role",
        type=str,
        default="security",
        help="default role in security,production,staging (default: sec)"
    )
    pargs = parser.parse_args()
    region = pargs.region
    baserole = pargs.default_role

    if baserole == "dev":
        DEFAULT_ACCOUNT = MGMT_ACCOUNT
        DEFAULT_ROLE_NAME = MGMT_ROLE_NAME
    elif baserole == "production":
        DEFAULT_ACCOUNT = PROD_ACCOUNT
        DEFAULT_ROLE_NAME = PROD_ROLE_NAME
    else:
        DEFAULT_ACCOUNT = STAGE_ACCOUNT
        DEFAULT_ROLE_NAME = STAGE_ROLE_NAME

    print(f"Running script version {VERSION} for region {region}")
    clean_credentials_file()
    print("Cleaned ~/.aws/credentials file.")
    setup_aws_config(region)
    print("Setup ~/.aws/config file")
    sso_login()

    print("Finished setup of production, staging & develop profiles.  Default profile set to " + baserole)


