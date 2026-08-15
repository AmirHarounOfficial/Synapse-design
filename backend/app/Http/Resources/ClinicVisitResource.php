<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ClinicVisitResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student_id' => $this->student_id,
            'school_id' => $this->school_id,
            'nurse_id' => $this->nurse_id,
            'reason' => $this->reason,
            'reason_ar' => $this->reason_ar,
            'notes' => $this->notes,
            'severity' => $this->severity,
            'is_emergency' => $this->is_emergency,
            'visited_at' => $this->visited_at?->toIso8601String(),
            'outcome' => $this->outcome,
            'photo_url' => $this->photo_url,
        ];
    }
}
