function lines() {
    echo '---'
}
aws iam get-user --profile tobyhf-admin --user-name redislabs-user 
lines
for ROLE_NAME in redislabs-role redislabs-cluster-node-role
do
    aws iam get-role --profile tobyhf-admin --role-name $ROLE_NAME
    lines
    aws iam list-attached-role-policies --profile tobyhf-admin --role-name $ROLE_NAME
    lines
    ARN=$(aws iam list-attached-role-policies --profile tobyhf-admin --role-name $ROLE_NAME --query 'AttachedPolicies[0].PolicyArn' | tr -d '"')
    aws iam get-policy --profile tobyhf-admin --policy-arn $ARN
    lines
    aws iam get-policy-version --version-id v1 --profile tobyhf-admin --policy-arn $ARN
    lines
done
