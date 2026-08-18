<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pharmacy_inventory_items', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('name_ar')->nullable();
            $table->string('category')->default('General'); // Analgesic, Antibiotic, Antihistamine, First Aid, Emergency, Maintenance, etc.
            $table->string('dosage_form')->nullable(); // e.g. 500mg tablet, 10mg/5ml syrup, 0.3mg auto-injector
            $table->integer('stock_quantity')->default(0);
            $table->integer('min_threshold')->default(10);
            $table->string('unit')->default('tablets'); // tablets, bottles, ampoules, boxes, inhalers
            $table->string('location')->nullable(); // Cabinet A-1, Fridge 2, Shelf 3
            $table->date('expiry_date')->nullable();
            $table->string('supplier')->nullable();
            $table->string('status')->default('active'); // active, low_stock, expired, out_of_stock
            $table->text('notes')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('pharmacy_inventory_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pharmacy_inventory_item_id')->nullable()->constrained('pharmacy_inventory_items')->nullOnDelete();
            $table->string('item_name'); // preserved even if item deleted
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('performed_by_name');
            $table->string('performed_by_role')->default('nurse');
            $table->string('action'); // created, updated, stock_adjusted, deleted
            $table->integer('quantity_change')->nullable();
            $table->integer('new_quantity')->nullable();
            $table->string('reason')->nullable();
            $table->json('meta')->nullable();
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pharmacy_inventory_logs');
        Schema::dropIfExists('pharmacy_inventory_items');
    }
};
