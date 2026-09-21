<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CafeteriaWallet extends Model
{
    protected $fillable = [
        'student_id',
        'monthly_budget',
        'daily_limit',
        'monthly_spent',
        'today_spent',
        'last_spent_date',
    ];

    protected function casts(): array
    {
        return [
            'monthly_budget' => 'decimal:2',
            'daily_limit' => 'decimal:2',
            'monthly_spent' => 'decimal:2',
            'today_spent' => 'decimal:2',
            'last_spent_date' => 'date',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
