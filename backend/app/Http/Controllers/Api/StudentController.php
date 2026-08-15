<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\StudentResource;
use App\Models\Student;
use Illuminate\Http\Request;

class StudentController extends Controller
{
    /// GET /api/students?grade=&q=&school_id=
    public function index(Request $request)
    {
        $query = Student::query()->with('allergens');

        if ($request->filled('school_id')) {
            $query->where('school_id', $request->integer('school_id'));
        }
        if ($request->filled('grade')) {
            $query->where('grade', $request->string('grade'));
        }
        if ($request->filled('q')) {
            $q = $request->string('q');
            $query->where(fn ($w) => $w
                ->where('name', 'like', "%{$q}%")
                ->orWhere('name_ar', 'like', "%{$q}%")
                ->orWhere('emirates_id', 'like', "%{$q}%"));
        }

        return StudentResource::collection($query->orderBy('name')->paginate(50));
    }

    public function show(Student $student)
    {
        return new StudentResource($student->load(['allergens', 'guardians', 'authorizedPersons']));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'school_id' => ['required', 'exists:schools,id'],
            'name' => ['required', 'string'],
            'name_ar' => ['nullable', 'string'],
            'grade' => ['nullable', 'string'],
            'section' => ['nullable', 'string'],
            'emirates_id' => ['nullable', 'string', 'unique:students,emirates_id'],
            'date_of_birth' => ['nullable', 'date'],
            'gender' => ['nullable', 'string'],
            'blood_type' => ['nullable', 'string'],
            'curriculum' => ['nullable', 'string'],
            'medical_summary' => ['nullable', 'string'],
        ]);

        return new StudentResource(Student::create($data));
    }

    public function update(Request $request, Student $student)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string'],
            'name_ar' => ['nullable', 'string'],
            'grade' => ['nullable', 'string'],
            'section' => ['nullable', 'string'],
            'date_of_birth' => ['nullable', 'date'],
            'gender' => ['nullable', 'string'],
            'blood_type' => ['nullable', 'string'],
            'curriculum' => ['nullable', 'string'],
            'medical_summary' => ['nullable', 'string'],
            'profile_active' => ['boolean'],
        ]);

        $student->update($data);

        return new StudentResource($student);
    }

    public function destroy(Student $student)
    {
        $student->delete();

        return response()->noContent();
    }
}
