<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('medications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('name_ar')->nullable();
            $table->string('dosage');
            $table->string('route')->nullable();
            $table->text('instructions')->nullable();
            $table->string('status')->default('pending'); // pending|approved|active|declined|suspended
            $table->string('prescribed_by')->nullable();
            $table->boolean('requires_physician')->default(false);
            $table->foreignId('approved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('approved_at')->nullable();
            $table->integer('supply_count')->nullable();
            $table->integer('low_supply_threshold')->nullable();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->boolean('is_halal_sensitive')->default(false);
            $table->timestamps();
        });

        Schema::create('medication_doses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('medication_id')->constrained()->cascadeOnDelete();
            $table->time('scheduled_time');
            $table->json('days_of_week')->nullable(); // e.g. ["mon","tue"]
            $table->string('label')->nullable();
            $table->timestamps();
        });

        Schema::create('dose_administrations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('medication_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->foreignId('administered_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('scheduled_for')->nullable();
            $table->dateTime('administered_at')->nullable();
            $table->string('status')->default('pending'); // given|missed|refused|conflict|pending
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dose_administrations');
        Schema::dropIfExists('medication_doses');
        Schema::dropIfExists('medications');
    }
};
