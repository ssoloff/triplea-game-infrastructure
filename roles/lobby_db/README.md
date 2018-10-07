## Manual Install Steps

The infra automation will create schema and run flyway, the below needs to be run:

```bash
apt update
apt install postgresql postgresql-contrib

sudo -i -u postgres

createuser --interactive  (moderator / n / n / n)
createuser --interactive  (triplea / n / n / n)
createuser --interactive  (flyway / n / y / y)

psql postgres
\password postgres
\password moderator
\password triplea
\password flyway
```
