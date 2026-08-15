<?php

namespace Database\Seeders;

use App\Models\AfterHoursRequest;
use App\Models\EquipmentItem;
use App\Models\School;
use App\Models\SmsTransaction;
use App\Models\SmsWallet;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class AdminUtilitiesSeeder extends Seeder
{
    /**
     * Seed admin-utilities demo data for the seeded school: an SMS wallet with
     * a handful of top-up/debit transactions, a few after-hours access requests
     * with varied statuses, and a clinic equipment checklist with varied states.
     * Idempotent.
     */
    public function run(): void
    {
        $school = School::where('code', 'SCHOOL2026')->first();

        if (! $school) {
            return;
        }

        $today = Carbon::today();

        $principal = User::where('email', 'principal@schookeep.ae')->first();
        $vicePrincipal = User::where('email', 'vice_principal@schookeep.ae')->first();
        $nurse = User::where('email', 'nurse@schookeep.ae')->first();

        // ── SMS wallet ────────────────────────────────────────────────────────
        SmsWallet::firstOrCreate(
            ['school_id' => $school->id],
            ['balance_credits' => 2500],
        );

        $transactions = [
            ['type' => 'topup', 'credits' => 1000, 'description' => 'Wallet top-up of 1000 credits', 'days' => 30],
            ['type' => 'debit', 'credits' => 120, 'description' => 'Emergency alerts broadcast', 'days' => 12],
            ['type' => 'debit', 'credits' => 85, 'description' => 'Routine parent messages', 'days' => 9],
            ['type' => 'topup', 'credits' => 2000, 'description' => 'Wallet top-up of 2000 credits', 'days' => 7],
            ['type' => 'debit', 'credits' => 43, 'description' => 'Pickup reminders', 'days' => 3],
            ['type' => 'debit', 'credits' => 12, 'description' => 'Weather advisory alerts', 'days' => 1],
        ];

        foreach ($transactions as $tx) {
            $at = $today->copy()->subDays($tx['days']);

            SmsTransaction::firstOrCreate(
                [
                    'school_id' => $school->id,
                    'type' => $tx['type'],
                    'description' => $tx['description'],
                ],
                [
                    'credits' => $tx['credits'],
                    'created_at' => $at,
                    'updated_at' => $at,
                ],
            );
        }

        // ── After-hours access requests ───────────────────────────────────────
        $afterHours = [
            [
                'user' => $nurse,
                'reason' => 'Restocking clinic emergency supplies after a late incident.',
                'status' => 'approved',
                'window_start' => $today->copy()->setTime(18, 0),
                'window_end' => $today->copy()->setTime(23, 59),
            ],
            [
                'user' => $vicePrincipal,
                'reason' => 'Weekend facilities inspection ahead of exam week.',
                'status' => 'pending',
                'window_start' => $today->copy()->addDays(2)->setTime(8, 0),
                'window_end' => $today->copy()->addDays(2)->setTime(17, 0),
            ],
            [
                'user' => $nurse,
                'reason' => 'Overnight access requested without documented justification.',
                'status' => 'denied',
                'window_start' => null,
                'window_end' => null,
            ],
        ];

        foreach ($afterHours as $req) {
            if (! $req['user']) {
                continue;
            }

            AfterHoursRequest::firstOrCreate(
                [
                    'school_id' => $school->id,
                    'requested_by' => $req['user']->id,
                    'reason' => $req['reason'],
                ],
                [
                    'requester_name' => $req['user']->name,
                    'status' => $req['status'],
                    'window_start' => $req['window_start'],
                    'window_end' => $req['window_end'],
                ],
            );
        }

        // ── Equipment checklist (clinic supplies) ─────────────────────────────
        $equipment = [
            ['name' => 'AED (Automated External Defibrillator)', 'category' => 'emergency', 'location' => 'Main Clinic', 'status' => 'low', 'days' => 89],
            ['name' => 'First Aid Kit (Main Clinic)', 'category' => 'emergency', 'location' => 'Main Clinic', 'status' => 'ok', 'days' => 24],
            ['name' => 'First Aid Kit (Gymnasium)', 'category' => 'emergency', 'location' => 'Gymnasium', 'status' => 'low', 'days' => 40],
            ['name' => 'EpiPen (Auto-injector)', 'category' => 'emergency', 'location' => 'Main Clinic', 'status' => 'expired', 'days' => 120],
            ['name' => 'Oxygen Tank', 'category' => 'emergency', 'location' => 'Main Clinic', 'status' => 'ok', 'days' => 29],
            ['name' => 'Blood Pressure Monitor', 'category' => 'diagnostic', 'location' => 'Main Clinic', 'status' => 'low', 'days' => 210],
            ['name' => 'Digital Thermometers', 'category' => 'diagnostic', 'location' => 'Main Clinic', 'status' => 'ok', 'days' => 16],
            ['name' => 'Nebulizer', 'category' => 'diagnostic', 'location' => 'Main Clinic', 'status' => 'ok', 'days' => 33],
            ['name' => 'Eye Wash Station', 'category' => 'safety', 'location' => 'Science Lab', 'status' => 'ok', 'days' => 43],
            ['name' => 'Fire Blanket', 'category' => 'safety', 'location' => 'Cafeteria', 'status' => 'missing', 'days' => 60],
        ];

        foreach ($equipment as $item) {
            EquipmentItem::firstOrCreate(
                [
                    'school_id' => $school->id,
                    'name' => $item['name'],
                ],
                [
                    'category' => $item['category'],
                    'location' => $item['location'],
                    'status' => $item['status'],
                    'last_checked_at' => $today->copy()->subDays($item['days']),
                    'checked_by' => $nurse?->id ?? $principal?->id,
                ],
            );
        }
    }
}
