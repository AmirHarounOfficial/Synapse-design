<?php

namespace Database\Seeders;

use App\Models\AppNotification;
use App\Models\AuditLog;
use App\Models\CounselorReport;
use App\Models\CounselorTag;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use App\Models\WeatherAdvisory;
use Illuminate\Database\Seeder;

class CounselorWellbeingSeeder extends Seeder
{
    /**
     * Seed sample wellbeing-system data: a couple counselor tags, one report,
     * a few notifications for the nurse, a couple audit logs, and one active
     * haboob weather advisory. Idempotent.
     */
    public function run(): void
    {
        $school = School::first();
        $counselor = User::where('email', 'counselor@schookeep.ae')->first();
        $nurse = User::where('email', 'nurse@schookeep.ae')->first();
        $principal = User::where('email', 'principal@schookeep.ae')->first();
        $students = Student::orderBy('id')->take(2)->get();

        if ($students->isEmpty()) {
            return;
        }

        // Counselor tags (confidential psychosocial tags).
        $tagSeeds = [
            [$students[0], ['anxiety', 'peer_support'], 'Showing signs of test anxiety; monitoring.', 'academic'],
            [$students->count() > 1 ? $students[1] : $students[0], ['attendance', 'family'], 'Recent attendance dip after family relocation.', 'attendance'],
        ];

        foreach ($tagSeeds as [$student, $tags, $notes, $context]) {
            CounselorTag::updateOrCreate(
                ['student_id' => $student->id, 'context' => $context],
                [
                    'counselor_id' => $counselor?->id,
                    'tags' => $tags,
                    'notes' => $notes,
                    'tagged_at' => now(),
                ],
            );
        }

        // One counselor report.
        CounselorReport::updateOrCreate(
            ['student_id' => $students[0]->id, 'type' => 'wellbeing_summary'],
            [
                'counselor_id' => $counselor?->id,
                'period' => 'Term 2',
                'status' => 'generated',
                'submitted_to_parent' => false,
                'generated_at' => now(),
                'content' => [
                    'summary' => 'Student is engaging well with peer-support sessions.',
                    'recommendations' => ['Continue weekly check-ins', 'Coordinate with class teacher'],
                ],
            ],
        );

        // A few notifications for the nurse user.
        if ($nurse) {
            $notificationSeeds = [
                ['medication_due', 'Medication due', 'Emma Rodriguez has a scheduled dose at 12:30 PM.'],
                ['clinic_visit', 'New clinic visit', 'Marcus Chen checked in with a mild headache.'],
                ['document_review', 'Document pending review', 'A vaccination record is awaiting your review.'],
            ];

            foreach ($notificationSeeds as [$type, $title, $body]) {
                AppNotification::updateOrCreate(
                    ['user_id' => $nurse->id, 'type' => $type, 'title' => $title],
                    [
                        'body' => $body,
                        'data' => ['source' => 'seed'],
                        'read_at' => null,
                    ],
                );
            }
        }

        // A couple of audit logs.
        $auditSeeds = [
            [$principal?->id, 'login', 'User', (string) ($principal?->id ?? '')],
            [$nurse?->id, 'medication.administer', 'DoseAdministration', '1'],
        ];

        foreach ($auditSeeds as [$userId, $action, $entityType, $entityId]) {
            AuditLog::updateOrCreate(
                ['action' => $action, 'entity_type' => $entityType, 'entity_id' => $entityId],
                [
                    'user_id' => $userId,
                    'meta' => ['source' => 'seed'],
                    'ip' => '127.0.0.1',
                    'created_at' => now(),
                ],
            );
        }

        // One active haboob (dust storm) weather advisory — mirrors the Flutter mock.
        WeatherAdvisory::updateOrCreate(
            ['kind' => 'haboob', 'school_id' => $school?->id],
            [
                'severity' => 'warning',
                'message' => 'Haboob dust storm expected this afternoon. Outdoor activities suspended; keep students indoors and windows closed.',
                'message_ar' => 'عاصفة ترابية (هبوب) متوقعة بعد الظهر. تم تعليق الأنشطة الخارجية؛ يرجى إبقاء الطلاب في الداخل وإغلاق النوافذ.',
                'active' => true,
                'starts_at' => now(),
                'ends_at' => now()->addHours(6),
            ],
        );
    }
}
