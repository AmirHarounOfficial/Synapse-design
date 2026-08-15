<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudentAllergen extends Model
{
    protected $fillable = ['student_id', 'allergen', 'allergen_ar', 'severity', 'notes'];

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }
}
