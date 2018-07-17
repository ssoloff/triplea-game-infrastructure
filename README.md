# Infrastructure - Overview


## Intent

This project automates and tracks server infrastructure deployment and management. All changes to TripleA infrastructure would be done through this project by modifying the configuration and scripting files. The deployment and updates of servers is then automatic and we have a consistent known state of all servers.


## Goals
 
- Document server ops in code, such as how to deploy a new lobby or bot
- Allow deployments and version upgrades to be automatically executed by updating a single configuration file
- Provide automatic DB upgrades and lobby deployment based on configuration
- Provide history of server configuration and changes
- Save time by automating server deployment and configuration
- Ensure consistent installations and known configurations
- install universal tools like papertrail (particularly with the install of universal tools, such as papertrail (log aggregation) and grafana (metrics)

## Integrations and What Does Infrastructure Do?

One thing to note, we run updates frequently which will install software if needed, or do an incremental update, the end state after execution will match the latest checked in configuration.

At a system level, on every host we will run all of the 'root' tasks, https://github.com/triplea-game/infrastructure/tree/master/root/tasks:
- update system packages
- ensure security configuration
- create users and deploy SSH keys
- add papertrail configuration for log aggregation
- prometheus integration to send metrics

In addition to that, the major installation is done as the concept of a 'role'. Each host is assigned to a set of roles, such as 'bot', or 'lobby', or 'lobby-database'. To see how hosts are mapped to roles, please check [host_control.sh](https://github.com/triplea-game/infrastructure/blob/master/roles/host_control.sh)

Each role has a 'tasks' folder which are installation executables. Each role also may have a 'files' folder that holds configuration files. For the set of roles, see:  https://github.com/triplea-game/infrastructure/tree/master/roles 


## How it Works - Overview 

Text based configuration for servers, we check in changes here, servers download this repo every
 5 minutes and run the update script, which will pick up any changes we check in.
 
 Update is divided into two logic pieces, system and host. The system are universal items, all servers
 run this first as part of update. Second is host, this is basically a script that is a switch statement
 with all the server hostnames, each server uses the hostname command to lookup it's name in this script and
 then executes the corresponding steps.


## Notifications

At a high level we have the gitter activity feed which is sending a constant yes/no result when the 
update cronjob kicks in, this is every 5 minutes. Each 



# Infrastructure - Adding Servers

## How to add a new server

### Prepare the install script in a text editor
Prepare the following three line script somewhere locally in a text editor for easy copy/paste:
```
MY_HOST=[hostname]
PAPERTRAIL_TOKEN=[paperTrailToken]
curl -s "https://raw.githubusercontent.com/triplea-game/infrastructure/master/setup/first_time_setup.sh" | bash -s $MY_HOST $PAPERTRAIL_TOKEN
```

Secret values can be found at `/home/triplea/secrets` on prod servers. The 'hostname' value should 
match the hostname we assigned in linode. (note: papertrail token is same on all hosts)

### Run through the steps to set up a server and install

- Log in to linode and click 'add a linode':
![00_add_node](https://user-images.githubusercontent.com/12397753/42787447-66370df0-890f-11e8-9378-bf8934a2d598.png)

- Click 'Deploy an image' link for the new server:
![01_deploy_image](https://user-images.githubusercontent.com/12397753/42787410-4340ec44-890f-11e8-8a8c-ee989ea5c755.png)

- Select latest Ubuntu LTS and use the root password from the master shared secrets document:
![02_select_image_and_pass](https://user-images.githubusercontent.com/12397753/42787411-4359ed7a-890f-11e8-8f8c-7b1c8504a6ed.png)

- Next, click boot to fire up the linode
![03_click_boot](https://user-images.githubusercontent.com/12397753/42787412-4374f35e-890f-11e8-8776-04ad5b25011e.png)

- Next, ssh to the newly started server:
![04_ssh_to_server](https://user-images.githubusercontent.com/12397753/42788250-4ec01b68-8913-11e8-89a7-7e00f164ed48.png)

- Now paste the commands from the prepare step to run the installation:
![05_install_contrab](https://user-images.githubusercontent.com/12397753/42787998-e0dc8560-8911-11e8-9c83-afb4355e9c7f.png)

- Next "exit" and reboot the server from linode so that hostname update takes full effect:
![06_reboot](https://user-images.githubusercontent.com/12397753/42787415-43c0905c-890f-11e8-91ea-62c2f5d12629.png)


### Finish-up: Update host-control

* [host_control.sh](https://github.com/triplea-game/infrastructure/blob/master/roles/host_control.sh)

An update is needed in the file to extend the switch statement which specifies which applications
are installed on which hosts. The existing pattern can be followed and new entries for the
new hosts would need to be created.

After all is updated, the update cycle is every 5 minutes, updates should take effect by then.


# Design Overview: The 3 Parts to Infrastructure configuration

## The Update task

The update job is responsible to remove the last cloned* version of infrastructure to a clone a new one. We then
run the update job `update_cron.sh`. This job is largely static, it is responsible for redirecting output to the 
correct locations, and to kick off system and host control.

*cloning: I noticed that github can buffer files for quite some time when doing 'curl' downloads. To ensure we get 
the very latest values a fresh clone is done.


## System Control

This is the initial entry point of update execution and here we install the system level
common components, things like: firewall, apt packages, common triplea user, admin ssh keys



## Host Control

- maps hostnames to their update instructions, basically a glorified switch statement where
each host uses `hostname` to determine which entry to execute.
- this is the file that decides which hosts will have bot software, which will have lobby




# How to Verify 
Things to notice and check:
* 'infrastructure' folder: `ls /root/`
* `crontab -l` should have a cron installed
* `/etc/hostname` should contain the new name
* `/etc/hosts` file should look like this:
```
127.0.0.1       localhost BotServer_NJ_70
```
* papertrail should have the host reporting
* prometheus and grafana should pick up the new host
* update status should be reported to gitter
* `ps -ef | grep java` will typically have some java processes running

## Checking Logs

Logs are sent to papertrail and tee'd to log folder at /root/logs
 

Live stream of logs:
```
journalctl -f
```

copy of logs are in:
```
/root/logs/..../*.log
```

# Users and User Policy

- `triplea` this was previously the goto user for everyone, this is now an 'application-only' user. We run the triplea application as this user, but otherwise do not log in as this user.
- `admin` this is the new goto user for doing anything on the servers. Ideally it is really rare that we need to log in to servers, and when we do there should be a feature request ticket somewhere asking for that use-case to be automated. If the admin account can't do something, please update the infrastructure scripts to grant it, and then perform that action as admin. Do *not* logout and back in as root, fix the infrastructure scripts instead.
- `root` essentially should not be used. Any root level commands should be done via infrastructure scripts. Use this account as a last restort, probably only when some sort of mistake needs to be corrected.

## Adding SSH Keys

### Generate SSH key:

Use the following to generate an ed25519 private+public key pair:

```
 ssh-keygen -t ed25519
```


### Add Key
Submit PR to add key to: https://github.com/triplea-game/infrastructure/blob/master/root/files/admin_user_authorized_keys

After the PR is merged and given 5 minutes for the update to take effect on servers, you can then log in to any server with `ssh admin@<server_ip>`

# Test and Manual Trigger

SSH to the machine and run cron job by hand, to view the cron jobs:
```
crontab -l
```


# Overwrite vs write-once Philosophy
- configuration files are written every time, this way updates will be applied to live server
- binary files that should never change are written once the first time only.

# Database Backups

Backups are done once a day 
[automatically](https://github.com/triplea-game/infrastructure/blob/master/roles/lobby_db/tasks/run_daily_db_backup.sh)

As part of backup we run a `pg_dump` and save the file locally to `/home/admin/db_backups`, and we also 
save a copy of the backup file to the infrastructure server (172.104.27.19)

To allow passwordless copy a ssh key was generated on the lobby server and was added to the [admin authorized keys files](https://github.com/triplea-game/infrastructure/blob/master/root/files/admin_user_authorized_keys)
