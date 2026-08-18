<?php

namespace Database\Seeders;

use App\Models\PharmacyInventoryItem;
use App\Models\PharmacyInventoryLog;
use App\Models\User;
use Illuminate\Database\Seeder;

class PharmacyInventorySeeder extends Seeder
{
    public function run(): void
    {
        $nurse = User::where('role', 'nurse')->first();
        $nurseId = $nurse?->id;
        $nurseName = $nurse?->name ?? 'Aisha Rahman (Nurse)';

        $itemsData = [
            [
                'name' => 'Paracetamol 500mg Tablets',
                'name_ar' => 'باراسيتامول 500 ملغ أقراص',
                'category' => 'Analgesic',
                'dosage_form' => '500mg Tablet',
                'stock_quantity' => 120,
                'min_threshold' => 30,
                'unit' => 'tablets',
                'location' => 'Cabinet A-1',
                'expiry_date' => '2027-11-15',
                'supplier' => 'Julphar Pharmaceuticals',
                'status' => 'active',
                'notes' => 'General fever & pain relief stock.',
            ],
            [
                'name' => 'Amoxicillin 250mg Oral Suspension',
                'name_ar' => 'أمكسيسيلين 250 ملغ معلق مفصلي',
                'category' => 'Antibiotic',
                'dosage_form' => '250mg/5ml Liquid',
                'stock_quantity' => 12,
                'min_threshold' => 15,
                'unit' => 'bottles',
                'location' => 'Fridge 1',
                'expiry_date' => '2027-06-30',
                'supplier' => 'Gulf Pharmaceutical Industries',
                'status' => 'low_stock',
                'notes' => 'Keep refrigerated between 2-8°C.',
            ],
            [
                'name' => 'Ventolin Inhaler 100mcg',
                'name_ar' => 'بخاخ فنتولين 100 مكغ',
                'category' => 'Respiratory',
                'dosage_form' => '100mcg/dose Inhaler',
                'stock_quantity' => 25,
                'min_threshold' => 10,
                'unit' => 'inhalers',
                'location' => 'Cabinet B-2',
                'expiry_date' => '2028-03-20',
                'supplier' => 'GlaxoSmithKline UAE',
                'status' => 'active',
                'notes' => 'Asthma rescue inhalers.',
            ],
            [
                'name' => 'EpiPen Auto-Injector 0.3mg',
                'name_ar' => 'حقنة إبي بين التلقائية 0.3 ملغ',
                'category' => 'Emergency',
                'dosage_form' => '0.3mg Auto-Injector',
                'stock_quantity' => 4,
                'min_threshold' => 5,
                'unit' => 'units',
                'location' => 'Emergency Crash Cart',
                'expiry_date' => '2027-09-10',
                'supplier' => 'Viatris Dubai',
                'status' => 'low_stock',
                'notes' => 'Severe anaphylaxis immediate emergency response.',
            ],
            [
                'name' => 'Sterile Saline Solution 0.9%',
                'name_ar' => 'محلول ملحي معقم 0.9%',
                'category' => 'First Aid',
                'dosage_form' => '100ml Bottle',
                'stock_quantity' => 45,
                'min_threshold' => 10,
                'unit' => 'bottles',
                'location' => 'Shelf C-3',
                'expiry_date' => '2028-01-01',
                'supplier' => 'Global Medical Supplies',
                'status' => 'active',
                'notes' => 'Eye wash and wound cleaning.',
            ],
            [
                'name' => 'Cetirizine 10mg Tablets',
                'name_ar' => 'سيتريزين 10 ملغ أقراص',
                'category' => 'Antihistamine',
                'dosage_form' => '10mg Tablet',
                'stock_quantity' => 0,
                'min_threshold' => 20,
                'unit' => 'tablets',
                'location' => 'Cabinet A-2',
                'expiry_date' => '2027-05-10',
                'supplier' => 'Julphar Pharmaceuticals',
                'status' => 'out_of_stock',
                'notes' => 'Seasonal allergy relief. Order replenishment urgent.',
            ],
        ];

        foreach ($itemsData as $data) {
            $data['created_by'] = $nurseId;
            $data['updated_by'] = $nurseId;
            $item = PharmacyInventoryItem::create($data);

            // Record initial audit log
            PharmacyInventoryLog::create([
                'pharmacy_inventory_item_id' => $item->id,
                'item_name' => $item->name,
                'user_id' => $nurseId,
                'performed_by_name' => $nurseName,
                'performed_by_role' => 'nurse',
                'action' => 'created',
                'quantity_change' => $item->stock_quantity,
                'new_quantity' => $item->stock_quantity,
                'reason' => 'Initial inventory item cataloging',
                'created_at' => now()->subHours(rand(1, 48)),
            ]);

            if ($item->status === 'low_stock' || $item->stock_quantity > 50) {
                // Add a sample stock adjustment log entry
                PharmacyInventoryLog::create([
                    'pharmacy_inventory_item_id' => $item->id,
                    'item_name' => $item->name,
                    'user_id' => $nurseId,
                    'performed_by_name' => $nurseName,
                    'performed_by_role' => 'nurse',
                    'action' => 'stock_adjusted',
                    'quantity_change' => 15,
                    'new_quantity' => $item->stock_quantity,
                    'reason' => 'Routine weekly stock replenishment',
                    'created_at' => now()->subHours(rand(2, 12)),
                ]);
            }
        }
    }
}
