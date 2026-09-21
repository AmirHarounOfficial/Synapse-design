<?php

namespace Database\Seeders;

use App\Models\CafeteriaTransaction;
use App\Models\CafeteriaWallet;
use App\Models\Student;
use Illuminate\Database\Seeder;

class CafeteriaWalletSeeder extends Seeder
{
    public function run(): void
    {
        $students = Student::all();

        foreach ($students as $student) {
            $wallet = CafeteriaWallet::updateOrCreate(
                ['student_id' => $student->id],
                [
                    'monthly_budget' => 600.00,
                    'daily_limit' => 30.00,
                    'monthly_spent' => 145.50,
                    'today_spent' => 12.00,
                    'last_spent_date' => now()->toDateString(),
                ]
            );

            // Seed recent transactions
            CafeteriaTransaction::create([
                'student_id' => $student->id,
                'amount' => 12.00,
                'item_name' => 'Grilled Chicken Sandwich & Apple Juice',
                'category' => 'meal',
                'staff_name' => 'Chef Ahmed (Main Cafeteria)',
                'created_at' => now()->subHours(2),
            ]);

            CafeteriaTransaction::create([
                'student_id' => $student->id,
                'amount' => 8.50,
                'item_name' => 'Fresh Fruit Salad & Yogurt',
                'category' => 'snack',
                'staff_name' => 'Chef Ahmed (Main Cafeteria)',
                'created_at' => now()->subDays(1)->setHour(12)->setMinute(15),
            ]);

            CafeteriaTransaction::create([
                'student_id' => $student->id,
                'amount' => 25.00,
                'item_name' => 'Hot Lunch Meal Deal + Water',
                'category' => 'meal',
                'staff_name' => 'Chef Ahmed (Main Cafeteria)',
                'created_at' => now()->subDays(2)->setHour(12)->setMinute(30),
            ]);
        }
    }
}
