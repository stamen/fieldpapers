Upgrading
=========

1.0 - 2.0.0
---------

Install new dependencies:

```bash
% apt-get update
% apt-get install redis-server screen python-requests

% pip install celery

% pecl install redis
```

Update your git clone:

```bash
% cd /usr/local/fieldpapers
% git fetch origin
% git checkout -b v2.0.0
```

Drop the MySQL `messages` table:

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
