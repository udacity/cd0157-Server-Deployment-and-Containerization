# Manual containerization
create-venv:
	pyenv virtualenv udacity-deployment-project
	echo udacity-deployment-project > venv

delete-venv:
	pyenv virtualenv-delete udacity-deployment-project
	rm venv

build-image:
	docker build -t myimage .

list-images:
	docker image ls

remove-image:
	docker image rm myimage

# For local run use post 8080, for containerized runs port 80
run-container:
	docker run --name myContainer --env-file=.docker_env -p 80:8080 myimage
	docker container ls
	docker container ps

list-containers:
	docker container ls

stop-container:
	docker container stop myContainer

remove-container:
	docker container rm myContainer

# Automatic deployment to AWS
create-cluster:
	eksctl create cluster --name simple-jwt-api --region=eu-north-1

get-nodes:
	kubectl get nodes

delete-cluster:
	eksctl delete cluster simple-jwt-api  --region=eu-north-1

get-aws-account-id:
	aws sts get-caller-identity --query Account --output text

create-deployment-role:
	aws iam create-role --role-name UdacityFlaskDeployCBKubectlRole --assume-role-policy-document file://trust.json --output text --query 'Role.Arn'

attach-policy-to-deployment-role:
	aws iam put-role-policy --role-name UdacityFlaskDeployCBKubectlRole --policy-name eks-describe --policy-document file://iam-role-policy.json

get-config-map:
	kubectl get -n kube-system configmap/aws-auth -o yaml > /tmp/aws-auth-patch.yml

# Add the following to fetched config map
# mapRoles: |
#   - groups:
#     - system:masters
#     rolearn: arn:aws:iam::<ACCOUNT_ID>:role/UdacityFlaskDeployCBKubectlRole
#     username: build

patch-config-map:
	kubectl patch configmap/aws-auth -n kube-system --patch-file /tmp/aws-auth-patch.yml

# Use ci-cd-codepipeline.cfn.yml template to create new stack in CloudFormation using new resources
