<?php

use App\Http\Controllers\Api\CafeteriaAlertController;
use App\Http\Controllers\Api\HalalCertificationController;
use App\Http\Controllers\Api\MealController;
use Illuminate\Support\Facades\Route;

// Auto-included inside the `auth:sanctum` group (see routes/domain.php).
// Reads allowed for all authenticated staff; writes restricted to cafeteria/nurse.

// Reads
Route::get('meals', [MealController::class, 'index']);
Route::get('meals/{meal}', [MealController::class, 'show']);
Route::get('halal-certifications', [HalalCertificationController::class, 'index']);
Route::get('halal-certifications/{halal_certification}', [HalalCertificationController::class, 'show']);
Route::get('cafeteria-alerts', [CafeteriaAlertController::class, 'index']);
Route::get('cafeteria-alerts/{cafeteria_alert}', [CafeteriaAlertController::class, 'show']);

// Writes
Route::middleware('role:cafeteria,nurse')->group(function () {
    Route::post('meals', [MealController::class, 'store']);
    Route::match(['put', 'patch'], 'meals/{meal}', [MealController::class, 'update']);

    Route::post('halal-certifications', [HalalCertificationController::class, 'store']);
    Route::match(['put', 'patch'], 'halal-certifications/{halal_certification}', [HalalCertificationController::class, 'update']);

    Route::post('cafeteria-alerts', [CafeteriaAlertController::class, 'store']);
    Route::post('cafeteria-alerts/{cafeteria_alert}/acknowledge', [CafeteriaAlertController::class, 'acknowledge']);
});
