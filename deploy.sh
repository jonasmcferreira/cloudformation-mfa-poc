STACK_NAME="cloudformation-mfa-poc"
aws s3 mb s3://$STACK_NAME --region eu-central-1

## DELETE CLOUDFORMATION STACK
echo 'Deleting the stack...'
aws cloudformation delete-stack --stack-name $STACK_NAME
echo 'Waiting for the stack to be deleted, this may take a few minutes...'
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME
echo 'Done'


sam package --s3-bucket $STACK_NAME --s3-prefix $STACK_NAME --output-template-file packaged.yaml
aws cloudformation deploy --template-file packaged.yaml --stack-name $STACK_NAME --capabilities CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset
aws cloudformation describe-stack-events --stack-name $STACK_NAME --query "StackEvents[?ResourceStatus == 'CREATE_FAILED'].ResourceStatusReason"

user_pool_id=$(aws cognito-idp list-user-pools --max-results 20 --query 'UserPools[?Name==`Basys User Pool`].[Id]' --output text)
aws cognito-idp set-user-pool-mfa-config --user-pool-id $user_pool_id   --mfa-configuration ON --software-token-mfa-configuration Enabled=true