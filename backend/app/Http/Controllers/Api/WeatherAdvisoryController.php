<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\WeatherAdvisoryResource;
use App\Models\WeatherAdvisory;
use Illuminate\Http\Request;

class WeatherAdvisoryController extends Controller
{
    /// GET /api/weather-advisories?active=
    public function index(Request $request)
    {
        $query = WeatherAdvisory::query();

        if ($request->filled('active')) {
            $query->where('active', $request->boolean('active'));
        }

        return WeatherAdvisoryResource::collection($query->latest()->paginate(50));
    }

    public function show(WeatherAdvisory $weatherAdvisory)
    {
        return new WeatherAdvisoryResource($weatherAdvisory);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'school_id' => ['nullable', 'exists:schools,id'],
            'kind' => ['required', 'string'],
            'severity' => ['nullable', 'string'],
            'message' => ['required', 'string'],
            'message_ar' => ['nullable', 'string'],
            'active' => ['boolean'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date'],
        ]);

        return new WeatherAdvisoryResource(WeatherAdvisory::create($data));
    }

    public function update(Request $request, WeatherAdvisory $weatherAdvisory)
    {
        $data = $request->validate([
            'school_id' => ['nullable', 'exists:schools,id'],
            'kind' => ['sometimes', 'string'],
            'severity' => ['nullable', 'string'],
            'message' => ['sometimes', 'string'],
            'message_ar' => ['nullable', 'string'],
            'active' => ['boolean'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date'],
        ]);

        $weatherAdvisory->update($data);

        return new WeatherAdvisoryResource($weatherAdvisory);
    }

    public function destroy(WeatherAdvisory $weatherAdvisory)
    {
        $weatherAdvisory->delete();

        return response()->noContent();
    }
}
