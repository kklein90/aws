import boto3
import subprocess

try:
    import argparse
except ModuleNotFoundError as e:
    print("this script requires the argparse python module")
    exit()

try:
    import inquirer
except ModuleNotFoundError as e:
    print("this script requires the inquirer python module")
    exit()

""" 
assumes a single deployed ECS cluster.
query ECS cluster in specified account (aws profile)
to build a list of services, ask user which service to connect to.
finds the taskId running for the service, and the container name.
then tries to launch an aws ecs exec session (/bin/sh).
user must be autheticated & have the aws cli + session manager
plugin installed.
"""

def get_env_client(account, region, svc):
    session = boto3.Session (profile_name=account, region_name=region)
    client = session.client(svc)
    return client

def get_svc_list(account, region):
    client = get_env_client(account, region, 'ecs')
    
    cluster_name = client.list_clusters(maxResults=1)['clusterArns'][0].split('/')[1]
    svc_arns = client.list_services(cluster=cluster_name)
    
    svc_names = []
    for arn in svc_arns['serviceArns']:
      arn_arr = arn.split('/')[-1].split('-')[0:2]
      svc_names.append(arn_arr[0] + '-' + arn_arr[1])

    return svc_names

def prompt_user(account, region):
    svc_names = get_svc_list(account, region)

    questions = [
    inquirer.List('service',
                  message="Which service to connect to?",
                  choices = svc_names
                  ),
    ]

    svc_conn = inquirer.prompt(questions)
    
    return svc_conn

def exec_cont(account, region):
    svc_conn = prompt_user(account, region)
    client = get_env_client(account, region, 'ecs')
    cluster_name = client.list_clusters(maxResults=1)['clusterArns'][0].split('/')[1]
    families = client.list_task_definition_families(familyPrefix=svc_conn['service'])
    for family in families['families']:
        tasks = client.list_tasks(cluster=cluster_name, family=family) # retuns taskArns
        try:
            task_id = tasks['taskArns'][0].split('/')[2]
        except IndexError as e:
            print("Could not list tasks: " + str(e) + "\n-- Is the service running?")
            exit()
    
    task_details = client.describe_tasks(cluster=cluster_name, tasks=[task_id])

    for task in task_details['tasks'][0]['containers']:
        if task['name'] == 'datadog-agent':  # don't want DD container
            continue
        else:
            cont_name = task['name']

    print("Connecting to: ")
    print("cluster name: " + cluster_name)
    print("task ID: " + task_id)
    print("container name: " + cont_name)

    subprocess.run(["aws", "--profile", account, "ecs", "execute-command", "--cluster", cluster_name, "--task", task_id, "--container", cont_name, "--interact", "--command", "/bin/sh"])

if __name__=="__main__":
    parser = argparse.ArgumentParser(description='ECS container exec')
    parser.add_argument(
        "--account", "-a",
        type=str,
        default="develop",
        help="AWS account to access (develop, staging, production) (default: %(default)s)"
    )
    parser.add_argument(
        "--region", "-r",
        type=str,
        default="us-east-1",
        help="AWS region to access (us-east-1,ca-west-1,eu-west-1) (default: %(default)s)"
    )
    pargs = parser.parse_args()
    account = pargs.account
    region = pargs.region

    exec_cont(account, region)