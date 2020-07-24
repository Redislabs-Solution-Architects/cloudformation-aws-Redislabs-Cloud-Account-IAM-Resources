AWS='aws iam --profile redislabs'
echo '--- #User: redislabs-user'
$AWS get-user --user-name redislabs-user --query '[User.UserName,User.Arn]' --output yaml
$AWS list-attached-user-policies --user-name redislabs-user --query 'AttachedPolicies[*].PolicyArn' --output yaml
$AWS list-user-policies --user-name redislabs-user --output yaml
$AWS get-policy --policy-arn arn:aws:iam::735486936198:policy/RedislabsIAMUserRestrictedPolicy --query [Policy.Arn,Policy.DefaultVersionId,Policy.AttachmentCount] --output yaml


function get_role() {
    echo '--- #Role:' $1
    role_name=$1
    policy_name=$2
    $AWS get-role --role-name ${role_name:?} --query [Role.Arn,Role.AssumeRolePolicyDocument] --output yaml
    $AWS list-role-policies --role-name ${role_name:?} --output yaml
    $AWS list-attached-role-policies --role-name ${role_name:?} --query 'AttachedPolicies[*].[PolicyArn]' --output yaml
    $AWS get-policy-version --policy-arn arn:aws:iam::735486936198:policy/${policy_name:?} --version-id v1 | grep -v CreateDate | yq -y .
}

get_role redislabs-cluster-node-role RedisLabsInstanceRolePolicy
get_role redislabs-role RedislabsIAMUserRestrictedPolicy

$AWS get-instance-profile --instance-profile-name redislabs-cluster-node-role | grep -v '.*Id' | grep -v CreateDate | yq -y .
