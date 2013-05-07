<?php

define("CELERY_ID_PREFIX", "fp_");
define("CELERY_REDIS_KEY", "celery");


/**
 * Queue a task to be run by Celery.
 *
 * @param task Celery task name.
 * @param args (Optional) array of arguments.
 * @param kwargs (Optional) hash of keyword arguments.
 */
function queue_task($task, $args = null, $kwargs = null) {
    // assemble Celery-ready messages

    $body = array(
        "id"   => uniqid(CELERY_ID_PREFIX),
        "task" => $task,
    );

    if (!empty($args)) {
        $body["args"] = $args;
    }

    if (!empty($kwargs)) {
        $body["kwargs"] = $kwargs;
    }

    $envelope = array(
        "content-encoding" => "utf-8",
        "content-type"     => "application/json",
        "body"             => base64_encode(json_encode($body)),
        "properties"       => array(
            "body_encoding" => "base64",
            "delivery_tag"  => uniqid(CELERY_ID_PREFIX),
            "delivery_mode" => 2,
            "delivery_info" => array(
                "exchange"    => CELERY_REDIS_KEY,
                "routing_key" => CELERY_REDIS_KEY,
                "priority"    => 0,
            ),
        ),
    );

    $redis = new Redis();
    $redis->connect(REDIS_HOST);
    $redis->lPush(CELERY_REDIS_KEY, json_encode($envelope));
    $redis->close();
}

?>
