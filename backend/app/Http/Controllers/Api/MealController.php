<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MealResource;
use App\Models\Meal;
use Illuminate\Http\Request;

class MealController extends Controller
{
    /// GET /api/meals?date=&school_id=
    public function index(Request $request)
    {
        $query = Meal::query();

        if ($request->filled('date')) {
            $query->whereDate('date', $request->date('date'));
        }
        if ($request->filled('school_id')) {
            $query->where('school_id', $request->integer('school_id'));
        }

        return MealResource::collection($query->orderBy('date', 'desc')->orderBy('name')->paginate(50));
    }

    public function show(Meal $meal)
    {
        return new MealResource($meal);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'school_id' => ['required', 'exists:schools,id'],
            'name' => ['required', 'string'],
            'name_ar' => ['nullable', 'string'],
            'date' => ['required', 'date'],
            'is_halal' => ['boolean'],
            'halal_certified' => ['boolean'],
            'allergens' => ['nullable', 'array'],
            'allergens.*' => ['string'],
        ]);

        return new MealResource(Meal::create($data));
    }

    public function update(Request $request, Meal $meal)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string'],
            'name_ar' => ['nullable', 'string'],
            'date' => ['sometimes', 'date'],
            'is_halal' => ['boolean'],
            'halal_certified' => ['boolean'],
            'allergens' => ['nullable', 'array'],
            'allergens.*' => ['string'],
        ]);

        $meal->update($data);

        return new MealResource($meal);
    }
}
