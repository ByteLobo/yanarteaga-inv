<?php
// Router for the local PHP development server. Apache serves public/ in deployment.
$publicPath=__DIR__.'/public';
$uri=urldecode(parse_url($_SERVER['REQUEST_URI'],PHP_URL_PATH)??'/');
if ($uri!=='/' && is_file($publicPath.$uri)) { return false; }
require $publicPath.'/index.php';
