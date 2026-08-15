<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\EmergencyConsentResource;
use App\Models\EmergencyConsent;
use Illuminate\Http\Request;

class EmergencyConsentController extends Controller
{
    /// GET /api/emergency-consents?status=&student_id=
    public function index(Request $request)
    {
        $query = EmergencyConsent::query();

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }
        if ($request->filled('student_id')) {
            $query->where('student_id', $request->integer('student_id'));
        }

        return EmergencyConsentResource::collection($query->latest()->paginate(50));
    }

    public function show(EmergencyConsent $emergencyConsent)
    {
        return new EmergencyConsentResource($emergencyConsent);
    }

    /// POST /api/emergency-consents/{emergency_consent}/respond {status: approved|declined}
    public function respond(Request $request, EmergencyConsent $emergencyConsent)
    {
        $data = $request->validate([
            'status' => ['required', 'in:approved,declined'],
        ]);

        $emergencyConsent->update([
            'status' => $data['status'],
            'parent_id' => $request->user()->id,
            'responded_at' => now(),
        ]);

        return new EmergencyConsentResource($emergencyConsent);
    }
}
