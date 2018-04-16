# Infrastructure

- when testing, run `crontab -l`, run the command manually. Check `journalctl -f` and logs in `/root/logs/*`
 
 
- cron does an update of the deployed infrastructure code by removing the infrastructure folder and creating a 
  new clone.
  

***TODO***: be sure to update cron job schedule on each iteration 
if we can so we can change it

***TODO***: good checks that secret file is present


# First time setup

```
bash <(curl -s "https://raw.githubusercontent.com/triplea-game/infrastructure/master/setup/first_time_setup.sh")
```

Wait for cronjob to kick in, then run `./infrastructure/setup/set_host_name.sh <hostName>`


Verify setup:
* should notice an 'infrastructure' folder: `ls /root/`
* `crontab -l` should have a cron installed

Then set hostname:
```
/root/infrastructure/set_host_name.sh {hostname}
```

Verify:
* `/etc/hostname` should contain the new name
* `/etc/hosts` file should look like this:
```
127.0.0.1       localhost BotServer_NJ_70
```

Use `crontab -e` to dial back the cronjob from once every minute to once every 5.

***TODO***: cronjob should be re-installed automatically by our update job, so would be no need to update 
it to corrected schedule.


# Adding SSH Keys
## Generate SSH key:


To generate a key, kindly use ed25519, generates a short and very powerful encryption key:
```
 ssh-keygen -o -a 100 -t ed25519 -C [user]@[machine]
 eg: ssh-keygen -o -a 100 -t ed25519 -C joe@alien-laptop
```

Public keys are copied to one of:
- super-admin (root user): https://github.com/triplea-game/infrastructure/blob/master/root/files/root_user_authorized_keys
- basic-admin (triplea user): https://github.com/triplea-game/infrastructure/blob/master/root/files/triplea_user_authorized_keys

To generate a private+public keypair, run:
```
 ssh-keygen -o -a 100 -t ed25519 -C [user]@[machine]
 eg: ssh-keygen -o -a 100 -t ed25519 -C joe@alien-laptop
```


# Test and Manual Trigger
SSH to the machine and run the cron by hand:
```
/root/infrastructure/update_cron.sh
```


# Component (Role) List

- Lobby server
- Lobby database
- Bot server
- Dice server
- https://forums.triplea-game.org


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
