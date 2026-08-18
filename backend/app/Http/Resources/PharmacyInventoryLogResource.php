<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PharmacyInventoryLogResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'pharmacy_inventory_item_id' => $this->pharmacy_inventory_item_id,
            'item_name' => $this->item_name,
            'user_id' => $this->user_id,
            'performed_by_name' => $this->performed_by_name,
            'performed_by_role' => $this->performed_by_role,
            'action' => $this->action,
            'quantity_change' => $this->quantity_change,
            'new_quantity' => $this->new_quantity,
            'reason' => $this->reason,
            'meta' => $this->meta,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
