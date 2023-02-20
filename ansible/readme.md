# Ansible playbook for provisioning

Single playbook for provisioning main, cpu and gpu instances for Steep. After the first provisioning, the main instance will keep the local copy of this repository up to date and runs ansible after each change automatically. It is sufficient to just update the services.yaml or hosts file in gitlab. The changes are deployed automatically.

## Create OpenStack instances
Start your VMs and make sure they are in the same network. Mount a hard drive at `/data` on the main instance. It will be available at `/data` on all instances later.

## Connect new instances
After creating the instances on OpenStack, they can be provisioned by ansible. Create a ssh key pair by `ssh-keygen -t ed25519` and save them in your local copy of this repository at `ansible/ansible_ed25519` and `ansible/ansible_ed25519.pub`. The public key must be added to the authorized_keys file of each instance. Add the ip address of each instance to the correct group in the `ansible/hosts` file.

## Prepare your ansible docker container
Create your container by running:
`docker run -it -d --name ansible-cont -e ANSIBLE_CONFIG=/data/ansible/ansible.cfg -v PATH_TO_THIS_REPOSITORY:/data cytopia/ansible:2.9`

Install the neccessry collections:
`docker exec -e ANSIBLE_CONFIG=/data/ansible/ansible.cfg ansible-cont ansible-galaxy collection install ansible.posix community.docker`

## Run the playbook
Run `docker start ansible-cont && docker exec -e ANSIBLE_CONFIG=/data/ansible/ansible.cfg ansible-cont ansible-playbook -i ansible/hosts ansible/playbook.yaml && docker stop ansible-cont` to provision all instances. You can add e.g. `-l cpu`to provioson only cpu instances. The `--tags restartSteep` option allows to only restart steep instances without further provisioning. Important: Only if all instances are provisioned, all Steep instances will be restarted.

## Run mongo on main instance
`docker run --rm --log-opt max-size=10m --name mongo -d -p 27017:27017 mongo`

## Test it!
Copy the content of the `data` directory to `/data`. Submit the `example-workflow-cpu.yaml` to the main instance to test a cpu instance. It saves it output at `/data/test_out.txt`. `example-workflow-gpu.yaml` works similar for gpu instances.

`curl -X POST http://<MAIN_IP>:8080/workflows --data-binary @example-workflow-gpu.yaml`

## Files
### Hosts
The `hosts` file in this directory specifies the ip addresses of the instances. There are 3 groups: main, cpu and gpu. The main group shall contain only one member on which the main steep instance runs. The other groups contain the instances which run the computations on cpu or gpu.

Important: Your public key has to be in the authorized_keys file of each instance.

### ansible.cfg
In this file you can specify the ssh username for connecting with the instances.

### auth.yml
In this file you can specify the docker authentification data and the path to the ed25519 key for sshfs mounting. The ssh key is called `ansible_ed25519` and `ansible_ed25519.pub` by default and shall be stored in this directory. You can create a new key by running `ssh-keygen -t ed25519`. This key will be added to all instances as private key, public key, known host and authenticated host. There is no need to distribute them yourself.


