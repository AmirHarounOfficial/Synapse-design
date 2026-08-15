<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\DoseAdministrationResource;
use App\Models\DoseAdministration;
use Illuminate\Http\Request;

class DoseAdministrationController extends Controller
{
    /// GET /api/dose-administrations?date=&student_id=
    public function index(Request $request)
    {
        $query = DoseAdministration::query();

        if ($request->filled('student_id')) {
            $query->where('student_id', $request->integer('student_id'));
        }
        if ($request->filled('date')) {
            $date = $request->string('date');
            $query->where(fn ($w) => $w
                ->whereDate('administered_at', $date)
                ->orWhereDate('scheduled_for', $date));
        }

        return DoseAdministrationResource::collection(
            $query->orderByDesc('administered_at')->paginate(50)
        );
    }

    /// POST /api/dose-administrations — log a dose
    public function store(Request $request)
    {
        $data = $request->validate([
            'medication_id' => ['required', 'exists:medications,id'],
            'student_id' => ['required', 'exists:students,id'],
            'scheduled_for' => ['nullable', 'date'],
            'status' => ['required', 'string'], // given|missed|refused|conflict|pending
            'notes' => ['nullable', 'string'],
        ]);

        $data['administered_by'] = $request->user()->id;
        $data['administered_at'] = now();

        return new DoseAdministrationResource(DoseAdministration::create($data));
    }
}
