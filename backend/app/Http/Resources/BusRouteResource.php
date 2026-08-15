<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BusRouteResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'school_id' => $this->school_id,
            'name' => $this->name,
            'driver_id' => $this->driver_id,
            'bus_number' => $this->bus_number,
            'period' => $this->period,
            'status' => $this->status,
            'events' => BusBoardingEventResource::collection($this->whenLoaded('events')),
        ];
    }
}
