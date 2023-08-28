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

The command `eksctl create cluster -f <file_name>` creates the file `$HOME/.kube/config` This file is the one that has the context to connect to the remote cluster. Then to store this file securely, the file should be encrypted and published in the artifacts list of the github repo. Then, in a linux terminal generate the gpg key with the command `gpg --full-generate-key`. For educational purposes I have not included a passphrase nor expiration date for this gpg key set. After, get the ID of the just created `gpg` with the command: `gpg --list-keys` Then, using the commands: `gpg --export -a KEY_ID | base64 -w 0 > public.asc` and `gpg --export-secret-keys -a KEY_ID | base64 -w 0  > private.asc` export the gpg keys that will be stored as secrets in GitHub actions. After, in the workflow import the gpg key to encrypt the file and then upload as artifact to GitHub actions repo.

#### Note:
For reference on how to deal with base64 and gpg keys use this link: https://dev.to/epam_india_python/how-we-set-up-gpg-keys-as-environment-variables-2f26
