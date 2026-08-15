<?php

use App\Http\Controllers\Api\BusRouteController;
use App\Http\Controllers\Api\PickupController;
use Illuminate\Support\Facades\Route;

// Auto-included inside the `auth:sanctum` group (see routes/domain.php).

// ── Pickups ───────────────────────────────────────────────────────────────────
// Register the literal `scan` route before the `{pickup}` wildcard.
Route::middleware('role:security')->group(function () {
    Route::post('pickups/scan', [PickupController::class, 'scan']);
    Route::post('pickups/{pickup}/release', [PickupController::class, 'release']);
});

Route::get('pickups', [PickupController::class, 'index']);
Route::get('pickups/{pickup}', [PickupController::class, 'show']);

// ── Bus routes ──────────────────────────────────────────────────────────────────
Route::get('bus-routes', [BusRouteController::class, 'index']);
Route::get('bus-routes/{bus_route}', [BusRouteController::class, 'show']);

Route::post('bus-routes/{bus_route}/events', [BusRouteController::class, 'events'])
    ->middleware('role:bus_driver');
