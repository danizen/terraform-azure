# Terraform and Azure

## Summary

Goal is to build a VPC and application which is dual redundant in US East 2 and US West 2

## Linking Azure CLI and Terraform

Terraform will use the login created by the following action:

    az login

However, it needs some environment variables to know which account to use. To make this link both persistent in git and secure, the environment variables are encrypted in a file `env.sh.gpg`. This needs to be decrypted and sourced before terraform will work.

## Concept of Operation

Rather than make each of these modules, the goal is to make them somewhat independent
by using data sources and an "azurerm" remote so that each could be separate repositories.  More importantly, I want to model how an organization could decouple terraform projects into different repositories and access shared state.

- `bootstrap` creates a Storage Account, and two containers - "terraform" and "app", and 
  places its state only on the filesystem.  All other template directories keep state 
  in that storage account.

- `vnet` creates 2 virtual networks with application and database subnets.
  The application subnets can use a NAT Gateway to reach the outside world, and
  a network security group so that only HTTP and HTTPS can some in. A bastion
  is created in each application subnet.

- `pgdb` creates a postgres server (flexible server) only available in the db subnets,
  with replication.

- `cosmos` creates a CosmosDB Mongo API server only available in the db subnets.

- `app` create a public IP, load balancer, and scale set that runs the application.

 
`pgdb` and `app` will import the state from `vnet`

## Status

I now have a minimally functional VPC with the two vnets and subnets per VPC. Security
is not quite there yet, but VMs in the app subnets can be reached via SSH (directly) whereas
VMs in the db subnet are not accessible.  Since there is not yet a NAT gateway, none of
these can reach the internet.

## Todo

* Add Azure Firewall to vnet
  - limit outgoing connections as follows:
    - 443 to everything
    - 80 to everything
    - 22 to Github
    - 53 to everything - DNS requests for referred DNS
  - Limit incoming as follows
    - 443
    - 80
    - 22

* Add private endpoints for
  - Key Vault
  - Storage

## Architecture

* A network security group is ~~attached to~~ associated with subnets or vms.
* An application security group is ~~attached to~~ associated with the application.
  - Supports multiple applications in the same subnet (anti-pattern)
  - Supports multiple application on the same virtual machine, and zero trust (ok)
