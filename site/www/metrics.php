<?php

require_once '../lib/lib.everything.php';

enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);

$context = default_context(false);

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$query = <<<EOQ
SELECT
    COUNT(pages.print_id) AS pages,
    prints.created,
    prints.composed
FROM prints
LEFT JOIN pages ON pages.print_id=prints.id
GROUP BY prints.id
ORDER BY created DESC
EOQ;

$res = $context->db->query($query);

if (PEAR::isError($res)) {
    die_with_code(500, $res->message);
}

$rsp = array();

while ($row = $res->fetchRow(DB_FETCHMODE_ASSOC)) {
    $rsp[] = array(
        "pages"    => (int) $row['pages'],
        "created"  => date("c", strtotime($row['created'])),
        "composed" => date("c", strtotime($row['composed'])),
    );
}

echo json_encode($rsp);

?>
