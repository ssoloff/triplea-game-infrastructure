# Infrastructure


- cron does an update of the deployed infrastructure code by removing the infrastructure folder and creating a 
  new clone.
  

# First time setup

```
MY_HOST=[hostname]
PAPERTRAIL_TOKEN=[paperTrailToken]
curl -s "https://raw.githubusercontent.com/triplea-game/infrastructure/master/setup/first_time_setup.sh" | bash -s $MY_HOST $PAPERTRAIL_TOKEN
```

Create secrets file: `/home/triplea/secrets`
Applications that use database will need additional secrets for DB connectivity, otherwise we just have
the papertrail tokens.


## Verify Setup
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



# Adding SSH Keys

## Generate SSH key:

To generate a key, kindly use ed25519, generates a short and very powerful encryption key:
```
 ssh-keygen -o -a 100 -t ed25519 -C [user]@[machine]
 eg: ssh-keygen -o -a 100 -t ed25519 -C joe@alien-laptop
```

## Add Key
Submit PR and add key to one of:
- super-admin (root user): https://github.com/triplea-game/infrastructure/blob/master/root/files/root_user_authorized_keys
- basic-admin (triplea user): https://github.com/triplea-game/infrastructure/blob/master/root/files/triplea_user_authorized_keys


# Test and Manual Trigger

SSH to the machine and run cron job by hand, to view the cron jobs:
```
crontab -l
```

# Setup & Configuration

After we create a linode server and give it a hostname and cron, we can then manage it by adding an entry
to the infrastructure control file: `system_control.sh`.


## Infrastructure Control File

- Single file that drives infrastructure configuration, maps hostnames to their update instructions
- script will do core setup and install if not yet done
- script will finish by executing 'role' specific install or update; this is done by matching
hostname with a switch statement, the switch statement will have the appropriate update command
configured with parameters.


# Gitter integration

Hosts will send their activity messages to a gitter chat, by watching this we can see message like:

```
bot_california_01 is starting initial install
bot_california_01 is starting initial install
bot_california_01 is installed
bot_california_01 is starting update to 1.9.0.0.1511
bot_california_01 completed update to 1.9.0.0.1511
bot_california_01 is startign...
bot_california_01 has updated [n] maps.

lobby_prerelease is starting update to 1.9.0.0.1511
lobby_prerelease completed update to 1.9.0.0.1511
```

# Overwrite vs write-once
-> all configurations and service files should be overwritten every time
-> binary files that are not expected to change can be write once
