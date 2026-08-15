<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MessageResource;
use App\Models\Message;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    /// GET /api/messages?status=&category=
    public function index(Request $request)
    {
        $query = Message::query()
            ->where('school_id', $request->user()->school_id);

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }
        if ($request->filled('category')) {
            $query->where('category', $request->string('category'));
        }

        return MessageResource::collection($query->latest()->paginate(50));
    }

    public function show(Request $request, Message $message)
    {
        abort_if($message->school_id !== $request->user()->school_id, 404);

        return new MessageResource($message->load(['recipient', 'replies']));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'subject' => ['required', 'string'],
            'body' => ['required', 'string'],
            'category' => ['required', 'string'],
            'recipient_id' => ['nullable', 'exists:users,id'],
        ]);

        $user = $request->user();

        $message = Message::create([
            'school_id' => $user->school_id,
            'sender_id' => $user->id,
            'sender_name' => $user->name,
            'recipient_id' => $data['recipient_id'] ?? null,
            'category' => $data['category'],
            'subject' => $data['subject'],
            'body' => $data['body'],
            'status' => 'unread',
        ]);

        return new MessageResource($message);
    }

    public function markRead(Request $request, Message $message)
    {
        abort_if($message->school_id !== $request->user()->school_id, 404);

        $message->update([
            'status' => 'read',
            'read_at' => now(),
        ]);

        return new MessageResource($message);
    }

    public function reply(Request $request, Message $message)
    {
        abort_if($message->school_id !== $request->user()->school_id, 404);

        $data = $request->validate([
            'body' => ['required', 'string'],
        ]);

        $user = $request->user();

        $reply = Message::create([
            'school_id' => $user->school_id,
            'sender_id' => $user->id,
            'sender_name' => $user->name,
            'recipient_id' => $message->sender_id,
            'category' => $message->category,
            'subject' => 'Re: '.$message->subject,
            'body' => $data['body'],
            'status' => 'unread',
            'parent_message_id' => $message->id,
        ]);

        $message->update(['status' => 'replied']);

        return new MessageResource($reply);
    }
}
