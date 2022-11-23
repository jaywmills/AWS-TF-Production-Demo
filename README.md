# TF-Production-Demo

In this project, we build internal Windows Server workstations and an internal Apache webserver. Our internal Apache webserver will be connected to an Application Load Balancer that will balance HTTPS internally. We will create an internal Route53 Hosted Zone with a domain name of your choosing that will be referenced to access our internal Apache webserver. All security groups will reflect the appropriate ingress and egress blocks as least permissive. We will create bastion hosts to connect to each of our internal ec2 instances. Finally, we will use Systems Manager to ensure our internal Apache webserver and Windows Server workstation will receive security updates.

![Infrastructure Diagram drawio-2](https://user-images.githubusercontent.com/111475307/202274782-383af18b-8a7e-4032-ad4f-0c61836a28d0.png)
