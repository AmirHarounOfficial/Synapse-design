<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Pickup extends Model
{
    protected $fillable = [
        'student_id', 'authorized_person_id', 'security_guard_id',
        'method', 'status', 'released_at', 'notes',
    ];

    protected function casts(): array
    {
        return [
            'released_at' => 'datetime',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function authorizedPerson(): BelongsTo
    {
        return $this->belongsTo(AuthorizedPerson::class);
    }

    public function securityGuard(): BelongsTo
    {
        return $this->belongsTo(User::class, 'security_guard_id');
    }
}
