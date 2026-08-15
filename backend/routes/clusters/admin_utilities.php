<?php

use App\Http\Controllers\Api\AfterHoursController;
use App\Http\Controllers\Api\EquipmentController;
use App\Http\Controllers\Api\SmsWalletController;
use Illuminate\Support\Facades\Route;

// Admin utilities: SMS wallet, after-hours access, equipment checklist.
// Reads allowed for principal, vice_principal, admin; writes restricted below.

Route::middleware('role:principal,vice_principal,admin')->group(function () {
    // SMS wallet
    Route::get('sms-wallet', [SmsWalletController::class, 'show']);

    // After-hours access
    Route::get('after-hours-requests', [AfterHoursController::class, 'index']);

    // Equipment checklist
    Route::get('equipment-items', [EquipmentController::class, 'index']);
});

// SMS wallet + after-hours writes: principal, admin.
Route::middleware('role:principal,admin')->group(function () {
    Route::post('sms-wallet/topup', [SmsWalletController::class, 'topup']);

    Route::post('after-hours-requests', [AfterHoursController::class, 'store']);
    Route::post('after-hours-requests/{after_hours_request}/respond', [AfterHoursController::class, 'respond']);
});

// Equipment update: vice_principal, principal, admin.
Route::middleware('role:vice_principal,principal,admin')->group(function () {
    Route::match(['put', 'patch'], 'equipment-items/{equipment_item}', [EquipmentController::class, 'update']);
});
