<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PharmacyInventoryLog extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'pharmacy_inventory_item_id',
        'item_name',
        'user_id',
        'performed_by_name',
        'performed_by_role',
        'action',
        'quantity_change',
        'new_quantity',
        'reason',
        'meta',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'quantity_change' => 'integer',
            'new_quantity' => 'integer',
            'meta' => 'array',
            'created_at' => 'datetime',
        ];
    }

    public function item(): BelongsTo
    {
        return $this->belongsTo(PharmacyInventoryItem::class, 'pharmacy_inventory_item_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
