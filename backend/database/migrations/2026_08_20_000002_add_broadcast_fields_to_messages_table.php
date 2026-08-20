<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            if (!Schema::hasColumn('messages', 'recipient_type')) {
                $table->string('recipient_type')->nullable()->after('recipient_id');
            }
            if (!Schema::hasColumn('messages', 'target_sector')) {
                $table->string('target_sector')->nullable()->after('recipient_type');
            }
            if (!Schema::hasColumn('messages', 'recipient_ids')) {
                $table->json('recipient_ids')->nullable()->after('target_sector');
            }
        });
    }

    public function down(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            $columnsToDrop = [];
            if (Schema::hasColumn('messages', 'recipient_type')) {
                $columnsToDrop[] = 'recipient_type';
            }
            if (Schema::hasColumn('messages', 'target_sector')) {
                $columnsToDrop[] = 'target_sector';
            }
            if (Schema::hasColumn('messages', 'recipient_ids')) {
                $columnsToDrop[] = 'recipient_ids';
            }
            if (!empty($columnsToDrop)) {
                $table->dropColumn($columnsToDrop);
            }
        });
    }
};
