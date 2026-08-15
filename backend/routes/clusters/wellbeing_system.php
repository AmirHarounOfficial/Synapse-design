<?php

use App\Http\Controllers\Api\AuditLogController;
use App\Http\Controllers\Api\CounselorReportController;
use App\Http\Controllers\Api\CounselorTagController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\WeatherAdvisoryController;
use Illuminate\Support\Facades\Route;

// Auto-included inside the auth:sanctum group (see routes/domain.php).

// ── Counselor (confidential — counselor only) ────────────────────────────────
Route::middleware('role:counselor')->group(function () {
    Route::get('counselor-tags', [CounselorTagController::class, 'index']);
    Route::get('counselor-tags/{counselorTag}', [CounselorTagController::class, 'show']);
    Route::post('counselor-tags', [CounselorTagController::class, 'store']);

    Route::get('counselor-reports', [CounselorReportController::class, 'index']);
    Route::get('counselor-reports/{counselorReport}', [CounselorReportController::class, 'show']);
    Route::post('counselor-reports', [CounselorReportController::class, 'store']);
    Route::match(['put', 'patch'], 'counselor-reports/{counselorReport}', [CounselorReportController::class, 'update']);
});

// ── Notifications (any authenticated user; owner-scoped in controller) ────────
Route::get('notifications', [NotificationController::class, 'index']);
Route::post('notifications/{notification}/read', [NotificationController::class, 'read']);

// ── Audit logs (principal / admin only) ──────────────────────────────────────
Route::middleware('role:principal,admin')->group(function () {
    Route::get('audit-logs', [AuditLogController::class, 'index']);
});

// ── Weather advisories (read: all; write: principal) ─────────────────────────
Route::get('weather-advisories', [WeatherAdvisoryController::class, 'index']);
Route::get('weather-advisories/{weatherAdvisory}', [WeatherAdvisoryController::class, 'show']);

Route::middleware('role:principal')->group(function () {
    Route::post('weather-advisories', [WeatherAdvisoryController::class, 'store']);
    Route::match(['put', 'patch'], 'weather-advisories/{weatherAdvisory}', [WeatherAdvisoryController::class, 'update']);
    Route::delete('weather-advisories/{weatherAdvisory}', [WeatherAdvisoryController::class, 'destroy']);
});
