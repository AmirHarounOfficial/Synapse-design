<?php

namespace App\Http\Controllers\Api;

use App\Enums\Role;
use App\Http\Controllers\Controller;
use App\Http\Resources\StaffResource;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class StaffController extends Controller
{
    /// GET /api/staff?role=
    public function index(Request $request)
    {
        $query = User::query()->where('school_id', $request->user()->school_id);

        if ($request->filled('role')) {
            $query->where('role', $request->string('role'));
        } else {
            // Staff management lists employees only — never parents/guardians.
            $query->where('role', '!=', 'parent');
        }

        return StaffResource::collection($query->orderBy('name')->paginate(50));
    }

    /// GET /api/staff/{user}
    public function show(User $user)
    {
        return new StaffResource($user);
    }

    /// POST /api/staff
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string'],
            'email' => ['required', 'email', 'unique:users,email'],
            'role' => ['required', Rule::in(Role::values())],
            'phone' => ['nullable', 'string'],
            'title' => ['nullable', 'string'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'role' => $data['role'],
            'phone' => $data['phone'] ?? null,
            'title' => $data['title'] ?? null,
            'school_id' => $request->user()->school_id,
            'password' => Hash::make('password'),
            'is_active' => true,
        ]);

        return new StaffResource($user);
    }

    /// PUT/PATCH /api/staff/{user}
    public function update(Request $request, User $user)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string'],
            'role' => ['sometimes', Rule::in(Role::values())],
            'phone' => ['nullable', 'string'],
            'title' => ['nullable', 'string'],
            'is_active' => ['boolean'],
        ]);

        $user->update($data);

        return new StaffResource($user);
    }

    /// POST /api/staff/{user}/deactivate
    public function deactivate(User $user)
    {
        $user->update(['is_active' => false]);

        return new StaffResource($user);
    }
}
