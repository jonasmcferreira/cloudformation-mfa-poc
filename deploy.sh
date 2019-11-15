STACK_NAME="cloudformation-mfa-poc"
aws s3 mb s3://$STACK_NAME --region us-west-1

## DELETE CLOUDFORMATION STACK
echo 'Deleting the stack...'
aws cloudformation delete-stack --stack-name $STACK_NAME
echo 'Waiting for the stack to be deleted, this may take a few minutes...'
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME
echo 'Done'


sam package --s3-bucket $STACK_NAME --s3-prefix $STACK_NAME --output-template-file packaged.yaml
aws cloudformation deploy --template-file packaged.yaml --stack-name $STACK_NAME --capabilities CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset