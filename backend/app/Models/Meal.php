<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Meal extends Model
{
    protected $fillable = [
        'school_id', 'name', 'name_ar', 'date', 'is_halal', 'halal_certified', 'allergens',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'is_halal' => 'boolean',
            'halal_certified' => 'boolean',
            'allergens' => 'array',
        ];
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }
}
