<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StudentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'school_id' => $this->school_id,
            'name' => $this->name,
            'name_ar' => $this->name_ar,
            'grade' => $this->grade,
            'section' => $this->section,
            'emirates_id' => $this->emirates_id,
            'date_of_birth' => $this->date_of_birth?->toDateString(),
            'gender' => $this->gender,
            'photo_url' => $this->photo_url,
            'blood_type' => $this->blood_type,
            'curriculum' => $this->curriculum,
            'medical_summary' => $this->medical_summary,
            'profile_active' => $this->profile_active,
            'allergens' => $this->whenLoaded('allergens', fn () => $this->allergens->map(fn ($a) => [
                'allergen' => $a->allergen,
                'allergen_ar' => $a->allergen_ar,
                'severity' => $a->severity,
                'notes' => $a->notes,
            ])),
        ];
    }
}
