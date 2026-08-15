<?php

namespace Database\Seeders;

use App\Models\AuthorizedPerson;
use App\Models\BusRoute;
use App\Models\Pickup;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Seeder;

class PickupBusSeeder extends Seeder
{
    /**
     * Seed pickup authorizations, a bus route with boarding events, and a few
     * pending pickups. Idempotent — safe to re-run.
     */
    public function run(): void
    {
        $students = Student::orderBy('id')->get();

        if ($students->isEmpty()) {
            return;
        }

        $school = School::first();
        $driver = User::where('role', 'bus_driver')->first();

        // Give each seeded student a unique authorized person.
        foreach ($students as $student) {
            AuthorizedPerson::updateOrCreate(
                ['qr_token' => 'QR-STU-'.$student->id],
                [
                    'student_id' => $student->id,
                    'name' => $student->name.' (Parent)',
                    'relationship' => 'Parent',
                    'phone' => '+971 50 000 00'.str_pad((string) $student->id, 2, '0', STR_PAD_LEFT),
                    'is_active' => true,
                ],
            );
        }

        // One afternoon bus route with a few boarding events.
        $route = BusRoute::updateOrCreate(
            ['name' => 'Route A — Downtown Loop'],
            [
                'school_id' => $school?->id,
                'driver_id' => $driver?->id,
                'bus_number' => 'BUS-01',
                'period' => 'afternoon',
                'status' => 'scheduled',
            ],
        );

        foreach ($students->take(3) as $i => $student) {
            $route->events()->updateOrCreate(
                ['student_id' => $student->id, 'type' => 'boarding'],
                [
                    'status' => 'boarded',
                    'occurred_at' => now()->subMinutes(30 - ($i * 5)),
                    'parent_notified' => true,
                    'stop_name' => 'Stop '.($i + 1),
                ],
            );
        }

        // A couple of pending pickups.
        foreach ($students->take(2) as $student) {
            $person = AuthorizedPerson::where('qr_token', 'QR-STU-'.$student->id)->first();

            Pickup::firstOrCreate(
                ['student_id' => $student->id, 'status' => 'pending'],
                [
                    'authorized_person_id' => $person?->id,
                    'method' => 'manual',
                ],
            );
        }
    }
}
