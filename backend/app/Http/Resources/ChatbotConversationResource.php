<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChatbotConversationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'school_id' => $this->school_id,
            'parent_id' => $this->parent_id,
            'parent_name' => $this->parent_name,
            'subject' => $this->subject,
            'status' => $this->status,
            'priority' => $this->priority,
            'assigned_to' => $this->assigned_to,
            'message_count' => $this->messages_count ?? $this->messages()->count(),
            'first_message' => $this->whenLoaded('messages', fn () => optional($this->messages->first())->body),
            'latest_message' => $this->whenLoaded('messages', fn () => optional($this->messages->last())->body),
            'messages' => ChatbotMessageResource::collection($this->whenLoaded('messages')),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
