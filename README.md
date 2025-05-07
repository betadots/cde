# Cloud Development Environment

Terraform and Bolt based deployment and provisioning of virtual machines with sshfs to a local workstation. At the moment only Proxmox is supported.

Also in the beginning only Debian and RHEL works. Ubuntu should works.

Required variables for Terraform (located in ./terraform) are:

* **proxmox** here the data for authentication
  * *endpoint* URL to the API endpoint of your Proxmox environment
  * *api_token*
* optional **vm_default** set defaults for all defined machines in **vms**
  * *type* (size) of the virtual machine
  * *template* name to clone from
  * *node* destination to deploy
  * *sshfs* hash to configure mounts from your local workstation
    * *user* name to login to your waorkstation
    * *private* private key (without passphrase) file to use 
  * *bridge* the vm is connected, defaults to vmbr0
  * *openvox* the openvox collection ("7" or "8") to use
* **vms** a hash of managed virtual machines cloned from templates
  * same options as in **vm_default**
* **types** for a definition of different VM sizes
  * name (for another hash) with count of *cores* and *memory*

See also the files with the suffix `.example`.

The file specified in `sshfs.private` of a virtual machine in `vms` will be copied to your new VM and will be used to authenticate against your local workstation. So the belonging public key has to be saved to your *authorized_keys* file of the user speficied. 

Requirements for the local machine:
* binaries in search path
  * facter
  * bolt
  * terraform
  * jq
* SSH access via pubkey without passphrass

Requirements for the used Proxmox templates:
* cloud-init, no package updates, user `cloud` with public ssh key
* qemu-guest-agent installed and running
* sshfs package installed

How to start?

* change into root project directory
* `./bin/cde init` 
  * initilize project (installs bolt modules and do a terraform init)
* `./bin/cde <up|destroy> [virtual machine]`
  * apply or destroy all or a specific defined machine(s)
* `./bin/cde ssh <virtual machine>`
  * logon specific machine  
