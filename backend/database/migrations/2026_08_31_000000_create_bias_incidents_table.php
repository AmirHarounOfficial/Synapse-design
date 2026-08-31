<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bias_incidents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('students')->onDelete('cascade');
            $table->string('student_name');
            $table->foreignId('reporter_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('reporter_role')->default('teacher'); // teacher, bus_driver, counselor
            $table->string('reporter_name');
            $table->string('location')->default('classroom'); // classroom, hallway, cafeteria, bus, online, playground, other
            $table->string('bus_route_number')->nullable();
            $table->string('category')->default('verbal_slur');
            $table->string('severity')->default('medium'); // low, medium, high, critical
            $table->string('status')->default('submitted'); // submitted, under_review, action_plan_active, resolved
            $table->text('description');
            $table->text('immediate_action_taken')->nullable();
            $table->text('witnesses')->nullable();
            $table->text('counselor_notes')->nullable();
            $table->text('resolution_plan')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bias_incidents');
    }
};
