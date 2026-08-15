<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MedicationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student_id' => $this->student_id,
            'name' => $this->name,
            'name_ar' => $this->name_ar,
            'dosage' => $this->dosage,
            'route' => $this->route,
            'instructions' => $this->instructions,
            'status' => $this->status,
            'prescribed_by' => $this->prescribed_by,
            'requires_physician' => $this->requires_physician,
            'approved_by' => $this->approved_by,
            'approved_at' => $this->approved_at?->toIso8601String(),
            'supply_count' => $this->supply_count,
            'low_supply_threshold' => $this->low_supply_threshold,
            'start_date' => $this->start_date?->toDateString(),
            'end_date' => $this->end_date?->toDateString(),
            'is_halal_sensitive' => $this->is_halal_sensitive,
            'doses' => MedicationDoseResource::collection($this->whenLoaded('doses')),
            'administrations' => DoseAdministrationResource::collection($this->whenLoaded('administrations')),
        ];
    }
}
