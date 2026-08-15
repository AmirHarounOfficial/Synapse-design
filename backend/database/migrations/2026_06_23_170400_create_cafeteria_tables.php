<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('meals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('school_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('name_ar')->nullable();
            $table->date('date');
            $table->boolean('is_halal')->default(true);
            $table->boolean('halal_certified')->default(false);
            $table->json('allergens')->nullable();
            $table->timestamps();
        });

        Schema::create('halal_certifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('school_id')->constrained()->cascadeOnDelete();
            $table->string('supplier');
            $table->string('certificate_no');
            $table->date('issued_date');
            $table->date('expiry_date');
            $table->string('status')->default('valid'); // valid|expiring|expired
            $table->timestamps();
        });

        Schema::create('cafeteria_alerts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('school_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('title');
            $table->text('message');
            $table->string('severity')->default('info'); // info|warning|critical
            $table->boolean('is_halal_issue')->default(false);
            $table->boolean('acknowledged')->default(false);
            $table->date('created_for_date')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cafeteria_alerts');
        Schema::dropIfExists('halal_certifications');
        Schema::dropIfExists('meals');
    }
};
