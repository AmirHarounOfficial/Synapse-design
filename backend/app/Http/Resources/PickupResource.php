<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PickupResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student_id' => $this->student_id,
            'authorized_person_id' => $this->authorized_person_id,
            'security_guard_id' => $this->security_guard_id,
            'method' => $this->method,
            'status' => $this->status,
            'released_at' => $this->released_at?->toIso8601String(),
            'notes' => $this->notes,
            'student' => new StudentResource($this->whenLoaded('student')),
            'authorized_person' => $this->whenLoaded('authorizedPerson', fn () => [
                'id' => $this->authorizedPerson->id,
                'name' => $this->authorizedPerson->name,
                'relationship' => $this->authorizedPerson->relationship,
                'phone' => $this->authorizedPerson->phone,
                'photo_url' => $this->authorizedPerson->photo_url,
                'qr_token' => $this->authorizedPerson->qr_token,
                'is_active' => $this->authorizedPerson->is_active,
            ]),
        ];
    }
}
