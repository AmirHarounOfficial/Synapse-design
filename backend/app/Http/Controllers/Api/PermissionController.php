<?php

namespace App\Http\Controllers\Api;

use App\Enums\Role;
use App\Http\Controllers\Controller;
use App\Models\RolePermission;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PermissionController extends Controller
{
    /// GET /api/permissions
    public function index(Request $request)
    {
        $matrix = RolePermission::query()
            ->where('school_id', $request->user()->school_id)
            ->orderBy('role')
            ->orderBy('capability')
            ->get()
            ->groupBy('role')
            ->map(fn ($rows) => $rows->map(fn ($p) => [
                'capability' => $p->capability,
                'allowed' => $p->allowed,
            ])->values());

        return response()->json(['data' => $matrix]);
    }

    /// PUT /api/permissions
    public function update(Request $request)
    {
        $data = $request->validate([
            'permissions' => ['required', 'array'],
            'permissions.*.role' => ['required', Rule::in(Role::values())],
            'permissions.*.capability' => ['required', 'string'],
            'permissions.*.allowed' => ['required', 'boolean'],
        ]);

        $schoolId = $request->user()->school_id;

        foreach ($data['permissions'] as $permission) {
            RolePermission::updateOrCreate(
                [
                    'school_id' => $schoolId,
                    'role' => $permission['role'],
                    'capability' => $permission['capability'],
                ],
                ['allowed' => $permission['allowed']],
            );
        }

        return $this->index($request);
    }
}
