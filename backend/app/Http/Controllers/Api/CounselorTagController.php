<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CounselorTagResource;
use App\Models\CounselorTag;
use Illuminate\Http\Request;

class CounselorTagController extends Controller
{
    /// GET /api/counselor-tags?student_id=
    public function index(Request $request)
    {
        $query = CounselorTag::query();

        if ($request->filled('student_id')) {
            $query->where('student_id', $request->integer('student_id'));
        }

        return CounselorTagResource::collection($query->latest('tagged_at')->paginate(50));
    }

    public function show(CounselorTag $counselorTag)
    {
        return new CounselorTagResource($counselorTag);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'student_id' => ['required', 'exists:students,id'],
            'tags' => ['nullable', 'array'],
            'notes' => ['nullable', 'string'],
            'context' => ['nullable', 'string'],
        ]);

        $data['counselor_id'] = $request->user()->id;
        $data['tagged_at'] = now();

        return new CounselorTagResource(CounselorTag::create($data));
    }
}
