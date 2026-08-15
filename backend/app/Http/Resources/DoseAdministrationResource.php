<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DoseAdministrationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'medication_id' => $this->medication_id,
            'student_id' => $this->student_id,
            'administered_by' => $this->administered_by,
            'scheduled_for' => $this->scheduled_for?->toIso8601String(),
            'administered_at' => $this->administered_at?->toIso8601String(),
            'status' => $this->status,
            'notes' => $this->notes,
        ];
    }
}
