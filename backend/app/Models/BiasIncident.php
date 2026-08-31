<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BiasIncident extends Model
{
    protected $fillable = [
        'student_id',
        'student_name',
        'reporter_id',
        'reporter_role',
        'reporter_name',
        'location',
        'bus_route_number',
        'category',
        'severity',
        'status',
        'description',
        'immediate_action_taken',
        'witnesses',
        'counselor_notes',
        'resolution_plan',
        'resolved_at',
    ];

    protected function casts(): array
    {
        return [
            'resolved_at' => 'datetime',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }
}
