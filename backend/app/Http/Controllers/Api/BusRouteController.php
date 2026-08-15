<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\BusBoardingEventResource;
use App\Http\Resources\BusRouteResource;
use App\Models\BusRoute;
use Illuminate\Http\Request;

class BusRouteController extends Controller
{
    /// GET /api/bus-routes?period=&status=
    public function index(Request $request)
    {
        $query = BusRoute::query();

        if ($request->filled('period')) {
            $query->where('period', $request->string('period'));
        }
        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        return BusRouteResource::collection($query->orderBy('name')->paginate(50));
    }

    public function show(BusRoute $busRoute)
    {
        return new BusRouteResource($busRoute->load(['events.student']));
    }

    /// POST /api/bus-routes/{bus_route}/events {student_id, type, status} — driver records boarding/deboarding.
    public function events(Request $request, BusRoute $busRoute)
    {
        $data = $request->validate([
            'student_id' => ['required', 'exists:students,id'],
            'type' => ['required', 'string'], // boarding|deboarding
            'status' => ['required', 'string'], // boarded|deboarded|absent|pending
            'stop_name' => ['nullable', 'string'],
        ]);

        $event = $busRoute->events()->create([
            'student_id' => $data['student_id'],
            'type' => $data['type'],
            'status' => $data['status'],
            'stop_name' => $data['stop_name'] ?? null,
            'occurred_at' => now(),
        ]);

        return new BusBoardingEventResource($event->load('student'));
    }
}
