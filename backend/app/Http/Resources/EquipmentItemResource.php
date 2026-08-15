<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EquipmentItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'school_id' => $this->school_id,
            'name' => $this->name,
            'category' => $this->category,
            'location' => $this->location,
            'status' => $this->status,
            'last_checked_at' => $this->last_checked_at?->toIso8601String(),
            'checked_by' => $this->checked_by,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
            'checked_by_user' => $this->whenLoaded('checkedBy', fn () => $this->checkedBy ? [
                'id' => $this->checkedBy->id,
                'name' => $this->checkedBy->name,
                'role' => $this->checkedBy->role,
            ] : null),
        ];
    }
}
