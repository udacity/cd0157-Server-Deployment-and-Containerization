# Deploying Flask API

## Initial setup
1. Fork this project by pressing the fork buton
2. Locally clone your Forked version. You can now begin modifying it. 

## Containerizing and Running Locally
The supplied flask app is a very simple api with three endpoints.
GET '/': This is a simple health check, which returns the response 'Healthy'. 
POST '/auth': This  takes a email and password as json arguments and returns a jwt token base on a custom secret.
GET '/contents': This requires a valid jwt token, and returns the un-encrpyted contents of that token. 

### Run the Api using Flask Server
1. Install python dependencies. These dependencies are kept in a requirements.txt file. To install them, use pip:
    ```bash
    pip install -r requirements.txt
    ```
2. Set up the environment. The following environment variable is required:

    **JWT_SECRET** - The secret used to make the JWT token, for the purpose of  this course it can be any string.

     The following environment variable is optional:

     **LOG_LEVEL** - The level of logging. Will default to 'INFO', but when  debugging an app locally, you may want to set it to 'DEBUG'

    ```bash
    export JWT_SECRET=myjwtsecret
    export LOG_LEVEL=DEBUG
    ```

3. Run the app using the Flask server, from the flask-app directory, run:
    ```bash
    python app/main.py
    ```

    To try the api endpoints, open a new shell and run, replacing '\<EMAIL\>' and '\<PASSWORD\>' with and any values:

    ```bash
    export TOKEN=`curl -d '{"email":"<EMAIL>","password":"<PASSWORD>"}' -H "Content-Type: application/json" -X POST localhost:80/auth  | jq -r '.token'`
    ```

     This calls the endpoint 'localhost:80/auth' with the '{"email":"<EMAIL>","password":"<PASSWORD>"}' as the message body. The return value is a jwt token based on the secret you supplied. We are assigning that secret to the environment variable 'TOKEN'. To see the jwt token, run:

    ```bash
    echo $TOKEN
    ```
    To call the 'contents' endpoint, which decrpyts the token and returns it content, run:

    ```bash
    curl --request GET 'http://127.0.0.1:80/contents' -H "Authorization: Bearer ${TOKEN}" | jq .
    ```
     You should see the email that you passed in as one of the values.

### Dockerize and Run Locally

