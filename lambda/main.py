import os
import time
import sys
import json
import boto3

SSM_DOCUMENT_NAME = os.getenv('SSM_DOCUMENT_NAME')
EC2_TARGET_TAGS = json.loads(os.getenv('EC2_TARGET_TAGS'))
TIMEOUT_SEC = int(os.getenv('TIMEOUT_SEC'))
MAX_ERRORS = os.getenv('MAX_ERRORS')

client_ssm = boto3.client('ssm')
client_ec2 = boto3.client('ec2')


def get_ec2_instances_ids_by_tags(tags):
    filters = []
    filters.append({
        'Name': 'instance-state-name',
        'Values': [
            'running',
        ]
    })
    for k, v in tags.items():
        filters.append({
            'Name': 'tag:' + k,
            'Values': [
                v,
            ]
        })
    response = client_ec2.describe_instances(Filters=filters, MaxResults=1000)

    ec2_ids = list()
    for instance in response['Reservations']:
        ec2_ids.append(instance['Instances'][0]['InstanceId'])

    return ec2_ids


def lambda_handler(*_):
    print(
        "INFO | Starting execution of '{0}' SSM document on EC2 instances with tags '{1}'..."
        .format(SSM_DOCUMENT_NAME, EC2_TARGET_TAGS))

    ec2_ids = get_ec2_instances_ids_by_tags(EC2_TARGET_TAGS)

    if not ec2_ids:
        print("WARN | No EC2 instances found. Stopping...")
        return

    print("INFO | Found EC2 instances '{0}'".format(", ".join(ec2_ids)))

    try:
        execution = client_ssm.send_command(
            DocumentName=SSM_DOCUMENT_NAME,
            InstanceIds=ec2_ids,
            MaxErrors=MAX_ERRORS,
            CloudWatchOutputConfig={'CloudWatchOutputEnabled': True})

        print("INFO | Waiting {0} seconds for execution completion...".format(
            TIMEOUT_SEC))
        waiter = client_ssm.get_waiter('command_executed')
        time.sleep(3)
        for v in ec2_ids:
            waiter.wait(CommandId=execution['Command']['CommandId'],
                        InstanceId=v,
                        WaiterConfig={
                            'Delay': 5,
                            'MaxAttempts': round(TIMEOUT_SEC / 5)
                        })
        print(
            "INFO | All Wireguard instances have been reloaded with no issues")
    # pylint: disable=broad-except
    except Exception as err:
        print("ERROR | {0}".format(err))
        sys.exit(1)
