<?php

use App\Http\Controllers\Api\StudentController;
use Illuminate\Support\Facades\Route;

// Reads allowed for all authenticated staff; writes restricted to admin roles.
Route::get('students', [StudentController::class, 'index']);
Route::get('students/{student}', [StudentController::class, 'show']);

Route::middleware('role:secretary,principal,vice_principal,admin')->group(function () {
    Route::post('students', [StudentController::class, 'store']);
    Route::match(['put', 'patch'], 'students/{student}', [StudentController::class, 'update']);
    Route::delete('students/{student}', [StudentController::class, 'destroy']);
});
