<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EmergencyConsentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student_id' => $this->student_id,
            'clinic_visit_id' => $this->clinic_visit_id,
            'requested_by' => $this->requested_by,
            'parent_id' => $this->parent_id,
            'status' => $this->status,
            'details' => $this->details,
            'responded_at' => $this->responded_at?->toIso8601String(),
        ];
    }
}
