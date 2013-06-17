# Celery Message Format

{
  "content-encoding": "utf-8",
  "properties": {
    "delivery_tag": "4ed58120-315e-4ab4-9b29-6f4a124bb07b",
    "delivery_mode": 2,
    "delivery_info": {
      "exchange": "celery",
      "routing_key": "celery",
      "priority": 0
    },
    "body_encoding": "base64"
  },
  "content-type": "application/json",
  "headers": {},
  "body": "eyJleHBpcmVzIjogbnVsbCwgInV0YyI6IHRydWUsICJhcmdzIjogWyJsaGJyYnR6eiIsICJsZXR0ZXIiLCAibGFuZHNjYXBlIl0sICJjaG9yZCI6IG51bGwsICJjYWxsYmFja3MiOiBudWxsLCAiZXJyYmFja3MiOiBudWxsLCAidGFza3NldCI6IG51bGwsICJpZCI6ICJkNWYxMzE2OC0wZWIyLTQxMjQtOWYzMy04ZTYzYTA4ZmZhM2MiLCAicmV0cmllcyI6IDAsICJ0YXNrIjogInBvbGwuY29tcG9zZVByaW50IiwgImV0YSI6IG51bGwsICJrd2FyZ3MiOiB7fX0="
}

base64-decoded body

{
  "kwargs": {},
  "eta": null,
  "task": "poll.composePrint",
  "retries": 0,
  "expires": null,
  "utc": true,
  "args": [
    "lhbrbtzz",
    "letter",
    "landscape"
  ],
  "chord": null,
  "callbacks": null,
  "errbacks": null,
  "taskset": null,
  "id": "d5f13168-0eb2-4124-9f33-8e63a08ffa3c"
}

id: uniqid("fp_")

configuration option "php_ini" is not set to php.ini location
You should add "extension=redis.so" to php.ini
