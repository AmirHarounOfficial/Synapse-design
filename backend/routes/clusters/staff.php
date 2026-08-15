<?php

use App\Http\Controllers\Api\PermissionController;
use App\Http\Controllers\Api\StaffController;
use Illuminate\Support\Facades\Route;

// Reads allowed to principal, vice_principal, admin; writes to principal, admin.
Route::middleware('role:principal,vice_principal,admin')->group(function () {
    Route::get('staff', [StaffController::class, 'index']);
    Route::get('staff/{user}', [StaffController::class, 'show']);
    Route::get('permissions', [PermissionController::class, 'index']);
});

Route::middleware('role:principal,admin')->group(function () {
    Route::post('staff', [StaffController::class, 'store']);
    Route::match(['put', 'patch'], 'staff/{user}', [StaffController::class, 'update']);
    Route::post('staff/{user}/deactivate', [StaffController::class, 'deactivate']);
    Route::put('permissions', [PermissionController::class, 'update']);
});
