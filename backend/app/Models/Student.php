<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Student extends Model
{
    protected $fillable = [
        'school_id', 'name', 'name_ar', 'grade', 'section', 'emirates_id',
        'date_of_birth', 'gender', 'photo_url', 'blood_type', 'curriculum',
        'medical_summary', 'profile_active',
    ];

    protected function casts(): array
    {
        return [
            'date_of_birth' => 'date',
            'profile_active' => 'boolean',
        ];
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function guardians(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'student_guardian')
            ->withPivot(['relationship', 'is_primary', 'can_pickup'])
            ->withTimestamps();
    }

    public function authorizedPersons(): HasMany
    {
        return $this->hasMany(AuthorizedPerson::class);
    }

    public function allergens(): HasMany
    {
        return $this->hasMany(StudentAllergen::class);
    }

    public function medications(): HasMany
    {
        return $this->hasMany(Medication::class);
    }

    public function clinicVisits(): HasMany
    {
        return $this->hasMany(ClinicVisit::class);
    }
}
