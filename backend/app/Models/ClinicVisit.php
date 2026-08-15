<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ClinicVisit extends Model
{
    protected $fillable = [
        'student_id', 'school_id', 'nurse_id', 'reason', 'reason_ar',
        'notes', 'severity', 'is_emergency', 'visited_at', 'outcome', 'photo_url',
    ];

    protected function casts(): array
    {
        return [
            'visited_at' => 'datetime',
            'is_emergency' => 'boolean',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function nurse(): BelongsTo
    {
        return $this->belongsTo(User::class, 'nurse_id');
    }
}
