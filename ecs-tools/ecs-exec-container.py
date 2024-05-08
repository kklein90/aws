import boto3
import subprocess

'''
exec into an ecs container
multi-profile aware
generate list of running tasks
present list of to choose from
run aws cmd as subprocess
'''

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


def get_env_client(account, region, svc):
    session = boto3.Session (profile_name=account, region_name=region)
    client = session.client(svc)
    return client

def prompt_user(cont_list):
    cont_list = cont_list
    # prompt user
    questions = [
        inquirer.List('service',
                    message="Which container to connect to?",
                    choices = cont_list
                    ),
    ]

    svc_conn = inquirer.prompt(questions)

    return svc_conn

def get_container_list(account, region):
    client = get_env_client(account, region, 'ecs')
    cluster_name = client.list_clusters(maxResults=1)['clusterArns'][0].split('/')[1]

    task_info={}
    cont_list=[]
    task_arns = client.list_tasks(cluster=cluster_name)
    for task_arn in task_arns['taskArns']:
        t_id = task_arn.split('/')[2]
        c_name = client.describe_tasks(cluster=cluster_name, tasks=[t_id])['tasks'][0]['containers'][0]['name']
        task_info[c_name] = t_id
        cont_list.append(c_name)
    # print(task_info)
    # print(cont_list)

    return cont_list, task_info, cluster_name

def exec_cont(cont_name, task_id, cluster, region):
    print("Connecting to: ")
    print("cluster name: " + cluster_name)
    print("task ID: " + task_id)
    print("container name: " + cont_name)
    subprocess.run(["aws", "--region", region, "--profile", account, "ecs", "execute-command", "--cluster", cluster_name, "--task", task_id, "--container", cont_name, "--interact", "--command", "/bin/sh"])

if __name__=="__main__":
    parser = argparse.ArgumentParser(description='Login to AWS')
    parser.add_argument(
        "--account", "-a",
        type=str,
        default="nonprod",
        help="AWS account to access (nonprod, production) (default: %(default)s)"
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

    cont_list, task_info, cluster_name = get_container_list(account, region)
    cont_name = prompt_user(cont_list)['service']
    task_id = task_info[cont_name]
    exec_cont(cont_name, task_id, cluster_name, region)




