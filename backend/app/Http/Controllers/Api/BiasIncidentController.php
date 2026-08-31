<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\BiasIncidentResource;
use App\Models\BiasIncident;
use Illuminate\Http\Request;

class BiasIncidentController extends Controller
{
    /**
     * GET /api/bias-incidents?status=&severity=&reporter_role=&student_id=&search=
     */
    public function index(Request $request)
    {
        $query = BiasIncident::query();

        if ($request->filled('status') && $request->string('status') !== 'all') {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('severity')) {
            $query->where('severity', $request->string('severity'));
        }

        if ($request->filled('reporter_role')) {
            $query->where('reporter_role', $request->string('reporter_role'));
        }

        if ($request->filled('student_id')) {
            $query->where('student_id', $request->integer('student_id'));
        }

        if ($request->filled('search')) {
            $search = $request->string('search');
            $query->where(function ($q) use ($search) {
                $q->where('student_name', 'like', "%{$search}%")
                  ->orWhere('reporter_name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        return BiasIncidentResource::collection($query->latest()->paginate(50));
    }

    /**
     * GET /api/bias-incidents/{biasIncident}
     */
    public function show(BiasIncident $biasIncident)
    {
        return new BiasIncidentResource($biasIncident);
    }

    /**
     * POST /api/bias-incidents
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'student_id' => ['required', 'integer'],
            'student_name' => ['required', 'string'],
            'reporter_role' => ['required', 'string', 'in:teacher,bus_driver,counselor'],
            'reporter_name' => ['required', 'string'],
            'location' => ['required', 'string'],
            'bus_route_number' => ['nullable', 'string'],
            'category' => ['required', 'string'],
            'severity' => ['required', 'string'],
            'description' => ['required', 'string'],
            'immediate_action_taken' => ['nullable', 'string'],
            'witnesses' => ['nullable', 'string'],
        ]);

        $user = $request->user();
        if ($user) {
            $validated['reporter_id'] = $user->id;
        }

        $validated['status'] = 'submitted';

        $incident = BiasIncident::create($validated);

        return new BiasIncidentResource($incident);
    }

    /**
     * PATCH/PUT /api/bias-incidents/{biasIncident}/status
     */
    public function updateStatus(Request $request, BiasIncident $biasIncident)
    {
        $validated = $request->validate([
            'status' => ['sometimes', 'string', 'in:submitted,under_review,action_plan_active,resolved'],
            'severity' => ['sometimes', 'string'],
            'counselor_notes' => ['nullable', 'string'],
            'resolution_plan' => ['nullable', 'string'],
        ]);

        if (isset($validated['status']) && $validated['status'] === 'resolved' && !$biasIncident->resolved_at) {
            $validated['resolved_at'] = now();
        }

        $biasIncident->update($validated);

        return new BiasIncidentResource($biasIncident);
    }
}
