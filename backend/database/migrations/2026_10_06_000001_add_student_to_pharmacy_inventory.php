<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pharmacy_inventory_items', function (Blueprint $table) {
            $table->foreignId('student_id')->nullable()->constrained()->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('pharmacy_inventory_items', function (Blueprint $table) {
            $table->dropConstrainedForeignId('student_id');
        });
    }
};
