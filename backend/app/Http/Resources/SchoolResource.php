<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SchoolResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'name_ar' => $this->name_ar,
            'emirate' => $this->emirate,
            'curriculum' => $this->curriculum,
            'license_authority' => $this->license_authority,
            'code' => $this->code,
            'address' => $this->address,
            'phone' => $this->phone,
            'logo_url' => $this->logo_url,
            'ramadan_mode' => $this->ramadan_mode,
        ];
    }
}
