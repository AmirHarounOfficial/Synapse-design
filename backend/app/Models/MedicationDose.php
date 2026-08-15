<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MedicationDose extends Model
{
    protected $fillable = [
        'medication_id', 'scheduled_time', 'days_of_week', 'label',
    ];

    protected function casts(): array
    {
        return [
            'days_of_week' => 'array',
            'scheduled_time' => 'datetime:H:i',
        ];
    }

    public function medication(): BelongsTo
    {
        return $this->belongsTo(Medication::class);
    }
}
