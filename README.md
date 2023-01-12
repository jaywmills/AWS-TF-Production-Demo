# TF-Production-Demo

In this example production project, we are building internal Windows Server workstations and an internal Apache webserver. The internal Apache webserver will be connected to an Application Load Balancer, which will balance HTTPS traffic internally. In order to access the internal Apache webserver, an internal Route53 Hosted Zone will be created with a domain name of your choosing. All security groups will be configured to have the least permissive ingress and egress rules possible. To securely connect to the internal ec2 instances, bastion hosts will be set up. Finally, Systems Manager will be used to ensure that the internal Apache webserver and Windows Server workstations receive security updates on a regular basis.

![Infrastructure Diagram drawio-2](https://user-images.githubusercontent.com/111475307/202274782-383af18b-8a7e-4032-ad4f-0c61836a28d0.png)
