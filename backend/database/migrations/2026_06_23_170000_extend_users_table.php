<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('role')->default('nurse')->after('email');
            $table->foreignId('school_id')->nullable()->after('role')->constrained()->nullOnDelete();
            $table->string('name_ar')->nullable()->after('name');
            $table->string('phone')->nullable()->after('school_id');
            $table->string('title')->nullable()->after('phone');
            $table->string('avatar_url')->nullable()->after('title');
            $table->string('license_number')->nullable()->after('avatar_url');
            $table->string('license_authority')->nullable()->after('license_number');
            $table->date('license_expiry')->nullable()->after('license_authority');
            $table->boolean('is_active')->default(true)->after('license_expiry');
            $table->string('locale')->default('en')->after('is_active');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('school_id');
            $table->dropColumn([
                'role', 'name_ar', 'phone', 'title', 'avatar_url',
                'license_number', 'license_authority', 'license_expiry', 'is_active', 'locale',
            ]);
        });
    }
};
