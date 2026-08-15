<?php

use App\Http\Controllers\Api\ClinicVisitController;
use App\Http\Controllers\Api\DocumentController;
use App\Http\Controllers\Api\EmergencyConsentController;
use Illuminate\Support\Facades\Route;

// Auto-included inside auth:sanctum. Reads allowed for authenticated staff; writes role-scoped.

// clinic-visits — nurse writes.
Route::get('clinic-visits', [ClinicVisitController::class, 'index']);
Route::get('clinic-visits/{clinic_visit}', [ClinicVisitController::class, 'show']);
Route::middleware('role:nurse')->group(function () {
    Route::post('clinic-visits', [ClinicVisitController::class, 'store']);
    Route::match(['put', 'patch'], 'clinic-visits/{clinic_visit}', [ClinicVisitController::class, 'update']);
});

// emergency-consents — parent responds.
Route::get('emergency-consents', [EmergencyConsentController::class, 'index']);
Route::get('emergency-consents/{emergency_consent}', [EmergencyConsentController::class, 'show']);
Route::post('emergency-consents/{emergency_consent}/respond', [EmergencyConsentController::class, 'respond'])
    ->middleware('role:parent');

// documents — upload open to authenticated staff/parents; review by nurse/physician.
Route::get('documents', [DocumentController::class, 'index']);
Route::get('documents/{document}', [DocumentController::class, 'show']);
Route::post('documents', [DocumentController::class, 'store']);
Route::post('documents/{document}/review', [DocumentController::class, 'review'])
    ->middleware('role:nurse,physician');
