<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('clinic_visits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->foreignId('school_id')->constrained()->cascadeOnDelete();
            $table->foreignId('nurse_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('reason');
            $table->string('reason_ar')->nullable();
            $table->text('notes')->nullable();
            $table->string('severity')->default('low'); // low|medium|high|critical
            $table->boolean('is_emergency')->default(false);
            $table->dateTime('visited_at');
            $table->string('outcome')->nullable();
            $table->string('photo_url')->nullable();
            $table->timestamps();
        });

        Schema::create('emergency_consents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->foreignId('clinic_visit_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('requested_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('parent_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('status')->default('pending'); // pending|approved|declined
            $table->text('details')->nullable();
            $table->dateTime('responded_at')->nullable();
            $table->timestamps();
        });

        Schema::create('documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->string('type'); // insurance_card|vaccination|consent|medical_report
            $table->string('title');
            $table->string('file_path')->nullable();
            $table->string('status')->default('pending'); // pending|approved|rejected
            $table->date('expiry_date')->nullable();
            $table->foreignId('uploaded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('reviewed_at')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('documents');
        Schema::dropIfExists('emergency_consents');
        Schema::dropIfExists('clinic_visits');
    }
};