1. Install Docker: [installation instructions](https://docs.docker.com/install/)

2. Create a Docker file. A Docker file decribes how to build a Docker image.  Create a file named 'Dockerfile' in the app repo. The contents of the file describe the steps in creating a Docker image.  Your Dockerfile should:
	- use the 'python:strech' image as a source image
	- Setup an app directory for your code
	- Install needed python requirements
	- Define an entrypoint which will run the main app using the gunicorn WSGI server

    gunicorn should be run with the arguments:

    ```bash
    gunicorn -b :8080 main:APP
    ```


3. Create a file named 'env_file' and use it to set the environment variables which will be run locally in your container. Here we do not need the export command, just an equals sign:

    ```
     \<VARIABLE-NAME\>=\<VARIABLE-VALUE\>
    ```

4. Build a Local Docker Image. To build a Docker image run:
    ```bash
    docker build -t jwt-api-test .
    ```

5. Run the image locally, using the 'gunicorn' server:
    ```bash
    docker run --env-file=env_file -p 80:8080 jwt-api-test
    ```

    To use the endpoints use the same curl commands as before:

    ```bash
    export TOKEN=`curl -d '{"email":"<EMAIL>","password":"<PASSWORD>"}' -H "Content-Type: application/json" -X POST localhost:80/auth  | jq -r '.token'`
    ```
    ```bash
    curl --request GET 'http://127.0.0.1:80/contents' -H "Authorization: Bearer ${TOKEN}" | jq .
    ```

## Deployment to Kubernetes using CodePipeline and CodeBuild

### Create a Kubernetes (EKS) Cluster

1. Create an EKS cluster named 'simpe-jwt-api'

### Create Pipeline
You will now create a pipeline which watches your Github. When changes are checked in, it will build a new image and deploy it to your cluster. 


1. Create an IAM role that CodeBuild can use to interact with EKS. :
	- Set an environment variable `ACCOUNT_ID` to the value of your AWS account id. You can do this with awscli:
            ```bash
            ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
            ```
	 - Create a role policy document that allows the actions "eks:Describe*" and "ssm:GetParameters". You can do this by setting an environment variable with the role policy:
	    ```bash
            TRUST="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"AWS\": \"arn:aws:iam::${ACCOUNT_ID}:root\" }, \"Action\": \"sts:AssumeRole\" } ] }"
            ```
	 - Create a role named 'UdacityFlaskDeployCBKubectlRole' using the role policy document:
	     ```bash
	     aws iam create-role --role-name UdacityFlaskDeployCBKubectlRole --assume-role-policy-document "$TRUST" --output text --query 'Role.Arn'
	     ```
	 - Create a role policy document that also allows the actions "eks:Describe*" and "ssm:GetParameters". You can create the document in your tmp directory:
	     ```bash
             echo '{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": [ "eks:Describe*", "ssm:GetParameters" ], "Resource": "*" } ] }' > /tmp/iam-role-policy 
             ```
	 - Attach the policy to the 'UdacityFlaskDeployCBKubectlRole'. You can do this using awscli:
	     ```bash
    
             aws iam put-role-policy --role-name UdacityFlaskDeployCBKubectlRole --policy-name eks-describe --policy-document file:///tmp/iam-role-policy
              ```
    You have now created a role named 'UdacityFlaskDeployCBKubectlRole'

2. Grant the role access to the cluster.
The 'aws-auth ConfigMap' is used to grant role based access control to your cluster. 

    ```bash
    ROLE="    - rolearn: arn:aws:iam::$ACCOUNT_ID:role/UdacityFlaskDeployCBKubectlRole\n      username: build\n      groups:\n        - system:masters"
    kubectl get -n kube-system configmap/aws-auth -o yaml | awk "/mapRoles: \|/{print;print \"$ROLE\";next}1" > /tmp/aws-auth-patch.yml
    kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yml)"
    ```

3. Generate a GitHub access token.
 A Github acces token will allow CodePipeline to monitor when a repo is changed. A token can be generated [here](https://github.com/settings/tokens/=).
This token should be saved somewhere that is secure.

4. The file *buildspec.yml* instructs CodeBuild. We need a way to pass your jwt secret to the app in kubernetes securly. You will be using AWS parameter-store to do this. First add the following to your buildspec.yml file:

    ```yaml
    env:
      parameter-store:         
        JWT_SECRET: JWT_SECRET
    ```
    This lets CodeBuild know to set an evironment variable based on a value in the parameter-store.

5.  Put secret into AWS Parameter Store 

    ```bash
    aws ssm put-parameter --name JWT_SECRET --value "YourJWTSecret" --type SecureString
    ```

6. Modify CloudFormation template.

   There is file named *ci-cd-codepipeline.cfn.yml*, this the the template file you will use to create your CodePipeline pipeline. Open this file and go to the 'Parameters' section. These are parameters that will accept values when you create a stack. Fill in the 'Default' value for the following:
   - **EksClusterName** : use the name of the EKS cluster you created above
   - **GitSourceRepo** : use the name of your project's github repo.
   - **GitHubUser** : use your github user name
   - **KubectlRoleName** : use the name of the role you created for kubectl above

   Save this file.
   
7. Create a stack for CodePipeline
    - Go the the [CloudFormation service](https://us-east-2.console.aws.amazon.com/cloudformation/) in the aws console. 
    - Press the 'Create Stack' button. 
    - Choose the 'Upload template to S3' option and upload the template file 'ci-cd-codepipeline.cfn.yml'
    - Press 'Next'. Give the stack a name, fill in your GitHub login and the Github access token generated in step 9. 
    - Confirm the cluster name matches your cluster, the 'kubectl IAM role' matches the role you created above, and the repository matches the name of your forked repo.
    - Create the stack.
 
    You can check it's status in the [CloudFormation console](https://us-east-2.console.aws.amazon.com/cloudformation/).

8. Check the pipeline works. Once the stack is successfully created, commit a change to the master branch of your github repo. Then, in the aws console go to the [CodePipeline UI](https://us-east-2.console.aws.amazon.com/codesuite/codepipeline). You should see that the build is running.

9. To test your api endpoints, get the external ip for your service:

    ``` bash
    kubectl get services simple-jwt-api -o wide
    ```

    Now use the external ip url to test the app:

    ```bash
    export TOKEN=`curl -d '{"email":"<EMAIL>","password":"<PASSWORD>"}' -H "Content-Type: application/json" -X POST <EXTERNAL-IP URL>:80/auth  | jq -r '.token'`
    curl --request GET '<EXTERNAL-IP URL>:80/contents' -H "Authorization: Bearer ${TOKEN}" | jq 
    ```

10. Paste the external id from above below this line for the reviewer to use:

 **EXTERNAL IP**: 

11. Add running tests as part of the build. 

    To require the unit tests to pass before our build will deploy new code to your cluster, you will add the tests to the build stage. Remember you installed the requirements and ran the unit tests locally at the beginning of this project. You will add the same commands to the *buildspec.yml*:
	- Open *buildspec.yml*
	- In the prebuild section, add a line to install the requirements and a line to run the tests. You may need to refer to 'pip' as 'pip3' and 'python' as 'python3'
	- save the file

12. You can check the tests prevent a bad deployment by breaking the tests on purpose:
	- Open the *test_main.py* file
	- Add `assert False` to any of the tests
	- Commit your code and push it to Github
	- Check that the build fails in [CodePipeline](https://us-east-2.console.aws.amazon.com/codesuite/codepipeline)
