<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BiasIncidentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student_id' => $this->student_id,
            'student_name' => $this->student_name,
            'reporter_id' => $this->reporter_id,
            'reporter_role' => $this->reporter_role,
            'reporter_name' => $this->reporter_name,
            'location' => $this->location,
            'bus_route_number' => $this->bus_route_number,
            'category' => $this->category,
            'severity' => $this->severity,
            'status' => $this->status,
            'description' => $this->description,
            'immediate_action_taken' => $this->immediate_action_taken,
            'witnesses' => $this->witnesses,
            'counselor_notes' => $this->counselor_notes,
            'resolution_plan' => $this->resolution_plan,
            'resolved_at' => $this->resolved_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
