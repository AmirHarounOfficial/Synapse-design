<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BusBoardingEvent extends Model
{
    protected $fillable = [
        'bus_route_id', 'student_id', 'type', 'status',
        'occurred_at', 'parent_notified', 'stop_name',
    ];

    protected function casts(): array
    {
        return [
            'occurred_at' => 'datetime',
            'parent_notified' => 'boolean',
        ];
    }

    public function busRoute(): BelongsTo
    {
        return $this->belongsTo(BusRoute::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
