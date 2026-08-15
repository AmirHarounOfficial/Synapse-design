<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->foreignId('school_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('name_ar')->nullable();
            $table->string('grade')->nullable();
            $table->string('section')->nullable();
            $table->string('emirates_id')->nullable()->unique();
            $table->date('date_of_birth')->nullable();
            $table->string('gender')->nullable();
            $table->string('photo_url')->nullable();
            $table->string('blood_type')->nullable();
            $table->string('curriculum')->nullable();
            $table->text('medical_summary')->nullable();
            $table->boolean('profile_active')->default(true);
            $table->timestamps();
        });

        Schema::create('student_guardian', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('relationship')->nullable();
            $table->boolean('is_primary')->default(false);
            $table->boolean('can_pickup')->default(true);
            $table->timestamps();
            $table->unique(['student_id', 'user_id']);
        });

        Schema::create('authorized_persons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('relationship')->nullable();
            $table->string('phone')->nullable();
            $table->string('emirates_id')->nullable();
            $table->string('photo_url')->nullable();
            $table->string('qr_token')->unique();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('student_allergens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->string('allergen');
            $table->string('allergen_ar')->nullable();
            $table->string('severity')->default('moderate'); // mild|moderate|severe|life_threatening
            $table->string('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('student_allergens');
        Schema::dropIfExists('authorized_persons');
        Schema::dropIfExists('student_guardian');
        Schema::dropIfExists('students');
    }
};
