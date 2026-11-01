<?php

namespace Database\Seeders;

use App\Enums\Role;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database with a demo school, one user per role
     * (password: `password`), and sample students. Domain clusters add their
     * own seeders, invoked at the end.
     */
    public function run(): void
    {
        $school = School::firstOrCreate(
            ['code' => 'SCHOOL2026'],
            [
                'name' => 'Al Noor International School',
                'name_ar' => 'مدرسة النور الدولية',
                'region' => 'Riyadh',
                'curriculum' => 'British',
                'license_authority' => 'MOH KSA',
                'phone' => '+966 11 123 4567',
                'ramadan_mode' => false,
            ],
        );

        $roleUsers = [
            [Role::Nurse, 'Sarah Johnson', 'nurse@schookeep.sa'],
            [Role::Parent, 'Ahmed Al Mansoori', 'parent@schookeep.sa'],
            [Role::Teacher, 'Fatima Hassan', 'teacher@schookeep.sa'],
            [Role::Cafeteria, 'Cafeteria Manager', 'cafeteria@schookeep.sa'],
            [Role::Security, 'Security Officer', 'security@schookeep.sa'],
            [Role::BusDriver, 'Bus Driver', 'bus@schookeep.sa'],
            [Role::Counselor, 'Layla Ahmed', 'counselor@schookeep.sa'],
            [Role::Secretary, 'Mariam Saeed', 'secretary@schookeep.sa'],
            [Role::Principal, 'Dr. Khalid Rahman', 'principal@schookeep.sa'],
            [Role::Physician, 'Dr. Jennifer Chen', 'physician@schookeep.sa'],
            [Role::VicePrincipal, 'Omar Abdullah', 'vp@schookeep.sa'],
            [Role::Admin, 'System Admin', 'admin@schookeep.sa'],
        ];

        foreach ($roleUsers as [$role, $name, $email]) {
            User::updateOrCreate(
                ['email' => $email],
                [
                    'name' => $name,
                    'role' => $role->value,
                    'school_id' => $school->id,
                    'password' => Hash::make('password'),
                    'is_active' => true,
                ],
            );
        }

        $students = [
            ['Emma Rodriguez', '5', 'A', 'O+'],
            ['Marcus Chen', '4', 'B', 'A+'],
            ['Sophia Williams', '6', 'A', 'B+'],
            ['James Patterson', '3', 'C', 'AB+'],
            ['Olivia Martinez', '5', 'B', 'O-'],
        ];

        foreach ($students as $i => [$name, $grade, $section, $blood]) {
            Student::updateOrCreate(
                ['national_id' => '1' . str_pad((string)$i, 9, '0', STR_PAD_LEFT)],
                [
                    'school_id' => $school->id,
                    'name' => $name,
                    'grade' => $grade,
                    'section' => $section,
                    'blood_type' => $blood,
                    'profile_active' => true,
                ],
            );
        }

        // Domain cluster seeders (added as clusters are built).
        $this->callClusterSeeders();
    }

    /**
     * Invoke any cluster seeder that exists, without failing if it doesn't.
     */
    private function callClusterSeeders(): void
    {
        foreach ([
            'MedicationSeeder',
            'ClinicSeeder',
            'CafeteriaSeeder',
            'PickupBusSeeder',
            'CounselorWellbeingSeeder',
            'MessagingSeeder',
            'ChatbotSeeder',
            'StaffSeeder',
            'AdminUtilitiesSeeder',
            'PharmacyInventorySeeder',
            'BiasIncidentSeeder',
            'CafeteriaWalletSeeder',
        ] as $seeder) {
            $class = "Database\\Seeders\\{$seeder}";
            if (class_exists($class)) {
                $this->call($class);
            }
        }
    }
}
