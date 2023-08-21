With regard to the file eks-cluster-policy.json:

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "eks:CreateCluster",
              "eks:DescribeCluster",
              "eks:UpdateClusterConfig",
              "eks:UpdateClusterVersion",
              "ssm:GetParameters"
            ],
            "Resource": "*" // * means that the already defined actions could be applied to any EKS cluster in the account
        }
    ]
}

In the file eksk8s/cluster-config.yaml the key nodeGroups.iam.instanceRoleARN has the value=arn:aws:iam::62132xxxx821:role/cv-eks-nodegroup-role. In a real project this file should be created using jinja/cookicutter in a previous step. This file should never have hard-coded values. However, for educational purposes/save time these values are hardcoded in the file.

This key pair was created in aws console. It is possible to do it using the command to create it. This step involves pushing (uploading) the keys to aws via aws cli or somehow.

The subnets were also created by hand in the aws console.