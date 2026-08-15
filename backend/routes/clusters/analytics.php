<?php

use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\StudentPromotionController;
use Illuminate\Support\Facades\Route;

// Auto-included inside auth:sanctum (see routes/domain.php).

// Analytics reads — leadership roles only (admin always passes the gate).
Route::middleware('role:principal,vice_principal,admin')->group(function () {
    Route::get('analytics/overview', [AnalyticsController::class, 'overview']);
    Route::get('analytics/health', [AnalyticsController::class, 'health']);
    Route::get('analytics/clinic-readiness', [AnalyticsController::class, 'clinicReadiness']);
    Route::get('analytics/annual-report', [AnalyticsController::class, 'annualReport']);
});

// Student promotion (write) — principal and admin only.
Route::middleware('role:principal,admin')->group(function () {
    Route::post('students/promote', [StudentPromotionController::class, 'promote']);
});
