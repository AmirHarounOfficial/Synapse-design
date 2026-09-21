<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CafeteriaTransaction;
use App\Models\CafeteriaWallet;
use App\Models\Student;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class CafeteriaWalletController extends Controller
{
    /**
     * GET /api/cafeteria/wallet/{studentId}
     */
    public function show($studentId)
    {
        $student = Student::findOrFail($studentId);

        $wallet = CafeteriaWallet::firstOrCreate(
            ['student_id' => $student->id],
            [
                'monthly_budget' => 500.00,
                'daily_limit' => 25.00,
                'monthly_spent' => 0.00,
                'today_spent' => 0.00,
                'last_spent_date' => now()->toDateString(),
            ]
        );

        // Reset today_spent if last_spent_date is not today
        $today = now()->toDateString();
        if ($wallet->last_spent_date && $wallet->last_spent_date->toDateString() !== $today) {
            $wallet->today_spent = 0.00;
            $wallet->last_spent_date = $today;
            $wallet->save();
        }

        // Reset monthly_spent if last_spent_date month is not current month
        if ($wallet->updated_at && $wallet->updated_at->month !== now()->month) {
            $wallet->monthly_spent = 0.00;
            $wallet->save();
        }

        $remainingMonthly = max(0, (float) $wallet->monthly_budget - (float) $wallet->monthly_spent);
        $remainingDaily = max(0, min((float) $wallet->daily_limit - (float) $wallet->today_spent, $remainingMonthly));

        return response()->json([
            'data' => [
                'student_id' => $student->id,
                'student_name' => $student->name,
                'monthly_budget' => (float) $wallet->monthly_budget,
                'daily_limit' => (float) $wallet->daily_limit,
                'monthly_spent' => (float) $wallet->monthly_spent,
                'today_spent' => (float) $wallet->today_spent,
                'remaining_monthly' => (float) $remainingMonthly,
                'remaining_daily' => (float) $remainingDaily,
                'last_spent_date' => $wallet->last_spent_date?->toDateString(),
            ]
        ]);
    }

    /**
     * POST /api/cafeteria/wallet/{studentId}
     * Parent sets monthly budget and daily limit
     */
    public function update(Request $request, $studentId)
    {
        $validated = $request->validate([
            'monthly_budget' => ['required', 'numeric', 'min:0'],
            'daily_limit' => ['required', 'numeric', 'min:0'],
        ]);

        $student = Student::findOrFail($studentId);

        $wallet = CafeteriaWallet::firstOrCreate(['student_id' => $student->id]);
        $wallet->monthly_budget = $validated['monthly_budget'];
        $wallet->daily_limit = $validated['daily_limit'];
        $wallet->save();

        return $this->show($studentId);
    }

    /**
     * POST /api/cafeteria/wallet/{studentId}/charge
     * Cafeteria staff registers a meal purchase
     */
    public function charge(Request $request, $studentId)
    {
        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:0.50'],
            'item_name' => ['required', 'string'],
            'category' => ['nullable', 'string'],
            'staff_name' => ['nullable', 'string'],
        ]);

        $student = Student::findOrFail($studentId);

        $wallet = CafeteriaWallet::firstOrCreate(
            ['student_id' => $student->id],
            [
                'monthly_budget' => 500.00,
                'daily_limit' => 25.00,
                'monthly_spent' => 0.00,
                'today_spent' => 0.00,
                'last_spent_date' => now()->toDateString(),
            ]
        );

        $today = now()->toDateString();
        if ($wallet->last_spent_date && $wallet->last_spent_date->toDateString() !== $today) {
            $wallet->today_spent = 0.00;
            $wallet->last_spent_date = $today;
        }

        $amount = (float) $validated['amount'];
        $remainingMonthly = max(0, (float) $wallet->monthly_budget - (float) $wallet->monthly_spent);
        $remainingDaily = max(0, (float) $wallet->daily_limit - (float) $wallet->today_spent);

        if ($amount > $remainingDaily) {
            return response()->json([
                'message' => "Transaction exceeds child's daily limit of " . number_format($wallet->daily_limit, 2) . " AED. Remaining today: " . number_format($remainingDaily, 2) . " AED.",
            ], 422);
        }

        if ($amount > $remainingMonthly) {
            return response()->json([
                'message' => "Transaction exceeds remaining monthly budget of " . number_format($remainingMonthly, 2) . " AED.",
            ], 422);
        }

        $wallet->today_spent += $amount;
        $wallet->monthly_spent += $amount;
        $wallet->last_spent_date = $today;
        $wallet->save();

        $transaction = CafeteriaTransaction::create([
            'student_id' => $student->id,
            'amount' => $amount,
            'item_name' => $validated['item_name'],
            'category' => $validated['category'] ?? 'meal',
            'staff_name' => $validated['staff_name'] ?? ($request->user()?->name ?? 'Cafeteria Staff'),
        ]);

        return response()->json([
            'message' => 'Purchase charged successfully',
            'transaction' => $transaction,
            'wallet' => $this->show($studentId)->getData()->data,
        ]);
    }

    /**
     * GET /api/cafeteria/wallet/{studentId}/transactions
     */
    public function transactions($studentId)
    {
        $transactions = CafeteriaTransaction::where('student_id', $studentId)
            ->latest()
            ->take(50)
            ->get();

        return response()->json([
            'data' => $transactions,
        ]);
    }
}
