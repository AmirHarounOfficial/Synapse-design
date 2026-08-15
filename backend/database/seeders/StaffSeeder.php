<?php

namespace Database\Seeders;

use App\Enums\Role;
use App\Models\RolePermission;
use App\Models\School;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class StaffSeeder extends Seeder
{
    /**
     * Seed extra staff users for the demo school so the staff directory has
     * volume, plus a sensible default role_permissions matrix. Idempotent.
     */
    public function run(): void
    {
        $school = School::orderBy('id')->first();
        if (! $school) {
            return;
        }

        // (a) Extra staff so the staff list has volume.
        $extraStaff = [
            [Role::Teacher, 'Michael Rodriguez', 'michael.rodriguez@schookeep.ae', 'Grade 5 Teacher'],
            [Role::Teacher, 'Emily Davis', 'emily.davis@schookeep.ae', 'Grade 3 Teacher'],
            [Role::Teacher, 'Daniel Kim', 'daniel.kim@schookeep.ae', 'PE Teacher'],
            [Role::Nurse, 'Aisha Rahman', 'aisha.rahman@schookeep.ae', 'School Nurse'],
            [Role::Secretary, 'Jennifer Williams', 'jennifer.williams@schookeep.ae', 'Front Office'],
        ];

        foreach ($extraStaff as [$role, $name, $email, $title]) {
            User::updateOrCreate(
                ['email' => $email],
                [
                    'name' => $name,
                    'role' => $role->value,
                    'school_id' => $school->id,
                    'title' => $title,
                    'password' => Hash::make('password'),
                    'is_active' => true,
                ],
            );
        }

        // (b) Default permission matrix: capabilities x main roles.
        $capabilities = [
            'view_students',
            'edit_students',
            'view_medications',
            'administer_medication',
            'view_reports',
            'manage_staff',
            'view_analytics',
            'send_messages',
        ];

        // allowed defaults per role (capabilities not listed default to false).
        $defaults = [
            'nurse' => ['view_students', 'view_medications', 'administer_medication', 'view_reports', 'send_messages'],
            'physician' => ['view_students', 'view_medications', 'administer_medication', 'view_reports', 'view_analytics', 'send_messages'],
            'teacher' => ['view_students', 'send_messages'],
            'secretary' => ['view_students', 'edit_students', 'send_messages'],
            'counselor' => ['view_students', 'view_reports', 'send_messages'],
            'principal' => $capabilities, // full access
            'vice_principal' => ['view_students', 'view_reports', 'view_analytics', 'manage_staff', 'send_messages'],
            'admin' => $capabilities, // full access
        ];

        foreach ($defaults as $role => $allowedCaps) {
            foreach ($capabilities as $capability) {
                RolePermission::updateOrCreate(
                    [
                        'school_id' => $school->id,
                        'role' => $role,
                        'capability' => $capability,
                    ],
                    ['allowed' => in_array($capability, $allowedCaps, true)],
                );
            }
        }
    }
}
