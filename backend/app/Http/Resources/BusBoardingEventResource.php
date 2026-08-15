<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BusBoardingEventResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'bus_route_id' => $this->bus_route_id,
            'student_id' => $this->student_id,
            'type' => $this->type,
            'status' => $this->status,
            'occurred_at' => $this->occurred_at?->toIso8601String(),
            'parent_notified' => $this->parent_notified,
            'stop_name' => $this->stop_name,
            'student' => new StudentResource($this->whenLoaded('student')),
        ];
    }
}
