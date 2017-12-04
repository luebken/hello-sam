#! /usr/bin/make -f
s3-bucket-name = test-mdl2

stack-name = hello-sam
AWS_REGION = us-east-1
API_ID := $(shell aws apigateway get-rest-apis --query "items[?name==\`$(stack-name)\`].id" | jq -r .[])

.DEFAULT_GOAL := help

prepare-s3: ## Create an S3 bucket.
	aws s3 mb s3://$(s3-bucket-name)

prepare-local-dynamo:
	aws dynamodb create-table \
	--endpoint-url http://localhost:8000 \
	--table-name $(TABLE_NAME) \
	--attribute-definitions AttributeName=id,AttributeType=S \
	--key-schema AttributeName=id,KeyType=HASH \
	--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

package: prepare-s3 ## Creates deployment zip file, uploads to S3, updates template.
	aws cloudformation package \
   	--template-file template.yaml \
   	--output-template-file serverless-output.yaml \
   	--s3-bucket $(s3-bucket-name)

deploy: package ## Deploys the stack. (Cloudformation CreateChangeSet, ExecuteChangeSet).
	aws cloudformation deploy \
   	--template-file serverless-output.yaml \
   	--stack-name $(stack-name) \
   	--capabilities CAPABILITY_IAM
	@echo "\nVisit https://console.aws.amazon.com/cloudformation/ for updates on the deployment."
	@echo "\n run "make curl" to test the endpoint."

curl: ## Test the application via curl.
	curl https://$(API_ID).execute-api.$(AWS_REGION).amazonaws.com/Prod/test?message=HeyHowAreYou&mdl=m01

delete: ## Deletes the whole stack.
	aws cloudformation delete-stack \
   	--stack-name $(stack-name)

local-start-dynamo:
	@echo "open http://localhost:8000/shell/ after dynamo has started"
	docker run -p 8000:8000 dwmkerr/dynamodb

local-start-api: ## Start the API locally.
	echo "currently not supported" https://github.com/awslabs/aws-sam-local/issues/105
	sam local start-api

local-invoke: ## Invoke the function locally.
	echo "currently not supported"
	echo '{"queryStringParameters" : {"message": "Hey, are you there?" }}' | sam local invoke GetHtmlFunction

	# via http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ##Shows help message

ifeq ($(s3-bucket-name), INSERTBUCKETNAME)
	@echo "Warning: It seems you haven't configured s3-bucket-name in the Makefile."
endif
	@echo "Available make commands:"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'