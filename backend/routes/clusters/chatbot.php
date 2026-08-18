<?php

use App\Http\Controllers\Api\ChatbotController;
use Illuminate\Support\Facades\Route;

// Auto-included inside auth:sanctum. The staff queue (reads + replies) is
// restricted to front-office/admin roles; starting a chat is open to any
// authenticated user (parents included).

Route::middleware('role:secretary,principal,vice_principal,admin')->group(function () {
    Route::get('chatbot-conversations', [ChatbotController::class, 'index']);
    Route::get('chatbot-conversations/{chatbot_conversation}', [ChatbotController::class, 'show']);
    Route::post('chatbot-conversations/{chatbot_conversation}/messages', [ChatbotController::class, 'storeMessage']);
});

// A parent (any authenticated user) can open a new conversation.
Route::post('chatbot-conversations', [ChatbotController::class, 'store']);

// AI assistant endpoint (OpenRouter Nemotron Nano)
Route::post('chatbot/ask', [ChatbotController::class, 'askAi']);
