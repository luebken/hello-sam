# set an bucketname and 
s3-bucket-name = <INSERT A S3 BUCKET NAME>

stack-name = hello-sam
AWS_REGION = us-east-1
API_ID := $(shell aws apigateway get-rest-apis --query "items[?name==\`$(stack-name)\`].id" | jq -r .[])

.DEFAULT_GOAL := deploy

prepare-s3:
	aws s3 mb s3://$(s3-bucket-name)

package: prepare-s3
	aws cloudformation package \
   	--template-file template.yaml \
   	--output-template-file serverless-output.yaml \
   	--s3-bucket $(s3-bucket-name)

deploy: package # deploys the stack. see https://console.aws.amazon.com/cloudformation/
	aws cloudformation deploy \
   	--template-file serverless-output.yaml \
   	--stack-name $(stack-name) \
   	--capabilities CAPABILITY_IAM

curl:
	curl https://$(API_ID).execute-api.$(AWS_REGION).amazonaws.com/Prod/test

delete:
	aws cloudformation delete-stack \
   	--stack-name $(stack-name)
