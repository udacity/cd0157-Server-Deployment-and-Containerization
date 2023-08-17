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