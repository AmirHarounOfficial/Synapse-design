<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ClinicVisitResource;
use App\Models\ClinicVisit;
use Illuminate\Http\Request;

class ClinicVisitController extends Controller
{
    /// GET /api/clinic-visits?date=&student_id=
    public function index(Request $request)
    {
        $query = ClinicVisit::query();

        if ($request->filled('student_id')) {
            $query->where('student_id', $request->integer('student_id'));
        }
        if ($request->filled('date')) {
            $query->whereDate('visited_at', $request->string('date'));
        }

        return ClinicVisitResource::collection($query->orderByDesc('visited_at')->paginate(50));
    }

    public function show(ClinicVisit $clinicVisit)
    {
        return new ClinicVisitResource($clinicVisit);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'student_id' => ['required', 'exists:students,id'],
            'school_id' => ['required', 'exists:schools,id'],
            'reason' => ['required', 'string'],
            'reason_ar' => ['nullable', 'string'],
            'notes' => ['nullable', 'string'],
            'severity' => ['nullable', 'string'],
            'is_emergency' => ['boolean'],
            'visited_at' => ['nullable', 'date'],
            'outcome' => ['nullable', 'string'],
            'photo_url' => ['nullable', 'string'],
        ]);

        $data['nurse_id'] = $request->user()->id;
        $data['visited_at'] = $data['visited_at'] ?? now();

        return new ClinicVisitResource(ClinicVisit::create($data));
    }

    public function update(Request $request, ClinicVisit $clinicVisit)
    {
        $data = $request->validate([
            'reason' => ['sometimes', 'string'],
            'reason_ar' => ['nullable', 'string'],
            'notes' => ['nullable', 'string'],
            'severity' => ['nullable', 'string'],
            'is_emergency' => ['boolean'],
            'visited_at' => ['nullable', 'date'],
            'outcome' => ['nullable', 'string'],
            'photo_url' => ['nullable', 'string'],
        ]);

        $clinicVisit->update($data);

        return new ClinicVisitResource($clinicVisit);
    }
}
