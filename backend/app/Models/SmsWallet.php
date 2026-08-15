<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SmsWallet extends Model
{
    protected $fillable = [
        'school_id', 'balance_credits',
    ];

    protected function casts(): array
    {
        return [
            'balance_credits' => 'integer',
        ];
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }
}
