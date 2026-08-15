<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class School extends Model
{
    protected $fillable = [
        'name', 'name_ar', 'emirate', 'curriculum', 'license_authority',
        'code', 'address', 'phone', 'logo_url', 'ramadan_mode',
    ];

    protected function casts(): array
    {
        return ['ramadan_mode' => 'boolean'];
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function students(): HasMany
    {
        return $this->hasMany(Student::class);
    }
}
