# Info
This repo contains the setup scripts from the paper "A Scalable AI Training Platform for Remote Sensing Data" presented at Agile 2023.

# Setup of the platform

## Structure of this repo

- `/ansible` This directory contains Ansible scripts to install the platform on classic servers or VMs. It is intended for cases where no internal cloud connection is available.
- `/conf` A basic configuration for Steep. It contains a CPU and a GPU training service. Both are based on the public tensorflow images. Thus, they can be used without a custom docker image beeing built.
- `/data` An example script for testing workflow execution
- `check-for-updates.sh` A simple script to restart the platform if the config in this repo changes. Should be executed as a cron job.
- `example-workflow-cpu.yaml` Example workflow that can be submitted to the platform and tests the CPU capability. See section below.
- `example-workflow-gpu.yaml` Example workflow that can be submitted to the platform and tests the GPU capability. See section below.

## Getting started

To try out everything we recommend the installation on classic servers. To do so, follow these steps.

1. Start three servers: A main instance with a large disk for some data, a CPU instance to normal calculations and a GPU instance to AI trainig.
2. Run the ansible script to prepare the instances and install everything. See the readme file in the subdirectory.
3. Submit your first workflow. To do so, copy the content of the `data` directory to `/data` on the main instance. Submit the `example-workflow-cpu.yaml` to the main instance to test a cpu instance. It saves it output at `/data/test_out.txt`. `example-workflow-gpu.yaml` works similar for gpu instances. You can submit a workflow via the UI (available on the main instance at port 8080) or via the command line: `curl -X POST http://<MAIN_IP>:8080/workflows --data-binary @example-workflow-gpu.yaml`

## Becoming a profi
- Read the documentation of Steep: https://steep-wms.github.io/ Here you can learn everything related to the used workflow management system.
- Add custom services. Setup a Gitlab repo, put your Dockerfile in it, specify a `.gitlab-ci.yml` to build your image after changes and generate a deployment key. This key has to be added to the platform. See `ansible/auth.yml` for the docker credentials. The `/my-custom-service-template` directory contains a template for a new service repo. 
- Write fancy workflows with loops etc. See https://steep-wms.github.io/#feeding-results-back-into-the-workflow-cyclesloops for an example.
- Write custom plugins for Steep. They can be placed in the `conf/plugins` directory.
- Enable cloud integration. If you specify OpenStack credentials when starting the main instance, it can launch VMs and destroy them after usage.
