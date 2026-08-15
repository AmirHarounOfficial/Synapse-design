<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('school_id')->constrained()->cascadeOnDelete()->index();
            $table->foreignId('sender_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('sender_name'); // denormalized for parents/external senders
            $table->foreignId('recipient_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('category')->default('general'); // attendance|health|general|urgent
            $table->string('subject');
            $table->text('body');
            $table->string('status')->default('unread'); // unread|read|replied
            $table->foreignId('parent_message_id')->nullable()->constrained('messages')->cascadeOnDelete();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
