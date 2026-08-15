<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PickupResource;
use App\Models\AuthorizedPerson;
use App\Models\Pickup;
use Illuminate\Http\Request;

class PickupController extends Controller
{
    /// GET /api/pickups?status=&student_id=
    public function index(Request $request)
    {
        $query = Pickup::query()->with(['student', 'authorizedPerson']);

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }
        if ($request->filled('student_id')) {
            $query->where('student_id', $request->integer('student_id'));
        }

        return PickupResource::collection($query->latest()->paginate(50));
    }

    public function show(Pickup $pickup)
    {
        return new PickupResource($pickup->load(['student', 'authorizedPerson', 'securityGuard']));
    }

    /// POST /api/pickups/scan {qr_token} — security verifies an authorized person.
    public function scan(Request $request)
    {
        $data = $request->validate([
            'qr_token' => ['required', 'string'],
        ]);

        $person = AuthorizedPerson::where('qr_token', $data['qr_token'])
            ->where('is_active', true)
            ->first();

        if ($person === null) {
            return response()->json([
                'message' => 'QR code not recognized or person is inactive.',
                'status' => 'denied',
            ], 404);
        }

        $pickup = Pickup::create([
            'student_id' => $person->student_id,
            'authorized_person_id' => $person->id,
            'security_guard_id' => $request->user()?->id,
            'method' => 'qr',
            'status' => 'verified',
        ]);

        return new PickupResource($pickup->load(['student', 'authorizedPerson']));
    }

    /// POST /api/pickups/{pickup}/release — security releases the student.
    public function release(Request $request, Pickup $pickup)
    {
        $pickup->update([
            'status' => 'released',
            'released_at' => now(),
            'security_guard_id' => $request->user()?->id,
        ]);

        return new PickupResource($pickup->load(['student', 'authorizedPerson']));
    }
}
