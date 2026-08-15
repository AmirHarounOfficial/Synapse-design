<?php

namespace Database\Seeders;

use App\Models\DoseAdministration;
use App\Models\Medication;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Seeder;

class MedicationSeeder extends Seeder
{
    /**
     * Seed medications mirroring the Flutter mock: an active stimulant, an active
     * inhaler, and a pending controlled medication awaiting physician approval.
     * Each gets a dose schedule row and a couple of administration logs.
     */
    public function run(): void
    {
        $student = Student::query()->orderBy('id')->first();

        if (! $student) {
            return;
        }

        $nurse = User::where('role', 'nurse')->first();

        $meds = [
            [
                'name' => 'Adderall XR 10mg',
                'dosage' => '10mg',
                'route' => 'oral',
                'instructions' => 'Take once in the morning with breakfast.',
                'status' => 'active',
                'prescribed_by' => 'Dr. Jennifer Chen',
                'requires_physician' => true,
                'supply_count' => 28,
                'low_supply_threshold' => 7,
                'is_halal_sensitive' => false,
                'dose' => ['scheduled_time' => '08:00', 'days_of_week' => ['mon', 'tue', 'wed', 'thu', 'fri'], 'label' => 'Morning'],
            ],
            [
                'name' => 'Albuterol Inhaler',
                'dosage' => '90mcg',
                'route' => 'inhalation',
                'instructions' => 'Two puffs as needed for shortness of breath.',
                'status' => 'active',
                'prescribed_by' => 'Dr. Jennifer Chen',
                'requires_physician' => false,
                'supply_count' => 200,
                'low_supply_threshold' => 20,
                'is_halal_sensitive' => false,
                'dose' => ['scheduled_time' => '12:00', 'days_of_week' => ['mon', 'tue', 'wed', 'thu', 'fri'], 'label' => 'Midday / PRN'],
            ],
            [
                'name' => 'Ritalin 5mg',
                'dosage' => '5mg',
                'route' => 'oral',
                'instructions' => 'Pending physician review before administration.',
                'status' => 'pending',
                'prescribed_by' => 'Dr. Jennifer Chen',
                'requires_physician' => true,
                'supply_count' => 30,
                'low_supply_threshold' => 7,
                'is_halal_sensitive' => true,
                'dose' => ['scheduled_time' => '13:00', 'days_of_week' => ['mon', 'wed', 'fri'], 'label' => 'Afternoon'],
            ],
        ];

        foreach ($meds as $spec) {
            $dose = $spec['dose'];
            unset($spec['dose']);

            $medication = Medication::firstOrCreate(
                ['student_id' => $student->id, 'name' => $spec['name']],
                $spec,
            );

            $medication->doses()->firstOrCreate(
                ['scheduled_time' => $dose['scheduled_time']],
                ['days_of_week' => $dose['days_of_week'], 'label' => $dose['label']],
            );
        }

        // A couple of dose administration logs for the active stimulant.
        $adderall = Medication::where('student_id', $student->id)
            ->where('name', 'Adderall XR 10mg')
            ->first();

        if ($adderall) {
            DoseAdministration::firstOrCreate(
                [
                    'medication_id' => $adderall->id,
                    'student_id' => $student->id,
                    'scheduled_for' => now()->subDay()->setTime(8, 0),
                ],
                [
                    'administered_by' => $nurse?->id,
                    'administered_at' => now()->subDay()->setTime(8, 5),
                    'status' => 'given',
                    'notes' => 'Taken with breakfast, no issues.',
                ],
            );

            DoseAdministration::firstOrCreate(
                [
                    'medication_id' => $adderall->id,
                    'student_id' => $student->id,
                    'scheduled_for' => now()->setTime(8, 0),
                ],
                [
                    'administered_by' => $nurse?->id,
                    'administered_at' => now()->setTime(8, 2),
                    'status' => 'given',
                    'notes' => 'Administered as scheduled.',
                ],
            );
        }
    }
}
