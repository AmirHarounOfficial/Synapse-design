<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ChatbotConversationResource;
use App\Models\ChatbotConversation;
use Illuminate\Http\Request;

class ChatbotController extends Controller
{
    /// GET /api/chatbot-conversations?status= — the staff escalations queue.
    public function index(Request $request)
    {
        $query = ChatbotConversation::query()
            ->where('school_id', $request->user()->school_id)
            ->withCount('messages');

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        // Pending first, then newest.
        $query->orderByRaw("CASE WHEN status = 'pending' THEN 0 ELSE 1 END")
            ->orderByDesc('created_at');

        return ChatbotConversationResource::collection($query->paginate(50));
    }

    /// GET /api/chatbot-conversations/{chatbot_conversation} — conversation with its messages.
    public function show(Request $request, ChatbotConversation $chatbotConversation)
    {
        abort_unless($chatbotConversation->school_id === $request->user()->school_id, 404);

        return new ChatbotConversationResource($chatbotConversation->load('messages'));
    }

    /// POST /api/chatbot-conversations/{chatbot_conversation}/messages — staff reply.
    public function storeMessage(Request $request, ChatbotConversation $chatbotConversation)
    {
        abort_unless($chatbotConversation->school_id === $request->user()->school_id, 404);

        $data = $request->validate([
            'body' => ['required', 'string'],
            'sender' => ['sometimes', 'string', 'in:bot,parent,staff'],
        ]);

        $chatbotConversation->messages()->create([
            'sender' => $data['sender'] ?? 'staff',
            'body' => $data['body'],
        ]);

        $chatbotConversation->update([
            'status' => 'assigned',
            'assigned_to' => $request->user()->id,
        ]);

        return new ChatbotConversationResource($chatbotConversation->load('messages'));
    }

    /// POST /api/chatbot-conversations — a parent starts a chat.
    public function store(Request $request)
    {
        $data = $request->validate([
            'subject' => ['required', 'string'],
            'body' => ['required', 'string'],
            'priority' => ['sometimes', 'string', 'in:low,normal,high'],
        ]);

        $user = $request->user();

        $conversation = ChatbotConversation::create([
            'school_id' => $user->school_id,
            'parent_id' => $user->id,
            'parent_name' => $user->name,
            'subject' => $data['subject'],
            'status' => 'pending',
            'priority' => $data['priority'] ?? 'normal',
        ]);

        // Automatic bot greeting, then the parent's first message.
        $conversation->messages()->create([
            'sender' => 'bot',
            'body' => 'Hello! I am the SchooKeep Assistant. How can I help you today?',
        ]);

        $conversation->messages()->create([
            'sender' => 'parent',
            'body' => $data['body'],
        ]);

        return new ChatbotConversationResource($conversation->load('messages'));
    }

    /// POST /api/chatbot/ask — Send a message to Nvidia Nemotron Nano AI assistant via OpenRouter.
    public function askAi(Request $request, \App\Services\OpenRouterService $aiService)
    {
        $data = $request->validate([
            'message' => ['required', 'string'],
            'history' => ['sometimes', 'array'],
            'role' => ['sometimes', 'string'],
            'conversation_id' => ['sometimes', 'nullable', 'string'],
        ]);

        $userMessage = $data['message'];
        $history = $data['history'] ?? [];
        $role = $data['role'] ?? ($request->user()?->role ?? 'parent');

        // Call OpenRouter API with role context
        $aiResponse = $aiService->chat($userMessage, $history, $role);

        // Optionally record in conversation if conversation_id provided and user logged in
        if ($request->user() && !empty($data['conversation_id'])) {
            $conversation = ChatbotConversation::find($data['conversation_id']);
            if ($conversation && $conversation->school_id === $request->user()->school_id) {
                $conversation->messages()->create([
                    'sender' => 'parent',
                    'body' => $userMessage,
                ]);
                $conversation->messages()->create([
                    'sender' => 'bot',
                    'body' => $aiResponse,
                ]);
            }
        }

        return response()->json([
            'success' => true,
            'reply' => $aiResponse,
            'response' => $aiResponse,
            'timestamp' => now()->toIso8601String(),
        ]);
    }
}
