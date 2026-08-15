<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WeatherAdvisory extends Model
{
    protected $table = 'weather_advisories';

    protected $fillable = [
        'school_id', 'kind', 'severity', 'message', 'message_ar',
        'active', 'starts_at', 'ends_at',
    ];

    protected function casts(): array
    {
        return [
            'active' => 'boolean',
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
        ];
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }
}
