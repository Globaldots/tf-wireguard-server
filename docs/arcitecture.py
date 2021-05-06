from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EC2ElasticIpAddress, EC2AutoScaling, EC2
# from diagrams.aws.database import RDS
from diagrams.aws.network import NLB, Route53
from diagrams.onprem.iac import Terraform
from diagrams.onprem.client import Users
from diagrams.aws.storage import S3
from diagrams.aws.integration import SNS, SimpleNotificationServiceSnsTopic
from diagrams.programming.language import Python
from diagrams.custom import Custom
from diagrams.aws.security import ACM


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
        eip = EC2ElasticIpAddress("Elastic IP")
        nlb = NLB("NLB \nHTTPS Listener & termination\nUDP Listener \n")
        acm = ACM("Certificate Manager \nACM")
        config = S3("S3")
        sns = SNS("SNS")
        front_app = EC2("Mgmt App (UI)")

        with Cluster("ec2_as", graph_attr={"label":"EC2 autoscaling group"}):
            ec2_autoscaling = EC2AutoScaling(
                    label="", fontsize="8", loc="t",
                    fixedsize="true", width="0.5", height="0.5", )
            wg = [
                EC2("wireguard 0"),
                EC2("wireguard 1")
            ]

        dns >> eip >> nlb >> Edge(label="UDP", lhead="cluster_ec2_as") >> wg[1]
        dns >> Edge(label="DNS validation") >> acm >> Edge(label="SSL certificate") >> nlb
        nlb >> Edge(label="HTTP") >> front_app >> Edge(lhead="cluster_ec2_as") >> wg[0]
        wg[1] << Edge(label="config", ltail="cluster_ec2_as") << config
        wg[0] << Edge(label="events", ltail="cluster_ec2_as") << sns


with Diagram("aws-ec2-wireguard app", show=False, graph_attr=graph_attr):
    config = S3("S3")

    with Cluster("wg", graph_attr={"label":"Wireguard instance"}):
        ec2 = EC2(
                label="", fontsize="8", loc="t",
                fixedsize="true", width="0.5", height="0.5", )
        wireguard =  Custom("Wireguard", "./wireguard-icon.png")
        backend_app = Python("BackendApp")

    with Cluster("ui", graph_attr={"label":"Mgmt App (UI)"}):
        ec2 = EC2(
                label="", fontsize="8", loc="t",
                fixedsize="true", width="0.5", height="0.5", )
        front_app = Python("FrontApp")

    Users() >> Edge(lhead="cluster_ui") >> front_app >> Edge(ltail="cluster_ui", lhead="cluster_wg") >> backend_app >> Edge(label="1. update config") >> config
    config >> Edge(label="2. fire event") >> SNS("SNS") \
        >> Edge(label="3. get event") >> backend_app >> \
            Edge(label="4. config update&reload") >> wireguard
