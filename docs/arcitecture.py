from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2ElasticIpAddress, EC2AutoScaling, EC2
# from diagrams.aws.database import RDS
from diagrams.aws.network import NLB, Route53
from diagrams.onprem.iac import Terraform
from diagrams.onprem.client import Users
from diagrams.aws.storage import S3, SimpleStorageServiceS3Object
from diagrams.aws.integration import SNS, SimpleNotificationServiceSnsTopic, SQS, SimpleQueueServiceSqsQueue
from diagrams.programming.language import Python
from diagrams.custom import Custom
from diagrams.aws.security import ACM
from diagrams.generic.blank import Blank

graph_attr = {
    "layout":"dot",
    "compound":"true",
    "splines":"spline",
    }

with Diagram("aws-ec2-wireguard infra", show=False, direction="LR", graph_attr=graph_attr):
    with Cluster("Terraform management"):
        terraform = Terraform(
                label="", fontsize="8", loc="t",
                fixedsize="true", width="0.5", height="0.5", )


        dns = Route53("DNS")
        nlb = NLB("NLB \nHTTPS Listener & termination\nUDP Listener \n")
        acm = ACM("Certificate Manager \nACM")
        config = S3("S3")
        static_config = SimpleStorageServiceS3Object("server config: \n[Interface] \n...")
        sns = SNS("SNS")

        with Cluster("ec2_as_web", graph_attr={"label":"EC2 autoscaling group"}):
            ec2_autoscaling = EC2AutoScaling(
                    label="", fontsize="8", loc="t",
                    fixedsize="true", width="0.5", height="0.5", )

            front_app = EC2("Mgmt App (UI)")


        with Cluster("ec2_as", graph_attr={"label":"EC2 autoscaling group"}):
            ec2_autoscaling = EC2AutoScaling(
                    label="", fontsize="8", loc="t",
                    fixedsize="true", width="0.5", height="0.5", )

            wg = [
                EC2("wireguard 0"),
                EC2("wireguard 1")
            ]

        dns >> nlb >> Edge(label="UDP", lhead="cluster_ec2_as") >> wg[1]
        dns >> Edge(label="DNS validation") >> acm >> Edge(label="SSL certificate") >> nlb
        nlb >> Edge(label="HTTP") >> front_app >> Edge(lhead="cluster_ec2_as") >> wg[0]
        wg[1] << Edge(label="config", ltail="cluster_ec2_as") << config << static_config
        wg[0] << Edge(label="events", ltail="cluster_ec2_as") << sns


with Diagram("aws-ec2-wireguard app", show=False, graph_attr=graph_attr):
    config = S3("S3")
    update = SimpleNotificationServiceSnsTopic("SNS Topic")

    with Cluster("wg", graph_attr={"label":"Wireguard instance"}):
        ec2 = EC2(
                label="", fontsize="8", loc="t",
                fixedsize="true", width="0.5", height="0.5", )
        wireguard =  Custom("Wireguard", "./wireguard-icon.png")
        backend_app = Python("BackendApp")
        
    with Cluster("wg1", graph_attr={"label":"Wireguard instance 1"}):
        ec2 = EC2(
                label="", fontsize="8", loc="t",
                fixedsize="true", width="0.5", height="0.5", )
        wireguard_1 =  Custom("Wireguard", "./wireguard-icon.png")
        backend_app_1 = Python("BackendApp")

    with Cluster("ui", graph_attr={"label":"Mgmt App (UI)"}):
        ec2 = EC2(
                label="", fontsize="8", loc="t",
                fixedsize="true", width="0.5", height="0.5", )
        front_app = Python("FrontApp")

    Users() >> Edge(lhead="cluster_ui", color="darkgreen") >> front_app \
        >> Edge(ltail="cluster_ui", lhead="cluster_wg", color="darkgreen") >> backend_app

    backend_app >> Edge(label="1. update config", color="darkgreen") >> config \
        >> Edge(label="2. fire event", color="darkgreen") >> SNS("SNS") \
            >> Edge(label="3. pub \ncreate an event", color="darkgreen") >> update \
                >> Edge(label="4. sub. \nget event", color="darkgreen") >> backend_app \
                    >> Edge(label="6. config update&reload", color="darkgreen") >> wireguard
    backend_app << Edge(label="5. read config", color="darkgreen") << config 


    backend_app_1 << Edge(label="5. read config", color="darkorange") << config 
    update >> Edge(label="4. sub. \nget event", color="darkorange") >> backend_app_1 \
        >> Edge(label="6. config update&reload", color="darkorange") >> wireguard_1

    with Cluster("config", graph_attr={"label":"Wireguard server config"}):
        static_config = SimpleStorageServiceS3Object("server config: \n[Interface] \n...")
        dynamic_config = SimpleStorageServiceS3Object("# Peers \n[Peer] \n...")
    static_config - Edge(ltail="cluster_config")  - config


with Diagram("aws-ec2-wireguard app_sqs", show=False, graph_attr=graph_attr):
    config = S3("S3")
    app_q = SimpleQueueServiceSqsQueue("SQS queue instance")
    app_1_q = SimpleQueueServiceSqsQueue("SQS queue instance 1")
    sqs = SQS("SQS")

    with Cluster("wg", graph_attr={"label":"Wireguard instance"}):
        ec2 = EC2(
                label="", fontsize="8", loc="t",
                fixedsize="true", width="0.5", height="0.5", )
        wireguard =  Custom("Wireguard", "./wireguard-icon.png")
        backend_app = Python("BackendApp")
        
    with Cluster("wg1", graph_attr={"label":"Wireguard instance 1"}):
        ec2 = EC2(
                label="", fontsize="8", loc="t",
                fixedsize="true", width="0.5", height="0.5", )
        wireguard_1 =  Custom("Wireguard", "./wireguard-icon.png")
        backend_app_1 = Python("BackendApp")

    with Cluster("ui", graph_attr={"label":"Mgmt App (UI)"}):
        ec2 = EC2(
                label="", fontsize="8", loc="t",
                fixedsize="true", width="0.5", height="0.5", )
        front_app = Python("FrontApp")

    Users() >> Edge(lhead="cluster_ui", color="darkgreen") >> front_app \
        >> Edge(ltail="cluster_ui", lhead="cluster_wg", color="darkgreen") >> backend_app

    backend_app >> Edge(label="1. update config", color="darkgreen") >> config \
        >> Edge(label="2. fire event", color="darkgreen") >> sqs \
            >> Edge(label="3. create an message", color="darkgreen") >> app_q \
                >> Edge(label="4. read message", color="darkgreen") >> backend_app \
                    >> Edge(label="6. config update&reload", color="darkgreen") >> wireguard
    backend_app << Edge(label="5. read config", color="darkgreen") << config 


    backend_app_1 << Edge(label="5. read config", color="darkorange") << config 
    sqs >> Edge(label="3. create an message", color="darkorange") \
        >> app_1_q >> Edge(label="4. read message", color="darkorange") >> backend_app_1 \
            >> Edge(label="6. config update&reload", color="darkorange") >> wireguard_1
    
    with Cluster("config", graph_attr={"label":"Wireguard server config"}):
        static_config = SimpleStorageServiceS3Object("server config: \n[Interface] \n...")
        dynamic_config = SimpleStorageServiceS3Object("# Peers \n[Peer] \n...")
    static_config - Edge(ltail="cluster_config")  - config
