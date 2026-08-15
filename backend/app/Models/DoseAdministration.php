<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DoseAdministration extends Model
{
    protected $fillable = [
        'medication_id', 'student_id', 'administered_by',
        'scheduled_for', 'administered_at', 'status', 'notes',
    ];

    protected function casts(): array
    {
        return [
            'scheduled_for' => 'datetime',
            'administered_at' => 'datetime',
        ];
    }

    public function medication(): BelongsTo
    {
        return $this->belongsTo(Medication::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function administeredBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'administered_by');
    }
}
