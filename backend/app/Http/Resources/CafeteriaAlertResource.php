<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CafeteriaAlertResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'school_id' => $this->school_id,
            'student_id' => $this->student_id,
            'created_by' => $this->created_by,
            'title' => $this->title,
            'message' => $this->message,
            'severity' => $this->severity,
            'is_halal_issue' => $this->is_halal_issue,
            'acknowledged' => $this->acknowledged,
            'created_for_date' => $this->created_for_date?->toDateString(),
        ];
    }
}
