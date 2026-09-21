<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cafeteria_wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->unique()->constrained('students')->onDelete('cascade');
            $table->decimal('monthly_budget', 10, 2)->default(500.00);
            $table->decimal('daily_limit', 10, 2)->default(25.00);
            $table->decimal('monthly_spent', 10, 2)->default(0.00);
            $table->decimal('today_spent', 10, 2)->default(0.00);
            $table->date('last_spent_date')->nullable();
            $table->timestamps();
        });

        Schema::create('cafeteria_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('students')->onDelete('cascade');
            $table->decimal('amount', 10, 2);
            $table->string('item_name');
            $table->string('category')->default('meal'); // meal, snack, beverage, custom
            $table->string('staff_name')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cafeteria_transactions');
        Schema::dropIfExists('cafeteria_wallets');
    }
};
