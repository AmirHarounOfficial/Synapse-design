<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MedicationDoseResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'medication_id' => $this->medication_id,
            'scheduled_time' => $this->scheduled_time?->format('H:i'),
            'days_of_week' => $this->days_of_week,
            'label' => $this->label,
        ];
    }
}
