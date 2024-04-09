import boto3
import subprocess

try:
    import inquirer
except ModuleNotFoundError as e:
    print("this script requires the inquirer python module")
    exit()


## todo - build list of service names dynamically
questions = [
    inquirer.List('service',
                  message="Which service to connect to?",
                  choices=['egateway', 'lender-ms', 'lender-web', 'macro-api','nginx', 'portal-web-dev', 'readiness-ms']
                  ),
]

svc_conn = inquirer.prompt(questions)

client=boto3.client('ecs')

# find cluster name
cluster_arn = client.list_clusters(maxResults=1)
cluster_name = cluster_arn['clusterArns'][0].split('/')[1]

## find service names - aws ecs list-services --cluster asterkey-cluster-01-development
# services = client.list_services(cluster=cluster_name, maxResults=10)
# for svc in services['serviceArns']:
#     last = len(svc.split("/"))
#     print(svc.split("/")[last - 1])


# find taskId
## need family names to find task id services
families = client.list_task_definition_families(familyPrefix=svc_conn['service'])

for family in families['families']:
    tasks = client.list_tasks(cluster=cluster_name, family=family) # retuns taskArns
    task_id = tasks['taskArns'][0].split('/')[2]

# find container name
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

subprocess.run(["aws", "ecs", "execute-command", "--cluster", cluster_name, "--task", task_id, "--container", cont_name, "--interact", "--command", "/bin/sh"])
