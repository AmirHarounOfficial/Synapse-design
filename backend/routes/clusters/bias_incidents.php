<?php

use App\Http\Controllers\Api\BiasIncidentController;
use Illuminate\Support\Facades\Route;

// Auto-included inside the auth:sanctum group via routes/domain.php.

Route::get('bias-incidents', [BiasIncidentController::class, 'index']);
Route::post('bias-incidents', [BiasIncidentController::class, 'store']);
Route::get('bias-incidents/{biasIncident}', [BiasIncidentController::class, 'show']);
Route::match(['put', 'patch'], 'bias-incidents/{biasIncident}/status', [BiasIncidentController::class, 'updateStatus']);
