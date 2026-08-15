<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/// Route guard: `->middleware('role:nurse,physician')`. Passes if the
/// authenticated user's role is in the allow-list (admin always passes).
class EnsureUserRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if ($user === null) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $role = $user->role?->value;

        if ($role !== 'admin' && ! in_array($role, $roles, true)) {
            return response()->json(['message' => 'This action is unauthorized for your role.'], 403);
        }

        return $next($request);
    }
}
