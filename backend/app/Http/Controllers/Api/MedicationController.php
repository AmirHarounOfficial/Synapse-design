<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MedicationResource;
use App\Models\Medication;
use App\Models\Student;
use Illuminate\Http\Request;

class MedicationController extends Controller
{
    /// GET /api/medications?status=&student_id=
    public function index(Request $request)
    {
        $query = Medication::query()->with('doses');

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }
        if ($request->filled('student_id')) {
            $query->where('student_id', $request->integer('student_id'));
        }

        return MedicationResource::collection($query->orderBy('name')->paginate(50));
    }

    /// GET /api/students/{student}/medications
    public function forStudent(Student $student)
    {
        return MedicationResource::collection(
            $student->medications()->with('doses')->orderBy('name')->get()
        );
    }

    public function show(Medication $medication)
    {
        return new MedicationResource($medication->load(['doses', 'administrations']));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'student_id' => ['required', 'exists:students,id'],
            'name' => ['required', 'string'],
            'name_ar' => ['nullable', 'string'],
            'dosage' => ['required', 'string'],
            'route' => ['nullable', 'string'],
            'instructions' => ['nullable', 'string'],
            'status' => ['nullable', 'string'],
            'prescribed_by' => ['nullable', 'string'],
            'requires_physician' => ['boolean'],
            'supply_count' => ['nullable', 'integer'],
            'low_supply_threshold' => ['nullable', 'integer'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date'],
            'is_halal_sensitive' => ['boolean'],
        ]);

        return new MedicationResource(Medication::create($data));
    }

    public function update(Request $request, Medication $medication)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string'],
            'name_ar' => ['nullable', 'string'],
            'dosage' => ['sometimes', 'string'],
            'route' => ['nullable', 'string'],
            'instructions' => ['nullable', 'string'],
            'status' => ['nullable', 'string'],
            'prescribed_by' => ['nullable', 'string'],
            'requires_physician' => ['boolean'],
            'supply_count' => ['nullable', 'integer'],
            'low_supply_threshold' => ['nullable', 'integer'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date'],
            'is_halal_sensitive' => ['boolean'],
        ]);

        $medication->update($data);

        return new MedicationResource($medication);
    }

    public function approve(Request $request, Medication $medication)
    {
        $medication->update([
            'status' => 'approved',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
        ]);

        return new MedicationResource($medication);
    }

    public function decline(Request $request, Medication $medication)
    {
        $medication->update([
            'status' => 'declined',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
        ]);

        return new MedicationResource($medication);
    }
}
