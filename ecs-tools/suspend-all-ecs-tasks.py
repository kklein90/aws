import boto3

service_names = []

client = boto3.client('ecs')

cluster_arn = client.list_clusters(maxResults=1)
cluster_name = cluster_arn['clusterArns'][0].split('/')[1]

services = client.list_services(cluster=cluster_name)

for arn in services['serviceArns']:
    service = client.describe_services(cluster=cluster_name, services=[arn])
    for svc in service['services']:
        response = client.update_service(
            cluster='asterkey-cluster-01-staging',
            service=svc['serviceName'],
            desiredCount=0,
        )

        print(response['ResponseMetadata']['RequestId'] + ' ' + str(response['ResponseMetadata']['HTTPStatusCode']))
    

def lambda_handler(event, context):
    client = boto3.client('ecs')

    cluster_arn = client.list_clusters(maxResults=1)
    cluster_name = cluster_arn['clusterArns'][0].split('/')[1]

    services = client.list_services(cluster=cluster_name)

    for arn in services['serviceArns']:
        service = client.describe_services(cluster=cluster_name, services=[arn])
        for svc in service['services']:
            try:
                response = client.update_service(
                    cluster='asterkey-cluster-01-staging',
                    service=svc['serviceName'],
                    desiredCount=0,
                )
            except Exception as e:
                print(f"Error shutting down : {svc}, error: {str(e)}" )
    
    return {
        'statusCode': 200,
        'body': "All ECS services shut down"
    }

                