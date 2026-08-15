<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CafeteriaAlert extends Model
{
    protected $fillable = [
        'school_id', 'student_id', 'created_by', 'title', 'message',
        'severity', 'is_halal_issue', 'acknowledged', 'created_for_date',
    ];

    protected function casts(): array
    {
        return [
            'is_halal_issue' => 'boolean',
            'acknowledged' => 'boolean',
            'created_for_date' => 'date',
        ];
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
