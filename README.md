# Cloud-Security---ELK-Stack
Setting up a cloud Monitoring system using elk stack server. 
## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

![alt text](https://github.com/tobuthomas/Cloud-Security---ELK-Stack/blob/main/Diagrams/ELK_Network_Diagram.PNG "ELK Network")

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select portions of the playbook file may be used to install only certain pieces of it, such as Filebeat.

  
#### Playbook 1: pentest.yml
```
---
- name: Config Web VM with Docker
  hosts: webservers
  become: true
  tasks:
  - name: docker.io
    apt:
      force_apt_get: yes
      update_cache: yes
      name: docker.io
      state: present

  - name: Install pip3
    apt:
      force_apt_get: yes
      name: python3-pip
      state: present

  - name: Install Docker python module
    pip:
      name: docker
      state: present

  - name: download and launch a docker web container
    docker_container:
      name: dvwa
      image: cyberxsecurity/dvwa
      state: started
      published_ports: 80:80

  - name: Enable docker service
    systemd:
      name: docker
      enabled: yes
```
 
       
#### Playbook 2: install-elk.yml
```
---
- name: Configure Elk VM with Docker
  hosts: elkservers
  remote_user: elk
  become: true
  tasks:
    # Use apt module
    - name: Install docker.io
      apt:
        update_cache: yes
        force_apt_get: yes
        name: docker.io
        state: present
    
    # Use apt module
    - name: Install python3-pip
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present
      
    # Use pip module (It will default to pip3)
    - name: Install Docker module
      pip:
        name: docker
        state: present
    
    # Use command module
    - name: Increase virtual memory
      command: sysctl -w vm.max_map_count=262144
      
    # Use sysctl module
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: 262144
        state: present
        reload: yes
      
    # Use docker_container module
    - name: download and launch a docker elk container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        # Please list the ports that ELK runs on
        published_ports:
          -  5601:5601
          -  9200:9200
          -  5044:5044
```

#### Playbook 3: filebeat-playbook.yml
```
---
- name: installing and launching filebeat
  hosts: webservers
  become: yes
  tasks:
  
  - name: download filebeat deb
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.0-amd64.deb 
 
  - name: install filebeat deb
    command: dpkg -i filebeat-7.4.0-amd64.deb 
  
  - name: drop in filebeat.yml 
    copy:
      src: /etc/ansible/files/filebeat-config.yml
      dest: /etc/filebeat/filebeat.yml
  
  - name: enable and configure system module
    command: filebeat modules enable system
  
  - name: setup filebeat
    command: filebeat setup
  
  - name: Start filebeat service
    command: service filebeat start
```
#### Playbook 4: metricbeat-playbook.yml
```
---
- name: Install metric beat
  hosts: webservers
  become: true
  tasks:
    
  - name: Download metricbeat
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.4.0-amd64.deb

  
  - name: install metricbeat
    command: dpkg -i metricbeat-7.4.0-amd64.deb

   
  - name: drop in metricbeat config
    copy:
      src: /etc/ansible/files/metricbeat-config.yml
      dest: /etc/metricbeat/metricbeat.yml

    
  - name: enable and configure docker module for metric beat
    command: metricbeat modules enable docker

   
  - name: setup metric beat
    command: metricbeat setup

    
  - name: start metric beat
    command: service metricbeat start
```

This document contains the following details:
- Description of the Topologu
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build


### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly _available_, in addition to restricting _access_ to the network.
- What aspect of security do load balancers protect? 
 _Load balancing improves service availability. The load balancer provides an external IP address accesible through the internet. When it recieves external traffic from the internet into the website, the load balacer methodically distributes the trafic across multiple servers and mitigate DoS attack. The health probe function in the load balancer detects issues with machines, reports them to load balancer, hence the load balancer stops the traffic to faulty machines and manages with available machines._       
- What is the advantage of a jump box?
1. _Improve productivity: Jump box makes it possible for the admin to do his or her work on the two sub-networks without the time-wasting process of logging out and logging back into each privileged area. It provides effective access control._
2. _Improve security: Jump box creates separation between a user’s workstation (which is at high risk of being compromised) and the privileged assets within the network. This separation helps to isolate privileged assets so that they are not directly in contact with potentially compromised workstations. In addition, because of their access to potentially sensitive areas, jump boxes are usually “hardened” in the extreme._

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the _event logs_ and system _metrics._
- What does Filebeat watch for?
_Filebeat monitors the log files or locations that you specify, collects log events, and forwards them either to Elasticsearch or Logstash for indexing._
- What does Metricbeat record?
_Metricbeat is a lightweight shipper that you can install on your servers to periodically collect metrics from the operating system and from services running on the server. Metricbeat takes the metrics and statistics that it collects and ships them to Logstash._

The configuration details of each machine may be found below.

| Name                | Function      | IP Address             | Operating System |
|---------------------|---------------|------------------------|------------------|
| Jumpbox VM: azadmin | Gateway       | 10.0.0.4/168.61.39.143 | Linux            |
| Web-1 VM            | Webserver     | 10.0.0.5               | Linux            |
| Web-2 VM            | Webserver     | 10.0.0.6               | Linux            |
| Web-3 VM            | Webserver     | 10.0.0.8               | Linux            |
| ELK-VM              | ELK Server    | 10.1.0.4/104.42.239.18 | Linux            |
| Load Balancer       | Load Balancer | 52.186.157.42          |         -        |

### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the _Jump box machine: azadmin_ can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:
- _Public Ip Address of workstation, 99.227.72.190_

Machines within the network can only be accessed by Jump Box : azadmin.
- Which machine did you allow to access your ELK VM? What was its IP address?
_ELK VM can be accessed from jump box azadmin (ip address 10.0.0.4) and the workstation (ip address 99.227.72.190)._
A summary of the access policies in place can be found in the table below.

| Name                 | Publicly Accessible | Allowed IP address                     | Port      |
|----------------------|---------------------|----------------------------------------|-----------|
| azadmin (Jumpbox VM) | No                  | 99.227.72.190 (Workstations public IP) | SSH P22   |
| Web-1 VM             | No                  | 10.0.0.4 (azadmin)                     | SSH P22   |
| Web-2 VM             | No                  | 10.0.0.4 (azadmin)                     | SSH P22   |
| Web-3 VM             | No                  | 10.0.0.4 (azadmin)                     | SSH P22   |
| ELK VM               | No                  | 99.227.72.190 (Workstations public IP) | TCP P5601 |
| Load Balancer        | No                  | 99.227.72.190 (Workstations public IP) | HTTP P80  |

### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because...
- What is the main advantage of automating configuration with Ansible?
_Ansible allows us to automate the creation, configuration and management of machines. Instead of manually keeping servers updated, making configurations, moving files, etc., we can use Ansible to automate this for groups of servers from one control machine. Ansible lets us quickly and easily deploy multitier apps. We list the tasks required to be done by writing a playbook, and Ansible will figure out how to get our systems to the state we want them to be in._  
The playbook implements the following tasks:
- _Install Packages: Installs the docker.io and python3-pip apt packages._
_docker.io: The Docker engine, used for running containers._
_python3-pip: Package used to install Python software._
- _Install pip module: Installs docker pip package, which is required by Ansible, for controlling the state of Docker containers_ 
- Other `tasks` that do the following:

	- - Increase virtual memory: Set the `vm.max_map_count` to `262144`

		- This configures the target VM (the machine being configured) to use more memory. The ELK container will not run without this setting.

		    - You will want to use Ansible's `sysctl` module and configure it so that this setting is automatically run if your VM has been restarted.
			- The most common reason that the `ELK` container does not run, is caused by this setting being incorrect.
			- [Ansible sysctl](https://docs.ansible.com/ansible/latest/modules/sysctl_module.html)

	- - published_ports:Configures the container to start with the following port mappings:
			- `5601:5601`
			- `9200:9200`
			- `5044:5044`


	- - state: started
        restart_policy: always Starts the container
- ...

The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

![TODO: Update the path with the name of your screenshot of docker ps output](Images/docker_ps_output.png)

### Target Machines & Beats
This ELK server is configured to monitor the following machines:
- Web1 : 10.0.0.5
- Web2 : 10.0.0.6
- Web3 : 10.0.0.8

We have installed the following Beats on these machines:
- _Filebeat and Metricbeat_

These Beats allow us to collect the following information from each machine:
- _filebeat:collects log events_
- _metricbeat:collect metrics from the operating system and from services running on the server_
### Using the Playbook
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:
- Copy the _install-elk.yml_ file to _/etc/ansible_.
- Update the _/etc/ansible/hosts file_ to include _a group called [elk] and specify the IP address of the elk VM created in Azure._
- Run the playbook, and navigate to http://[your.ELK-VM.External.IP]:5601/app/kibana to check that the installation worked as expected.

### Bonus provide the specific commands the user will need to run to download the playbooks and configurations

1. To download ansible hosts: curl https://gist.githubusercontent.com/jbybsIT/916b4cb2d2dc2365e3c81dab8b118105/raw > /etc/ansible/scripts/files/hosts 
2. To set up Web VMs with docker: curl https://gist.githubusercontent.com/jbybsIT/2cb1cfa9bd64a70aa17e2a88e96d6a5c/raw > /etc/ansible/scripts/files/websetup.yml 
3. To download configuration file for ansible : curl https://gist.githubusercontent.com/jbybsIT/4dee2c4eeb68c5bde2b0114dfb7b2c04/raw > /etc/ansible/scripts/files/ansible.cfg
4. To download Elk playbook for installing ELK to ELK VM: curl https://gist.githubusercontent.com/jbybsIT/27cedb77f48b74ad45eef0850a93fee1/raw > /etc/ansible/scripts/files/install-ELK.yml  
5. To download metricbeat configuration file: curl https://gist.githubusercontent.com/jbybsIT/6d004f7eec0d133ee78fc10752d02a95/raw > /etc/ansible/scripts/files/metricbeat-config.yml 
6. To download filebeat configuration files: curl https://gist.githubusercontent.com/jbybsIT/94286080bc581cb2b6825f3899f959e4/raw > /etc/ansible/scripts/files/filebeat-config.yml
7. To download metricbeat playbook: curl https://gist.githubusercontent.com/jbybsIT/04e66b2bc44881afa55e6c8dbd7cee6c/raw > /etc/ansible/scripts/files/metricbeat_playbook.yml
8. To download filebeat playbook: curl https://gist.githubusercontent.com/jbybsIT/eb031455c278d83f3191a30046ce0a28/raw > /etc/ansible/scripts/files/filebeat_playbook.yml


