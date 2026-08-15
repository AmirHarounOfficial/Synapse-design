<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pickups', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->foreignId('authorized_person_id')->nullable()->constrained('authorized_persons')->nullOnDelete();
            $table->foreignId('security_guard_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('method')->default('qr'); // qr|manual
            $table->string('status')->default('pending'); // pending|verified|released|denied
            $table->dateTime('released_at')->nullable();
            $table->string('notes')->nullable();
            $table->timestamps();
        });

        Schema::create('bus_routes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('school_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->foreignId('driver_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('bus_number')->nullable();
            $table->string('period')->default('morning'); // morning|afternoon
            $table->string('status')->default('scheduled'); // scheduled|in_progress|completed
            $table->timestamps();
        });

        Schema::create('bus_boarding_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('bus_route_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->string('type'); // boarding|deboarding
            $table->string('status')->default('pending'); // boarded|deboarded|absent|pending
            $table->dateTime('occurred_at')->nullable();
            $table->boolean('parent_notified')->default(false);
            $table->string('stop_name')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bus_boarding_events');
        Schema::dropIfExists('bus_routes');
        Schema::dropIfExists('pickups');
    }
};
