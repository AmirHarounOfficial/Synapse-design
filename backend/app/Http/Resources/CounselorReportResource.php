<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CounselorReportResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student_id' => $this->student_id,
            'counselor_id' => $this->counselor_id,
            'type' => $this->type,
            'period' => $this->period,
            'status' => $this->status,
            'submitted_to_parent' => $this->submitted_to_parent,
            'generated_at' => $this->generated_at?->toIso8601String(),
            'content' => $this->content,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
