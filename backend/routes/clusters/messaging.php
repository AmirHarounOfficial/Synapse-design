<?php

use App\Http\Controllers\Api\MessageController;
use Illuminate\Support\Facades\Route;

// Messaging domain — reads and sends allowed to all authenticated staff.
Route::get('messages', [MessageController::class, 'index']);
Route::get('messages/{message}', [MessageController::class, 'show']);
Route::post('messages', [MessageController::class, 'store']);
Route::post('messages/{message}/read', [MessageController::class, 'markRead']);
Route::post('messages/{message}/reply', [MessageController::class, 'reply']);
