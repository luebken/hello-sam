bucket-name = test-mdl
stack-name = test-mdl

prepare-s3:
	aws s3 mb s3://$(bucket-name)

package:
	aws cloudformation package \
   	--template-file template.yaml \
   	--output-template-file serverless-output.yaml \
   	--s3-bucket $(bucket-name)

deploy:
	aws cloudformation deploy \
   	--template-file serverless-output.yaml \
   	--stack-name $(stack-name) \
   	--capabilities CAPABILITY_IAM