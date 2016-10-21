Terraform AWS Mesos/Marathon infrastructure ===========================================

## Background

This repository contains example Terraform code to setup a complete AWS infrastructure for running and managing a
container-based platform (Mesos/Marathon was used but can be replaced by any other clustered container management
software). The original design is included as a reference. The goal of this repository is **not** to provide you with a
copy-paste platform, but rather as a way to share knowledge on how to build Terraform based infrastructures. Of course
it is possible to use this setup but it would probably require tweaks for your specific situation.

There is not a whole lot of information out there on how to setup a maintainable Terraform codebase for a large
infrastructure. This repository aims to serve as an example of how it can be done. Of course it is also based on
knowledge gathered from multiple blogs, most notably these:

* https://charity.wtf/tag/terraform/
* http://blog.sinica.me/aws_multi_account_with_terraform.html
* https://segment.com/blog/rebuilding-our-infrastructure/

I encourage you to read them all before starting your Terraform journey.

## Caveats

This repository is only concerned with setting up low-level AWS infrastructure to run services on top. You will need
some kind of provisioning to actually get something useful. We used Ansible for this but you can pick any tool you like.
It is also one possible implementation and not necessarily the **right** one. I am confident though that it will help
you get up and running with Terraform more quickly, at which point you can evolve the code further.

The current state of the code is a reflection of where we were at a specific moment in time. It will likely have evolved
but I feel that at this point it provides enough benefits to put it out there for further study and discussion. I've
tried to generalize the code as much as possible but I may have missed some bits that make it hard to start the platform
as-is. It also assumes some small bootstrap steps (creating state-buckets, keys, accounts etc.) on AWS before you can
start using it. Let me know if you want to set it up and run into trouble. I'll try to help out and update the
repository with guidance.

Lastly, this is not a Terraform tutorial. It assumes you understand what Terraform is and what the syntax looks like.
The Terraform documentation is pretty good for understanding the resources that are being used.

## AWS Design

This Terraform is the result of an [AWS design](https://github.com/nautsio/terraform-aws-starter/design/platform_design.pdf)
that we created before coding anything. I can highly recommend that you do this, as it will give you a clear 'dot-on-the-horizon'
and gets everybody on the same page. I'm including the design here, not as something that you have to implement as the
one true way, but rather to better understand the code that is in this repository. Of course I would love to hear about
improvements that could be made.

## Workflow

Having a clearly defined Terraform workflow was imperative to having a good experience with multiple people working on
the code. We've codified our workflow in a Makefile that is included in the repo. It contains a number of commands that
makes working with Terraform and remote state easy. Running ```make help``` will give you an overview of the commands.
Most likely you will want to use ```make plan ENV=...``` and ```make apply ENV=...``` most of the time.

We've separated environments to different AWS accounts and use the 'assume-role' functionality of AWS to centralize
management of all environment to a single account. Of course you can just use multiple environments within the same AWS
account. This will simplify a number of things but you lose the complete isolation. **Always** create separate state
files for your environments to isolate the failure domain, even if you run in one AWS account. The Makefile requires
that you setup some information on account and KMS key identifiers before you can use it. This is part of the AWS
bootstrapping that you have to do before using this repository.

## Code Layout and Design

The repository contains two top-level directories ```environments``` and ```modules```. The first one contains all the
configuration for the different environments and makes use of the generic Terraform modules that can be found in the
second the directory. Let's start with the modules first.

### Modules

Every Terraform module is structured in roughly the same way. It contains an ```variables.tf```, ```main.tf``` and
```outputs.tf``` file. The variables file contains all the variables that can be used as input to the module. The main
file contains the actual resources that logically make up a piece of functionality. The general rule here is that if you
need two or more resources to setup a piece of functionality, that you create a module for it, no exceptions. This keeps
things nicely reusable and coherent. Some modules, depending on the use-case, contain some additional files like
userdata and additional Terraform files that are being used by the module.

The ```env``` module is a special 'templating' module. It spins up entire identical environments in one go. The
acceptance and production environment (VPC) are an example of this. By parameterizing the env module you can customize
the environment as you see fit (e.g. bigger or smaller instances). Using modules in this way is really powerful concept
that really ties things together and makes for a maintainable code base.

### Environments

As you can see in the AWS design there are a number of environments. Some of them are connected through peering, which
allows resources to communicate with each other as if they were in the same VPC. This really enables some nice separation of
concerns.

#### Management

This environment contains all the services necessary to operate our infrastructure. There could be an ELK stack,
Prometheus, Grafana etc. It also provides connectivity into the environment through a bastion and openvpn host. It is
also the home of an automation server that triggers deployments or starts provisioning runs.

#### Services

The services environment is used for applications that support the development process, provide communication tooling,
etc. It is not concerned with management of the environments and it also does not run application workloads.

#### VPN

This environment is the gateway to the corporate datacenter via a VPN connection. Through peering we can let other
environments communicate with on-premises infrastructure.

#### Acceptance / Production / etc.

These are the environments that run our application workloads. They contain services like cluster management, databases,
caching etc. They are all identical with respect to infrastructure setup but can be scaled up or down (in terms of
compute or database replication etc.) according to the needed capacity. If you run your VPC's within the same AWS
account you can fully automate this process!

I hope that this example code will give you new insights or a headstart with your Terraform journey!
