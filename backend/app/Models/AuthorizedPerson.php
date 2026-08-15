<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AuthorizedPerson extends Model
{
    protected $table = 'authorized_persons';

    protected $fillable = [
        'student_id', 'name', 'relationship', 'phone', 'emirates_id',
        'photo_url', 'qr_token', 'is_active',
    ];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
