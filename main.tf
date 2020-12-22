# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.0.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.21.0"
    }
  }
}

provider "random" {
}

provider "aws" {
	 profile = "tobyhf-admin"
	 region = "us-east-1"
}

resource "random_password" "password" {
  length = 16
  special = true
}

resource "aws_iam_role" "RedisLabsClusterNodeRole" {
    name = "redislabs-cluster-node-role"
    assume_role_policy = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
    EOT
    description = "Role used by EC2 instances managed by RedisLabs"
    tags = {
	UsedBy = "RedisLabs"
    }
}

resource "aws_iam_policy" "RedisLabsInstanceRolePolicy" {
    name = "RedisLabsInstanceRolePolicy"
    description = "Instance role policy used by Redislabs for its cluster members"
    policy = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes"
      ],
      "Resource": "*"
    },
    {
      "Sid": "EC2Tagged",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DeleteSecurityGroup",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/RedisLabsIdentifier": "Redislabs-VPC"
        }
      }
    },
    {
      "Sid": "EBSVolumeActions",
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:CreateTags",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    },
    {
      "Sid": "S3Object",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "*"
    },
    {
      "Sid": "IAM",
      "Effect": "Allow",
      "Action": [
        "iam:GetPolicy",
        "iam:ListPolicies"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}
    
resource "aws_iam_role_policy_attachment" "cluster-node-role-attach" {
  role       = aws_iam_role.RedisLabsClusterNodeRole.name
  policy_arn = aws_iam_policy.RedisLabsInstanceRolePolicy.arn
}

resource "aws_iam_instance_profile" "RedisLabsClusterNodeRoleInstanceProfile" {
  role = aws_iam_role.RedisLabsClusterNodeRole.name
}

resource "aws_iam_policy" "RedislabsIAMUserRestrictedPolicy" {
    name = "RedislabsIAMUserRestrictedPolicy"
    description = "Policy used by RedisLabs users"
    policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Ec2DescribeAll",
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchReadOnly",
      "Effect": "Allow",
      "Action": [
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "IamUserOperations",
      "Effect": "Allow",
      "Action": [
        "iam:GetUser",
        "iam:GetUserPolicy",
        "iam:ChangePassword"
      ],
      "Resource": "arn:aws:iam::*:user/$${aws:username}"
    },
    {
      "Sid": "RolePolicyUserReadActions",
      "Action": [
        "iam:GetRole",
        "iam:GetPolicy",
        "iam:ListUsers",
        "iam:ListPolicies",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfiles",
        "iam:ListInstanceProfilesForRole",
        "iam:SimulatePrincipalPolicy"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "KeyPairActions",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateKeyPair",
        "ec2:DeleteKeyPair",
        "ec2:ImportKeyPair"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CreateInstancesVolumesAndTags",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVolume",
        "ec2:AttachVolume",
        "ec2:StartInstances",
        "ec2:RunInstances",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PassRlClusterNodeRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::*:role/redislabs-cluster-node-role"
    },
    {
      "Sid": "NetworkAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:*Vpc*",
        "ec2:*VpcPeering*",
        "ec2:*Subnet*",
        "ec2:*Gateway*",
        "ec2:*Vpn*",
        "ec2:*Route*",
        "ec2:*Address*",
        "ec2:*SecurityGroup*",
        "ec2:*NetworkAcl*",
        "ec2:*DhcpOptions*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DeleteInstancesVolumesAndTagsWithIdentiferTag",
      "Effect": "Allow",
      "Action": [
        "ec2:RebootInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances",
        "ec2:DeleteVolume",
        "ec2:DetachVolume",
        "ec2:DeleteTags"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/RedisLabsIdentifier": "Redislabs-VPC"
        }
      }
    },
    {
      "Sid": "Support",
      "Effect": "Allow",
      "Action": "support:*",
      "Resource": "*"
    }
  ]
}
    EOT
}

resource "aws_iam_user" "RedisLabsUser" {
    name = "redislabs-user"
    tags = {
	UsedBy = "RedisLabs"
    }
}

resource "aws_iam_user_login_profile" "RedisLabsUserLoginProfile" {
  user    = aws_iam_user.RedisLabsUser.name
  pgp_key = "keybase:toby_h_ferguson"
  password_reset_required = false
}

resource "aws_iam_user_policy_attachment" "RedisLabsUserPolicyAttachment" {
  user       = aws_iam_user.RedisLabsUser.name
  policy_arn = aws_iam_policy.RedislabsIAMUserRestrictedPolicy.arn
}

resource "aws_iam_access_key" "RedisLabsUserAccessKey" {
    user = aws_iam_user.RedisLabsUser.name
    pgp_key = "keybase:toby_h_ferguson"
}

resource "aws_iam_role" "RedisLabsCrossAccountRole" {
    name = "redislabs-role"
    description = "String"
    assume_role_policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::168085023892:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
    EOT
    tags = {
	UsedBy = "RedisLabs"
    }
}

resource "aws_iam_role_policy_attachment" "cross-account-role-attach" {
  role       = aws_iam_role.RedisLabsCrossAccountRole.name
  policy_arn = aws_iam_policy.RedislabsIAMUserRestrictedPolicy.arn
}

output "access_key_id" {
    value = aws_iam_access_key.RedisLabsUserAccessKey.id
}

output "encrypted_secret_access_key" {
    description = "Decrypt thus: terraform output encrypted_secret_access_key | tr -d \" | base64 --decode | keybase pgp decrypt" 
    value = aws_iam_access_key.RedisLabsUserAccessKey.encrypted_secret
    sensitive = true
}

output "IAMRoleName" {
    description = "The name of the console role with access to the console"
    value =  aws_iam_role.RedisLabsCrossAccountRole.name
}

output "consoleUsername" {
    description =  "Redis Labs Users login username"
    value = aws_iam_user.RedisLabsUser.name
}

data "aws_caller_identity" "current" {}

output "signInLoginUrl" {
    description =  "Redis Labs User's console login URL"
    value = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console"
}

output "consolePassword" {
    description = "Redis Labs User's password. Decrypt thus: terraform output consolePassword | tr -d \" | base64 --decode | keybase pgp decrypt"
    value = aws_iam_user_login_profile.RedisLabsUserLoginProfile.encrypted_password
    sensitive = true
}


