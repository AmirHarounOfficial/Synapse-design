<?php

namespace Database\Seeders;

use App\Models\CafeteriaAlert;
use App\Models\HalalCertification;
use App\Models\Meal;
use App\Models\School;
use App\Models\Student;
use App\Models\StudentAllergen;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class CafeteriaSeeder extends Seeder
{
    /**
     * Seed cafeteria demo data for the seeded school: today's meals (mostly
     * halal-certified, one flagged non-halal), halal certifications (one valid,
     * one expiring), cafeteria alerts (incl. a halal issue), and a couple of
     * severe student allergens. Idempotent.
     */
    public function run(): void
    {
        $school = School::where('code', 'SCHOOL2026')->first();

        if (! $school) {
            return;
        }

        $today = Carbon::today();
        $cafeteriaUser = User::where('email', 'cafeteria@schookeep.ae')->first();

        // Today's meals — mix of halal-certified, one non-halal detected.
        $meals = [
            [
                'name' => 'Grilled Chicken & Rice',
                'name_ar' => 'دجاج مشوي مع الأرز',
                'is_halal' => true,
                'halal_certified' => true,
                'allergens' => [],
            ],
            [
                'name' => 'Vegetable Pasta',
                'name_ar' => 'باستا بالخضار',
                'is_halal' => true,
                'halal_certified' => true,
                'allergens' => ['gluten', 'dairy'],
            ],
            [
                'name' => 'Peanut Butter Sandwich',
                'name_ar' => 'شطيرة زبدة الفول السوداني',
                'is_halal' => true,
                'halal_certified' => true,
                'allergens' => ['peanut', 'gluten'],
            ],
            [
                // Mirrors the "non-halal detected" mock.
                'name' => 'Pepperoni Pizza',
                'name_ar' => 'بيتزا بيبروني',
                'is_halal' => false,
                'halal_certified' => false,
                'allergens' => ['gluten', 'dairy'],
            ],
        ];

        foreach ($meals as $meal) {
            Meal::firstOrCreate(
                [
                    'school_id' => $school->id,
                    'name' => $meal['name'],
                    'date' => $today->toDateString(),
                ],
                [
                    'name_ar' => $meal['name_ar'],
                    'is_halal' => $meal['is_halal'],
                    'halal_certified' => $meal['halal_certified'],
                    'allergens' => $meal['allergens'],
                ],
            );
        }

        // Halal certifications — one valid, one expiring soon.
        HalalCertification::firstOrCreate(
            [
                'school_id' => $school->id,
                'certificate_no' => 'HC-2026-0001',
            ],
            [
                'supplier' => 'Emirates Halal Foods LLC',
                'issued_date' => $today->copy()->subMonths(6)->toDateString(),
                'expiry_date' => $today->copy()->addMonths(6)->toDateString(),
                'status' => 'valid',
            ],
        );

        HalalCertification::firstOrCreate(
            [
                'school_id' => $school->id,
                'certificate_no' => 'HC-2026-0002',
            ],
            [
                'supplier' => 'Gulf Catering Services',
                'issued_date' => $today->copy()->subMonths(11)->toDateString(),
                'expiry_date' => $today->copy()->addDays(20)->toDateString(),
                'status' => 'expiring',
            ],
        );

        // Severe allergens for a couple of seeded students (peanut/dairy).
        $emma = Student::where('school_id', $school->id)->where('name', 'Emma Rodriguez')->first();
        $marcus = Student::where('school_id', $school->id)->where('name', 'Marcus Chen')->first();

        if ($emma) {
            StudentAllergen::firstOrCreate(
                ['student_id' => $emma->id, 'allergen' => 'Peanut'],
                ['allergen_ar' => 'الفول السوداني', 'severity' => 'severe', 'notes' => 'Carries EpiPen.'],
            );
        }

        if ($marcus) {
            StudentAllergen::firstOrCreate(
                ['student_id' => $marcus->id, 'allergen' => 'Dairy'],
                ['allergen_ar' => 'منتجات الألبان', 'severity' => 'severe', 'notes' => 'Avoid all dairy.'],
            );
        }

        // Cafeteria alerts — one halal issue, one allergen warning.
        CafeteriaAlert::firstOrCreate(
            [
                'school_id' => $school->id,
                'title' => 'Non-halal item detected',
            ],
            [
                'student_id' => null,
                'created_by' => $cafeteriaUser?->id,
                'message' => 'Pepperoni Pizza on today\'s menu is not halal-certified. Remove from service.',
                'severity' => 'critical',
                'is_halal_issue' => true,
                'acknowledged' => false,
                'created_for_date' => $today->toDateString(),
            ],
        );

        CafeteriaAlert::firstOrCreate(
            [
                'school_id' => $school->id,
                'title' => 'Allergen conflict warning',
            ],
            [
                'student_id' => $emma?->id,
                'created_by' => $cafeteriaUser?->id,
                'message' => 'Peanut Butter Sandwich conflicts with a student peanut allergy.',
                'severity' => 'warning',
                'is_halal_issue' => false,
                'acknowledged' => false,
                'created_for_date' => $today->toDateString(),
            ],
        );
    }
}
