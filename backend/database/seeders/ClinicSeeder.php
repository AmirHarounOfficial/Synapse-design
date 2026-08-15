<?php

namespace Database\Seeders;

use App\Models\ClinicVisit;
use App\Models\Document;
use App\Models\EmergencyConsent;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Seeder;

class ClinicSeeder extends Seeder
{
    /**
     * Seed clinic visits, one pending emergency consent, and a few documents
     * for the demo students. Idempotent.
     */
    public function run(): void
    {
        $nurse = User::where('email', 'nurse@schookeep.ae')->first();
        $parent = User::where('email', 'parent@schookeep.ae')->first();

        $students = Student::orderBy('id')->get();
        if ($students->isEmpty()) {
            return;
        }

        $visitData = [
            ['Headache', 'low', false],
            ['Minor injury', 'medium', false],
            ['Fever', 'high', false],
        ];

        foreach ($students as $i => $student) {
            [$reason, $severity, $isEmergency] = $visitData[$i % count($visitData)];

            ClinicVisit::firstOrCreate(
                [
                    'student_id' => $student->id,
                    'reason' => $reason,
                ],
                [
                    'school_id' => $student->school_id,
                    'nurse_id' => $nurse?->id,
                    'severity' => $severity,
                    'is_emergency' => $isEmergency,
                    'visited_at' => now()->subDays($i),
                    'outcome' => 'Returned to class',
                ],
            );
        }

        // One pending emergency consent for the first student.
        $firstStudent = $students->first();
        $emergencyVisit = ClinicVisit::firstOrCreate(
            [
                'student_id' => $firstStudent->id,
                'reason' => 'Allergic reaction',
            ],
            [
                'school_id' => $firstStudent->school_id,
                'nurse_id' => $nurse?->id,
                'severity' => 'critical',
                'is_emergency' => true,
                'visited_at' => now(),
                'outcome' => 'Awaiting parent consent',
            ],
        );

        EmergencyConsent::firstOrCreate(
            [
                'student_id' => $firstStudent->id,
                'clinic_visit_id' => $emergencyVisit->id,
            ],
            [
                'requested_by' => $nurse?->id,
                'parent_id' => $parent?->id,
                'status' => 'pending',
                'details' => 'Consent requested to administer emergency medication for allergic reaction.',
            ],
        );

        // 2-3 documents per first couple of students.
        $docTemplates = [
            ['insurance_card', 'Insurance Card', 'approved', true],
            ['vaccination', 'Vaccination Record', 'pending', false],
            ['medical_report', 'Annual Medical Report', 'pending', false],
        ];

        foreach ($students->take(2) as $student) {
            foreach ($docTemplates as [$type, $title, $status, $hasExpiry]) {
                Document::firstOrCreate(
                    [
                        'student_id' => $student->id,
                        'type' => $type,
                    ],
                    [
                        'title' => $title,
                        'status' => $status,
                        'expiry_date' => $hasExpiry ? now()->addYear()->toDateString() : null,
                        'uploaded_by' => $parent?->id,
                    ],
                );
            }
        }
    }
}
