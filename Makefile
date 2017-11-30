#! /usr/bin/make -f
s3-bucket-name = INSERTBUCKETNAME

stack-name = hello-sam
AWS_REGION = us-east-1
API_ID := $(shell aws apigateway get-rest-apis --query "items[?name==\`$(stack-name)\`].id" | jq -r .[])

.DEFAULT_GOAL := help

prepare-s3: ## Create an S3 bucket.
	aws s3 mb s3://$(s3-bucket-name)

package: prepare-s3 ## Creates deployment zip file, uploads to S3, updates template.
	aws cloudformation package \
   	--template-file template.yaml \
   	--output-template-file serverless-output.yaml \
   	--s3-bucket $(s3-bucket-name)

deploy: package ## Deploys the stack. (Cloudformation CreateChangeSet, ExecuteChangeSet). Visit https://console.aws.amazon.com/cloudformation/ for updates.
	aws cloudformation deploy \
   	--template-file serverless-output.yaml \
   	--stack-name $(stack-name) \
   	--capabilities CAPABILITY_IAM

curl: ## Test the application via curl.
	curl https://$(API_ID).execute-api.$(AWS_REGION).amazonaws.com/Prod/test

delete: ## Deletes the whole stack.
	aws cloudformation delete-stack \
   	--stack-name $(stack-name)

local-start-api: ## Start the API locally.
	sam local start-api

local-invoke: ## Invoke the function locally.
	echo '{"message": "Hey, are you there?" }' | sam local invoke GetHtmlFunction

	# via http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ##Shows help message

ifeq ($(s3-bucket-name), INSERTBUCKETNAME)
	@echo "Warning: It seems you haven't configured s3-bucket-name in the Makefile."
endif
	@echo "Available make commands:"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'