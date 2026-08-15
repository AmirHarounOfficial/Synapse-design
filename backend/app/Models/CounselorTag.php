<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CounselorTag extends Model
{
    protected $fillable = [
        'student_id', 'counselor_id', 'tags', 'notes', 'context', 'tagged_at',
    ];

    protected function casts(): array
    {
        return [
            'tags' => 'array',
            'tagged_at' => 'datetime',
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
