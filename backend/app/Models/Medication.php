<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Medication extends Model
{
    protected $fillable = [
        'student_id', 'name', 'name_ar', 'dosage', 'route', 'instructions',
        'status', 'prescribed_by', 'requires_physician', 'approved_by', 'approved_at',
        'supply_count', 'low_supply_threshold', 'start_date', 'end_date', 'is_halal_sensitive',
    ];

    protected function casts(): array
    {
        return [
            'requires_physician' => 'boolean',
            'is_halal_sensitive' => 'boolean',
            'approved_at' => 'datetime',
            'start_date' => 'date',
            'end_date' => 'date',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function approver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function doses(): HasMany
    {
        return $this->hasMany(MedicationDose::class);
    }

    public function administrations(): HasMany
    {
        return $this->hasMany(DoseAdministration::class);
    }
}
