  # TL;DR
  Create the necessary resources for Redislabs to manage subscriptions in your AWS account: <a href="https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=RedisCloud&templateURL=https://doa1.s3.amazonaws.com/RedisCloud.yaml">
<img alt="Launch RedisCloud template" src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"/>
</a>

# Longer
  This repo contains a template (`RedisCloud.yaml`) to construct all the necessary resources
  to enable RedisCloud to manage clusters in your AWS account, as per
  
  https://docs.redislabs.com/latest/rc/how-to/creating-aws-user-redis-enterprise-vpc/
  
  These resources are then used to construct a RedisLabs account as per
  
  https://docs.redislabs.com/latest/rc/how-to/view-edit-cloud-account/

  This will construct:
  + An instance role and profile, both named `RedisLabsInstanceRolePolicy`
  + A user named `redislabs-user` with an access key
  + A role named `redislabs-role` granting AWS console access with MFA to the RedisLabs AWS account

  This stack will output the following:
  + an `AWS_ACCESS_KEY_ID` for the user `redislabs-user`
  + An `AWS_SECRET_ACCESS_KEY` for the user `redislabs-user`
  + The `redislabs-role` name
 
 
