<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MessageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'school_id' => $this->school_id,
            'sender_id' => $this->sender_id,
            'sender_name' => $this->sender_name,
            'recipient_id' => $this->recipient_id,
            'category' => $this->category,
            'subject' => $this->subject,
            'body' => $this->body,
            'status' => $this->status,
            'parent_message_id' => $this->parent_message_id,
            'read_at' => $this->read_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
            'recipient' => $this->whenLoaded('recipient', fn () => $this->recipient ? [
                'id' => $this->recipient->id,
                'name' => $this->recipient->name,
                'role' => $this->recipient->role,
            ] : null),
            'replies' => MessageResource::collection($this->whenLoaded('replies')),
        ];
    }
}
