# Quick Start

The quick start describes step by step how to install the testbed.

The prerequisite is to have an account on one of the supported OpenStack cloud providers. Deploying on other OpenStack clouds
should be possible, but you may need to adapt some settings, like flavor and image names.

It is not part of this quick start to describe the registration with the individual cloud providers. Please contact the
respective cloud provider for this.

Product          | Provider      | Profile name
-----------------|---------------|--------------
Betacloud        | OSISM         | **betacloud**
Cleura           | Cleura        | **cleura**
Fuga Cloud       | FUGA          | **fuga**
OVH              | OVH           | **ovh**
OpenTelekomCloud | T-Systems     | **otc**
Wavestack        | noris network | **wavestack**
pluscloud open   | plusserver    | **pluscloudopen**
HuaweiCloud      | HuaweiCloud   | **huaweicloud**

Terraform must be installed and usable. Information on installing Terraform can be found in the [Terraform documentation](https://learn.hashicorp.com/tutorials/terraform/install-cli)
Currently Terraform **>= 1.2.0** is supported.

Ansible must be installed and usable. Information on installing Ansible can be found in the [Ansible documentation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
Currently Ansible **>=6.0.0** is supported.

Furthermore, **make** and **git** must be usable. These are mostly already usable. If not, please install them with the package
manager of the operating system you are using.

The first step is to clone the **osism/testbed** repository.

```sh
   git clone https://github.com/osism/testbed.git
   cd testbed
```

:::note

>**note:** In the following, OpenTelekomCloud is used as an example. The cloud name in **clouds.yaml** and the environment name
>(value of **ENVIRONMENT**) are **otc** in this case. If another cloud is used, replace **otc** with the respective profile name
>from the table above.

:::

The access data for the cloud provider used is then stored in **terraform/clouds.yaml**.
The **clouds.yaml** file is provided by the cloud provider used. Please check the documentation of the cloud provider you are
using or their support for details.

```yaml
   :caption: ``terraform/clouds.yaml`` sample for OpenTelekomCloud

   clouds:
     otc:
       auth:
         auth_url: https://iam.eu-de.otc.t-systems.com:443/v3
         project_name: eu-de
         user_domain_name: OTC-EU-DE-00000000000000000000
         domain_name: OTC-EU-DE-00000000000000000000
         username: USERNAME
         password: PASSWORD
       interface: public
       identity_api_version: 3

```

Then everything necessary for the installation is prepared.

```sh
   make prepare
```

Next, the necessary infrastructure is created with the help of Terraform.

```sh
   make ENVIRONMENT=otc create
```

Finally, OSISM is installed on the previously created infrastructure. Depending on the cloud, the installation will take some
time. Up to two hours is not unusual.

```sh
   make ENVIRONMENT=otc deploy
```

After the installation, you can log in to the manager via SSH.

```sh
   make ENVIRONMENT=otc login
```

When the testbed is no longer needed, it can be deleted.

```sh
   make ENVIRONMENT=otc clean
```
