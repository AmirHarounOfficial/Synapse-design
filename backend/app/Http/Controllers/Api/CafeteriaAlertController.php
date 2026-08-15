<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CafeteriaAlertResource;
use App\Models\CafeteriaAlert;
use Illuminate\Http\Request;

class CafeteriaAlertController extends Controller
{
    /// GET /api/cafeteria-alerts?acknowledged=&student_id=
    public function index(Request $request)
    {
        $query = CafeteriaAlert::query();

        if ($request->filled('acknowledged')) {
            $query->where('acknowledged', $request->boolean('acknowledged'));
        }
        if ($request->filled('student_id')) {
            $query->where('student_id', $request->integer('student_id'));
        }

        return CafeteriaAlertResource::collection($query->latest()->paginate(50));
    }

    public function show(CafeteriaAlert $cafeteriaAlert)
    {
        return new CafeteriaAlertResource($cafeteriaAlert);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'school_id' => ['required', 'exists:schools,id'],
            'student_id' => ['nullable', 'exists:students,id'],
            'title' => ['required', 'string'],
            'message' => ['required', 'string'],
            'severity' => ['nullable', 'string', 'in:info,warning,critical'],
            'is_halal_issue' => ['boolean'],
            'created_for_date' => ['nullable', 'date'],
        ]);

        $data['created_by'] = $request->user()?->id;

        return new CafeteriaAlertResource(CafeteriaAlert::create($data));
    }

    public function acknowledge(CafeteriaAlert $cafeteriaAlert)
    {
        $cafeteriaAlert->update(['acknowledged' => true]);

        return new CafeteriaAlertResource($cafeteriaAlert);
    }
}
