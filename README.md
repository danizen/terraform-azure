# Terraform and Azure

## Summary

Goal is to build a VPC and applications in US East

## Linking Azure CLI and Terraform

Terraform will use the login created by the following action:

    az login

However, it needs some environment variables to know which account to use. To make this link both persistent in git and secure, the environment variables are encrypted in a file `env.sh.gpg`. This needs to be decrypted and sourced before terraform will work.

## Concept of Operation

- `bootstrap` creates a Storage Account, and two containers - "terraform" and "app", and 
  places its state only on the filesystem.  All other template directories keep state 
  in that storage account.

- `vnet` creates a two tier virtual network with application and database subnets.
  The application subnets can use a NAT Gateway to reach the outside world.
  A bastion is created in the application subnet.

- `pgdb` creates a postgres server in the db subnets with replication.

- `app` create a public IP, load balancer, and scale set that runs the application.

 
`pgdb` and `app` will import the state from `vnet`

