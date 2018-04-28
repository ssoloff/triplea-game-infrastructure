set -eu

/root/infrastructure/root/tasks/root_user.sh
/root/infrastructure/root/tasks/triplea_user.sh
/root/infrastructure/root/tasks/admin_user.sh
/root/infrastructure/root/tasks/turn_off_ssh_passwords.sh

/root/infrastructure/root/tasks/firewall.sh
/root/infrastructure/root/tasks/update_system_packages.sh

/root/infrastructure/root/tasks/prometheus_metrics_exporter.sh
/root/infrastructure/root/tasks/papertrail.sh

/root/infrastructure/root/tasks/verify_host.sh
