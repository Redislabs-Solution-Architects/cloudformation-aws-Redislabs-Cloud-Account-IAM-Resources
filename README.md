  # Overview
This module automates the manual [Creating IAM Entities for AWS Cloud Accounts](https://redis.io/docs/latest/operate/rc/subscriptions/bring-your-own-cloud/iam-resources/cloudformation/) process by using the following Cloudformation stack template instead:
  
  <a href="https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=RedisCloud&templateURL=https://s3.amazonaws.com/cloudformation-templates.redislabs.com/RedisCloud.yaml">
<img alt="Launch RedisCloud template" src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"/>
</a>

All you need to do to use this is click the above link and CloudFormation will do the rest. (Or, if you prefer, use the below aws cli command, substituting in your profile name:

```
aws cloudformation create-stack --stack-name RedisCloud --template-url \
https://s3.amazonaws.com/cloudformation-templates.redislabs.com/RedisCloud.yaml \
--capabilities CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM CAPABILITY_IAM \
--profile YOUR_PROFILE_HERE
```

Once the resources are created you can use the `Outputs` section of CloudFormation to get the values you'll need to complete the rest of the overall [RedisLabs Cloud Account](https://docs.redislabs.com/latest/rc/how-to/view-edit-cloud-account) creation process. 

# Longer

[Creating IAM Entities for AWS Cloud Accounts 
] describes a manual process for creating the necessary IAM resources so that you can subsequently _configure_ an AWS Cloud Account into your Redis Cloud Account, allowing your Redis Cloud Account to create Subscription and Database resources in your AWS Cloud Account. 

This repo contains a template (`RedisCloud.yaml`) to construct the necessary IAM resources.

If you configure an AWS Cloud Account 'By Hand' you'll be [following these instructions](https://docs.redislabs.com/latest/rc/how-to/view-edit-cloud-account/)

If you configure an AWS Cloud Account using the Cloud API you'll use [this specific call](https://api.redislabs.com/v1/swagger-ui.html#/Cloud%20Accounts/createCloudAccountUsingPOST)
  
The template will construct the necessary IAM resources required for both approaches. It will show them in the 'output' section of the stack, _except_ for the secrets (`accessSecretKey` and `consolePassword`), which are stored as secrets in the AWS Secret's manager. For these secrets the URL is output, from whence one can find the actual secret, assuming one has sufficient permissions.

The mapping between the stack outputs and the names used in the two different configuration methods is shown below:
  
| Output | By Hand | By API|
|---------|---|---|
| IAMRoleName | IAM Role Name | - |
| accessKeyId | AWS_ACCESS_KEY_ID | accessKeyId |
| accessSecretKey | AWS_SECRET_ACCESS_KEY | accessSecretKey |
| consolePassword | - | consolePassword |
| consoleUsername| - | consoleUsername |
| signInLoginUrl | - | signInLoginUrl |

 ## Updating
 From time to time new policy files are produced. Simply running an update on the stack will pick up these new files and the stack will be updated accordingly.
 

# Developer Information

## Prerequisite
 Expected resources:
 - AWS CLI
 - Git
 - JQ
 
 We expect you to have an AWS profile for the Redislabs AWS account # (we use the name 'redislabs' for that profile in the following instructions; amend as necessary for your naming convention).

## S3 Location
 The cloudformation template is stored in the publicly accessible Redislabs owned bucket `cloudformation-templates.redislabs.com`
 
 The template object itself has the key `/RedisCloud.yaml`. It references two snippets, one for each of two policies. These snippets are: `/RedisLabsInstanceRolePolicySnippet.json` and `/RedislabsIAMUserRestrictedPolicySnippet.json`


### Updating policies
 
These snippets are constructed from the policies (available in raw source form on the [Creating IAM Entities for AWS Cloud Accounts 
] page).
 
To update the policies use the following procedure:
 
1. Copy/paste the two files locally into the relevant json files `RedisLabsInstanceRolePolicy.json` and `RedislabsIAMUserRestrictedPolicy.json`
2. Create the snippets using this shell script:

```
for file in RedisLabsInstanceRolePolicy.json RedislabsIAMUserRestrictedPolicy.json
do
	snippet=$(basename $file .json)Snippet.json
	cat $file | jq '{ PolicyDocument: . }' >$snippet &&
	aws s3 --profile redislabs cp $snippet s3://cloudformation-templates.redislabs.com
done
```

### Updating the template

If you need to update the template then copy it to S3 thus:

```
aws s3 --profile redislabs cp RedisCloud.yaml s3://cloudformation-templates.redislabs.com
```

----------
[Creating IAM Entities for AWS Cloud Accounts 
]: https://docs.redislabs.com/latest/rc/how-to/creating-aws-user-redis-enterprise-vpc/
