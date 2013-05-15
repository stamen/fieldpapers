Upgrading
=========

1.0 - 2.0.0
---------

Install new dependencies:

```bash
% apt-get update
% apt-get install screen
% apt-get install php5-dev

% pip install celery

% pecl install redis
```

If you're using Ubuntu 10.04:

```bash
% add-apt-repository ppa:chris-lea/redis-server
% apt-get update
% apt-get install redis-server

% pip install requests
% pip install redis
```

If you're using Ubuntu 12.04 (or later):

```bash
% apt-get install redis-server python-redis python-requests
```

Add Redis to the list of registered PHP extensions and use its bundled session
handler:

```bash
% cat <<EOF > /etc/php5/conf.d/20-redis.ini
extension=redis.so
session.save_handler = redis
session.save_path = "tcp://localhost"
EOF
```

Restart Apache:

```bash
% /etc/init.d/apache2 restart
```

Update your git clone:

```bash
% cd /usr/local/fieldpapers
% git fetch origin
% git checkout -b v2.0.0
```

Add `REDIS_HOST` to `site/lib/init.php`:

```php
define('REDIS_HOST', 'localhost');
```

Drop the MySQL `messages` table (optional):

```bash
echo "drop table messages;" | mysql -u root
```

Remove the calls to `poll.py` from `/etc/crontab`:

```bash
% sensible-editor /etc/crontab
```

Add Celery to `upstart`:

```bash
% cp conf/celery.conf /etc/init
% start celery
```

Loosen the restrictions on where user ids are required:

```sql
alter table prints modify column user_id varchar(8);
alter table scans modify column user_id varchar(8);
```

Clean out the `users` table:

```sql
delete users from users left join prints on prints.user_id=users.id left join scans on scans.user_id=users.id where prints.id is null and scans.id is null and users.name is null;
create index users_email on users(email);
```

Feel free to clear out any pending session data (in `/var/lib/php5` by
default), as all new sessions will be stored in Redis.
