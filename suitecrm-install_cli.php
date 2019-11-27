<?php

$sapi_type = php_sapi_name();
if (substr($sapi_type, 0, 3) != 'cli') {
    die("CLI only.");
}

if (!is_file('config_si.php')) {
    die("Missing config_si.php");
}

if (!defined('sugarEntry')) {
    define('sugarEntry', true);
    define('SUITE_PHPUNIT_RUNNER', true);
    ini_set('error_log', 'php://stderr');
    $_REQUEST['goto'] = 'SilentInstall';
    $_REQUEST['cli'] = 'true';
    $_SERVER['SERVER_SOFTWARE'] = 'Apache/2.x';
    $_SERVER['HTTP_HOST'] = 'localhost';
    $_SERVER['SERVER_NAME'] = 'localhost';
    $_SERVER['REQUEST_URI'] = '/install.php';
    $_SERVER['SERVER_PORT'] = '80';
    // this will fix warning in modules/Users/Save.php:295 during installation
    $_POST['email_reminder_checked'] = false;
    try {
        ob_start();
        require_once 'install.php';
        ob_end_clean();
    } catch (\Exception $e) {
        echo "\nINSTALLATION FAILED! file: " . $e->getFile() . " - line: " . $e->getLine()
            . "\n" . $e->getMessage()
            . "\n" . str_repeat("-", 120)
            . "\n" . print_r($e->getTrace(), true)
            . "\n" . str_repeat("-", 120)
            . "\n";
    }
}
