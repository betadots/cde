# Cloud Development Environment

Terraform based deployment and provisioning of virtual machines with sshfs to a local workstation. At the moment only Proxmox is supported.

Also in the beginning only Debian works. Ubuntu should works.

Required variables are:

* **proxmox** here the data for authentication
  * *endpoint* URL to the API endpoint of your Proxmox environment
  * *api_token*
* **vms** a hash of managed virtual machines cloned from templates
  * *type* (size) of the virtual machine
  * *template* name to clone from
  * *node* destination to deploy
  * *sshfs* hash to configure mounts from your local workstation
    * *user* name to login to your waorkstation
    * *private* private key (without passphrase) file to use 
* **types** for a definition of different VM sizes
  * name (for another hash) with count of *cores* and *memory*

See also the files with the suffix `.example`.

The file specified in `sshfs.private` of a virtual machine in `vms` will be copied to your new VM and will be used to authenticate against your local workstation. So the belonging public key has to be saved to your *authorized_keys* file of the user speficied. 

Requirements for the local machine:
* facter in search path
* SSH access via pubkey without passphrass

Requirements for the used Proxmox templates:
* cloud-init, no package updates
* qemu-guest-agent installed and running
* sshfs package installed
