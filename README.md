# Infrastructure

## Overview 

Text based configuration for servers, we check in changes here, servers download this repo every
 5 minutes and run the update script, which will pick up any changes we check in.
 
 Update is divided into two logic pieces, system and host. The system are universal items, all servers
 run this first as part of update. Second is host, this is basically a script that is a switch statement
 with all the server hostnames, each server uses the hostname command to lookup it's name in this script and
 then executes the corresponding steps.


## Notifications

At a high level we have the gitter activity feed which is sending a constant yes/no result when the 
update cronjob kicks in, this is every 5 minutes. Each 



# First time setup

To get a host configured we need:
1. linode server and a hostname for it
1. an entry in the infrastructure control file: `host_control.sh`.
1. one-time install of the update cronjob on the linode
1. reboot of the server so the hostname is updated


## Update host-control

* [host_control.sh](https://github.com/triplea-game/infrastructure/blob/master/roles/host_control.sh)

The script file is a glorified switch statement, each machine executes the file and uses `hostname` to know which
specific instructions to run. File updates that are merged to master will be available to live production on each
machines next update cycle (every 5 minutes)


## Create Server in Linode
- Add a new linode, select plan with best price per megabyte of RAM; this tends to be the 1GB nano instances, $5 per month
- use largest swap disk available (for now.. helps avoid OS reaper process which can kill the bot when 
system runs low and near out of memory)
- ubuntu OS 17 or better

'boot' the linode, should be in a running state.

## Prepare install script

Prepare the following script somewhere locally:
```
MY_HOST=[hostname]
PAPERTRAIL_TOKEN=[paperTrailToken]
curl -s "https://raw.githubusercontent.com/triplea-game/infrastructure/master/setup/first_time_setup.sh" | bash -s $MY_HOST $PAPERTRAIL_TOKEN
```
- replace `[hostname]` with the same host name added to `host_control.sh` in the previous step
- `[paperTrailToken]` is universal and always the same value, it can be grabbed from any running
machine under infrastructure from the file: `/home/triplea/secrets`


## Boot server and run install script

SSH to the server via command line using `root@IP`, use the password specified during setup. Next copy/paste
and run the `curl` script previously prepared. Next, log out, and reboot the server from linode so that the hostname 
update would take effect. You're done : )  

When the update job kicks in after reboot SSH keys will be copied and necessary software will be installed and started.


# The 3 Parts to Infrastructure configuration: the update task, system control and host control

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

***TODO*** make sure we have all logs going to all locations, std error might be missing from one of these log streams


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

