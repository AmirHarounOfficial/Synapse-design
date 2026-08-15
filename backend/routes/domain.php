<?php

/*
 | Domain route clusters. Each domain cluster registers its routes in its own
 | file under routes/clusters/*.php; they are auto-included here (already inside
 | the `auth:sanctum` group from routes/api.php). This lets clusters be added
 | independently without editing a shared file.
 */

use Illuminate\Support\Facades\Route;

foreach (glob(__DIR__.'/clusters/*.php') as $clusterRoutes) {
    require $clusterRoutes;
}
