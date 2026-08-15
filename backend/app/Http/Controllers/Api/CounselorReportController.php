<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CounselorReportResource;
use App\Models\CounselorReport;
use Illuminate\Http\Request;

class CounselorReportController extends Controller
{
    /// GET /api/counselor-reports?status=&student_id=
    public function index(Request $request)
    {
        $query = CounselorReport::query();

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }
        if ($request->filled('student_id')) {
            $query->where('student_id', $request->integer('student_id'));
        }

        return CounselorReportResource::collection($query->latest()->paginate(50));
    }

    public function show(CounselorReport $counselorReport)
    {
        return new CounselorReportResource($counselorReport);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'student_id' => ['nullable', 'exists:students,id'],
            'type' => ['required', 'string'],
            'period' => ['nullable', 'string'],
            'status' => ['nullable', 'string'],
            'submitted_to_parent' => ['boolean'],
            'generated_at' => ['nullable', 'date'],
            'content' => ['nullable', 'array'],
        ]);

        $data['counselor_id'] = $request->user()->id;

        return new CounselorReportResource(CounselorReport::create($data));
    }

    public function update(Request $request, CounselorReport $counselorReport)
    {
        $data = $request->validate([
            'type' => ['sometimes', 'string'],
            'period' => ['nullable', 'string'],
            'status' => ['nullable', 'string'],
            'submitted_to_parent' => ['boolean'],
            'generated_at' => ['nullable', 'date'],
            'content' => ['nullable', 'array'],
        ]);

        $counselorReport->update($data);

        return new CounselorReportResource($counselorReport);
    }
}
