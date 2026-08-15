<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\EquipmentItemResource;
use App\Models\EquipmentItem;
use Illuminate\Http\Request;

class EquipmentController extends Controller
{
    /// GET /api/equipment-items?category= — school-scoped list.
    public function index(Request $request)
    {
        $query = EquipmentItem::query()
            ->where('school_id', $request->user()->school_id)
            ->with('checkedBy');

        if ($request->filled('category')) {
            $query->where('category', $request->string('category'));
        }

        return EquipmentItemResource::collection($query->orderBy('name')->get());
    }

    /// PUT|PATCH /api/equipment-items/{equipment_item} {status?, location?}
    public function update(Request $request, EquipmentItem $equipmentItem)
    {
        abort_if($equipmentItem->school_id !== $request->user()->school_id, 404);

        $data = $request->validate([
            'status' => ['sometimes', 'in:ok,low,expired,missing'],
            'location' => ['nullable', 'string'],
        ]);

        $data['last_checked_at'] = now();
        $data['checked_by'] = $request->user()->id;

        $equipmentItem->update($data);

        return new EquipmentItemResource($equipmentItem->load('checkedBy'));
    }
}
