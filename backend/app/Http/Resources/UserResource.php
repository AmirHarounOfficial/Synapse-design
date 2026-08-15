<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'name_ar' => $this->name_ar,
            'email' => $this->email,
            'role' => $this->role?->value,
            'school_id' => $this->school_id,
            'phone' => $this->phone,
            'title' => $this->title,
            'avatar_url' => $this->avatar_url,
            'license_number' => $this->license_number,
            'license_authority' => $this->license_authority,
            'license_expiry' => $this->license_expiry?->toDateString(),
            'is_active' => $this->is_active,
            'locale' => $this->locale,
            'school' => new SchoolResource($this->whenLoaded('school')),
        ];
    }
}
