<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MealResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'school_id' => $this->school_id,
            'name' => $this->name,
            'name_ar' => $this->name_ar,
            'date' => $this->date?->toDateString(),
            'is_halal' => $this->is_halal,
            'halal_certified' => $this->halal_certified,
            'allergens' => $this->allergens ?? [],
        ];
    }
}
