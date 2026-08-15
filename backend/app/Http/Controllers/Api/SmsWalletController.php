<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\SmsTransactionResource;
use App\Models\SmsTransaction;
use App\Models\SmsWallet;
use Illuminate\Http\Request;

class SmsWalletController extends Controller
{
    /// GET /api/sms-wallet — balance and recent transactions for the school.
    public function show(Request $request)
    {
        $schoolId = $request->user()->school_id;

        $wallet = SmsWallet::firstOrCreate(
            ['school_id' => $schoolId],
            ['balance_credits' => 0],
        );

        $transactions = SmsTransaction::query()
            ->where('school_id', $schoolId)
            ->latest()
            ->limit(20)
            ->get();

        return response()->json([
            'balance_credits' => $wallet->balance_credits,
            'transactions' => SmsTransactionResource::collection($transactions),
        ]);
    }

    /// POST /api/sms-wallet/topup {credits} — add credits and log a topup.
    public function topup(Request $request)
    {
        $data = $request->validate([
            'credits' => ['required', 'integer', 'min:1'],
        ]);

        $schoolId = $request->user()->school_id;

        $wallet = SmsWallet::firstOrCreate(
            ['school_id' => $schoolId],
            ['balance_credits' => 0],
        );

        $wallet->increment('balance_credits', $data['credits']);

        SmsTransaction::create([
            'school_id' => $schoolId,
            'type' => 'topup',
            'credits' => $data['credits'],
            'description' => 'Wallet top-up of '.$data['credits'].' credits',
        ]);

        return response()->json([
            'balance_credits' => $wallet->fresh()->balance_credits,
            'transactions' => SmsTransactionResource::collection(
                SmsTransaction::query()
                    ->where('school_id', $schoolId)
                    ->latest()
                    ->limit(20)
                    ->get()
            ),
        ]);
    }
}
