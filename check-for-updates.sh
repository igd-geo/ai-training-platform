#!/bin/bash
GIT_REPO=/home/ubuntu/ansible/
ANSIBLE_DOCKER_CONTAINER_NAME=ansible-cont
ANSIBLE_DOCKER_IMAGE=cytopia/ansible:2.9
cd $GIT_REPO
git remote update 
# Check if there is an update for the repo on the server
if [ $(git rev-list --count HEAD..@{u}) != 0 ]; then
echo "Repo has updates"
# Check if docker container for ansible is already created
if [ ! $(docker ps -a | grep $ANSIBLE_DOCKER_CONTAINER_NAME) ] 
then
docker run -it -d --name $ANSIBLE_DOCKER_CONTAINER_NAME -e ANSIBLE_CONFIG=/data/ansible/ansible.cfg -v $GIT_REPO:/data $ANSIBLE_DOCKER_IMAGE
docker exec -e ANSIBLE_CONFIG=/data/ansible/ansible.cfg $ANSIBLE_DOCKER_CONTAINER_NAME ansible-galaxy collection install ansible.posix community.docker
fi
# Check if ansible is not running right now
if [ ! "$(docker container ls | grep $ANSIBLE_DOCKER_CONTAINER_NAME)" ]
then 
  # Repository was updated and ansinle is not running
  echo "Ansible is not running. Start it now..."
  # Update repo
  git reset --hard
  git pull
  # Run ansible
  docker start $ANSIBLE_DOCKER_CONTAINER_NAME
  docker exec -e ANSIBLE_CONFIG=/data/ansible/ansible.cfg $ANSIBLE_DOCKER_CONTAINER_NAME ansible-playbook -i ansible/hosts ansible/playbook.yaml
  docker stop $ANSIBLE_DOCKER_CONTAINER_NAME
fi
fi
