<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PharmacyInventoryItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'name_ar' => $this->name_ar,
            'category' => $this->category,
            'dosage_form' => $this->dosage_form,
            'stock_quantity' => $this->stock_quantity,
            'min_threshold' => $this->min_threshold,
            'unit' => $this->unit,
            'location' => $this->location,
            'expiry_date' => $this->expiry_date?->format('Y-m-d'),
            'supplier' => $this->supplier,
            'status' => $this->status,
            'notes' => $this->notes,
            'created_by' => $this->created_by,
            'updated_by' => $this->updated_by,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
            'logs' => PharmacyInventoryLogResource::collection($this->whenLoaded('logs')),
        ];
    }
}
