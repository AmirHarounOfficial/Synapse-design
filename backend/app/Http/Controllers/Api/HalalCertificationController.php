<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\HalalCertificationResource;
use App\Models\HalalCertification;
use Illuminate\Http\Request;

class HalalCertificationController extends Controller
{
    /// GET /api/halal-certifications?school_id=
    public function index(Request $request)
    {
        $query = HalalCertification::query();

        if ($request->filled('school_id')) {
            $query->where('school_id', $request->integer('school_id'));
        }

        return HalalCertificationResource::collection($query->orderBy('expiry_date')->paginate(50));
    }

    public function show(HalalCertification $halalCertification)
    {
        return new HalalCertificationResource($halalCertification);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'school_id' => ['required', 'exists:schools,id'],
            'supplier' => ['required', 'string'],
            'certificate_no' => ['required', 'string'],
            'issued_date' => ['required', 'date'],
            'expiry_date' => ['required', 'date'],
            'status' => ['nullable', 'string', 'in:valid,expiring,expired'],
        ]);

        return new HalalCertificationResource(HalalCertification::create($data));
    }

    public function update(Request $request, HalalCertification $halalCertification)
    {
        $data = $request->validate([
            'supplier' => ['sometimes', 'string'],
            'certificate_no' => ['sometimes', 'string'],
            'issued_date' => ['sometimes', 'date'],
            'expiry_date' => ['sometimes', 'date'],
            'status' => ['nullable', 'string', 'in:valid,expiring,expired'],
        ]);

        $halalCertification->update($data);

        return new HalalCertificationResource($halalCertification);
    }
}
