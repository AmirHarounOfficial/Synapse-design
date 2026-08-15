<?php

use App\Http\Controllers\Api\DoseAdministrationController;
use App\Http\Controllers\Api\MedicationController;
use Illuminate\Support\Facades\Route;

// Auto-included inside the auth:sanctum group. Reads allowed for all authenticated
// staff; physician approval and nurse dose-logging are role-scoped.

Route::get('students/{student}/medications', [MedicationController::class, 'forStudent']);

Route::get('medications', [MedicationController::class, 'index']);
Route::get('medications/{medication}', [MedicationController::class, 'show']);
Route::post('medications', [MedicationController::class, 'store']);
Route::match(['put', 'patch'], 'medications/{medication}', [MedicationController::class, 'update']);

Route::post('medications/{medication}/approve', [MedicationController::class, 'approve'])
    ->middleware('role:physician');
Route::post('medications/{medication}/decline', [MedicationController::class, 'decline'])
    ->middleware('role:physician');

Route::get('dose-administrations', [DoseAdministrationController::class, 'index']);
Route::post('dose-administrations', [DoseAdministrationController::class, 'store'])
    ->middleware('role:nurse');
