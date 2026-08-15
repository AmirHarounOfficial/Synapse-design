<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AfterHoursRequestResource;
use App\Models\AfterHoursRequest;
use Illuminate\Http\Request;

class AfterHoursController extends Controller
{
    /// GET /api/after-hours-requests — school-scoped list.
    public function index(Request $request)
    {
        $requests = AfterHoursRequest::query()
            ->where('school_id', $request->user()->school_id)
            ->with('requester')
            ->latest()
            ->paginate(50);

        return AfterHoursRequestResource::collection($requests);
    }

    /// POST /api/after-hours-requests {reason, window_start?, window_end?}
    public function store(Request $request)
    {
        $data = $request->validate([
            'reason' => ['required', 'string'],
            'window_start' => ['nullable', 'date'],
            'window_end' => ['nullable', 'date'],
        ]);

        $user = $request->user();

        $afterHoursRequest = AfterHoursRequest::create([
            'school_id' => $user->school_id,
            'requested_by' => $user->id,
            'requester_name' => $user->name,
            'reason' => $data['reason'],
            'status' => 'pending',
            'window_start' => $data['window_start'] ?? null,
            'window_end' => $data['window_end'] ?? null,
        ]);

        return new AfterHoursRequestResource($afterHoursRequest->load('requester'));
    }

    /// POST /api/after-hours-requests/{after_hours_request}/respond {status}
    public function respond(Request $request, AfterHoursRequest $afterHoursRequest)
    {
        abort_if($afterHoursRequest->school_id !== $request->user()->school_id, 404);

        $data = $request->validate([
            'status' => ['required', 'in:approved,denied'],
        ]);

        $afterHoursRequest->update(['status' => $data['status']]);

        return new AfterHoursRequestResource($afterHoursRequest->load('requester'));
    }
}
