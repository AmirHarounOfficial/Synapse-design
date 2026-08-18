<?php

namespace App\Http\Controllers\Api;

use App\Enums\Role;
use App\Http\Controllers\Controller;
use App\Http\Resources\PharmacyInventoryItemResource;
use App\Http\Resources\PharmacyInventoryLogResource;
use App\Models\PharmacyInventoryItem;
use App\Models\PharmacyInventoryLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PharmacyInventoryController extends Controller
{
    /**
     * Helper to compute item status based on stock count & expiry
     */
    private function computeStatus(int $stock, int $minThreshold, ?string $expiryDate): string
    {
        if ($stock <= 0) {
            return 'out_of_stock';
        }
        if ($expiryDate && strtotime($expiryDate) < time()) {
            return 'expired';
        }
        if ($stock <= $minThreshold) {
            return 'low_stock';
        }
        return 'active';
    }

    /**
     * Helper to record a pharmacy action audit log
     */
    private function recordLog($user, $item, string $action, ?int $quantityChange = null, ?int $newQuantity = null, ?string $reason = null, ?array $meta = null): PharmacyInventoryLog
    {
        return PharmacyInventoryLog::create([
            'pharmacy_inventory_item_id' => $item?->id,
            'item_name' => $item?->name ?? ($meta['item_name'] ?? 'Pharmacy Item'),
            'user_id' => $user?->id,
            'performed_by_name' => $user?->name ?? 'School Nurse',
            'performed_by_role' => $user?->role instanceof Role ? $user->role->value : ($user?->role ?? 'nurse'),
            'action' => $action,
            'quantity_change' => $quantityChange,
            'new_quantity' => $newQuantity ?? $item?->stock_quantity,
            'reason' => $reason,
            'meta' => $meta,
            'created_at' => now(),
        ]);
    }

    /**
     * GET /api/pharmacy-inventory
     */
    public function index(Request $request)
    {
        $query = PharmacyInventoryItem::query();

        if ($request->filled('search')) {
            $search = $request->string('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('name_ar', 'like', "%{$search}%")
                  ->orWhere('category', 'like', "%{$search}%")
                  ->orWhere('location', 'like', "%{$search}%");
            });
        }

        if ($request->filled('category') && $request->string('category') !== 'all') {
            $query->where('category', $request->string('category'));
        }

        if ($request->filled('status') && $request->string('status') !== 'all') {
            if ($request->string('status') === 'low_stock') {
                $query->where(function ($q) {
                    $q->where('status', 'low_stock')
                      ->orWhereRaw('stock_quantity <= min_threshold');
                });
            } else {
                $query->where('status', $request->string('status'));
            }
        }

        $items = $query->orderBy('name')->get();

        return PharmacyInventoryItemResource::collection($items);
    }

    /**
     * GET /api/pharmacy-inventory/{item}
     */
    public function show(PharmacyInventoryItem $pharmacy_inventory)
    {
        return new PharmacyInventoryItemResource($pharmacy_inventory->load('logs'));
    }

    /**
     * POST /api/pharmacy-inventory
     */
    public function store(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'name_ar' => ['nullable', 'string', 'max:255'],
            'category' => ['required', 'string', 'max:100'],
            'dosage_form' => ['nullable', 'string', 'max:100'],
            'stock_quantity' => ['required', 'integer', 'min:0'],
            'min_threshold' => ['required', 'integer', 'min:0'],
            'unit' => ['required', 'string', 'max:50'],
            'location' => ['nullable', 'string', 'max:100'],
            'expiry_date' => ['nullable', 'date'],
            'supplier' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
        ]);

        $data['status'] = $this->computeStatus($data['stock_quantity'], $data['min_threshold'], $data['expiry_date'] ?? null);
        $data['created_by'] = $user?->id;
        $data['updated_by'] = $user?->id;

        $item = PharmacyInventoryItem::create($data);

        $this->recordLog(
            $user,
            $item,
            'created',
            $data['stock_quantity'],
            $data['stock_quantity'],
            'Initial inventory entry added',
            ['initial_fields' => $data]
        );

        return new PharmacyInventoryItemResource($item);
    }

    /**
     * PUT/PATCH /api/pharmacy-inventory/{item}
     */
    public function update(Request $request, PharmacyInventoryItem $pharmacy_inventory)
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'name_ar' => ['nullable', 'string', 'max:255'],
            'category' => ['sometimes', 'string', 'max:100'],
            'dosage_form' => ['nullable', 'string', 'max:100'],
            'stock_quantity' => ['sometimes', 'integer', 'min:0'],
            'min_threshold' => ['sometimes', 'integer', 'min:0'],
            'unit' => ['sometimes', 'string', 'max:50'],
            'location' => ['nullable', 'string', 'max:100'],
            'expiry_date' => ['nullable', 'date'],
            'supplier' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
        ]);

        $oldStock = $pharmacy_inventory->stock_quantity;
        $newStock = $data['stock_quantity'] ?? $oldStock;
        $minThreshold = $data['min_threshold'] ?? $pharmacy_inventory->min_threshold;
        $expiryDate = array_key_exists('expiry_date', $data) ? $data['expiry_date'] : $pharmacy_inventory->expiry_date?->format('Y-m-d');

        $data['status'] = $this->computeStatus($newStock, $minThreshold, $expiryDate);
        $data['updated_by'] = $user?->id;

        $pharmacy_inventory->update($data);

        $quantityChange = $newStock - $oldStock;

        $this->recordLog(
            $user,
            $pharmacy_inventory,
            'updated',
            $quantityChange != 0 ? $quantityChange : null,
            $newStock,
            'Pharmacy inventory item updated',
            ['updated_fields' => array_keys($data)]
        );

        return new PharmacyInventoryItemResource($pharmacy_inventory);
    }

    /**
     * POST /api/pharmacy-inventory/{item}/adjust-stock
     */
    public function adjustStock(Request $request, PharmacyInventoryItem $pharmacy_inventory)
    {
        $user = $request->user();

        $data = $request->validate([
            'adjustment' => ['required', 'integer'], // e.g. +20 for intake, -5 for dispense
            'reason' => ['required', 'string', 'max:255'],
        ]);

        $oldStock = $pharmacy_inventory->stock_quantity;
        $newStock = max(0, $oldStock + $data['adjustment']);

        $pharmacy_inventory->stock_quantity = $newStock;
        $pharmacy_inventory->status = $this->computeStatus(
            $newStock,
            $pharmacy_inventory->min_threshold,
            $pharmacy_inventory->expiry_date?->format('Y-m-d')
        );
        $pharmacy_inventory->updated_by = $user?->id;
        $pharmacy_inventory->save();

        $this->recordLog(
            $user,
            $pharmacy_inventory,
            'stock_adjusted',
            $data['adjustment'],
            $newStock,
            $data['reason'],
            ['previous_stock' => $oldStock, 'adjustment' => $data['adjustment']]
        );

        return new PharmacyInventoryItemResource($pharmacy_inventory);
    }

    /**
     * DELETE /api/pharmacy-inventory/{item}
     */
    public function destroy(Request $request, PharmacyInventoryItem $pharmacy_inventory)
    {
        $user = $request->user();
        $itemName = $pharmacy_inventory->name;
        $lastStock = $pharmacy_inventory->stock_quantity;

        $this->recordLog(
            $user,
            $pharmacy_inventory,
            'deleted',
            -$lastStock,
            0,
            'Item removed from pharmacy inventory',
            ['item_name' => $itemName]
        );

        $pharmacy_inventory->delete();

        return response()->json([
            'message' => 'Pharmacy inventory item deleted successfully.',
            'item_name' => $itemName,
        ]);
    }

    /**
     * GET /api/pharmacy-inventory/logs
     */
    public function logs(Request $request)
    {
        $query = PharmacyInventoryLog::query();

        if ($request->filled('item_id')) {
            $query->where('pharmacy_inventory_item_id', $request->integer('item_id'));
        }

        if ($request->filled('action')) {
            $query->where('action', $request->string('action'));
        }

        $logs = $query->latest('created_at')->limit(100)->get();

        return PharmacyInventoryLogResource::collection($logs);
    }
}
