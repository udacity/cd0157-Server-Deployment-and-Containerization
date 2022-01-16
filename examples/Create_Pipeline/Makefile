create-stack:
	aws cloudformation create-stack  \
     --stack-name simple-pipeline-build \
     --region eu-north-1 \
     --template-body file://simple-pipeline-build.yml \
     --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM"
delete-stack:
	aws cloudformation delete-stack  --stack-name simple-pipeline-build
