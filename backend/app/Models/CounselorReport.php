<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CounselorReport extends Model
{
    protected $fillable = [
        'student_id', 'counselor_id', 'type', 'period', 'status',
        'submitted_to_parent', 'generated_at', 'content',
    ];

    protected function casts(): array
    {
        return [
            'content' => 'array',
            'submitted_to_parent' => 'boolean',
            'generated_at' => 'datetime',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function counselor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'counselor_id');
    }
}
