<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PharmacyInventoryItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'name_ar',
        'category',
        'dosage_form',
        'stock_quantity',
        'min_threshold',
        'unit',
        'location',
        'expiry_date',
        'supplier',
        'status',
        'notes',
        'created_by',
        'updated_by',
    ];

    protected function casts(): array
    {
        return [
            'stock_quantity' => 'integer',
            'min_threshold' => 'integer',
            'expiry_date' => 'date',
        ];
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function updater(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    public function logs(): HasMany
    {
        return $this->hasMany(PharmacyInventoryLog::class, 'pharmacy_inventory_item_id')->latest('created_at');
    }
}
