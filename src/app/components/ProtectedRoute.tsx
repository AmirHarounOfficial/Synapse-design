import { Navigate } from 'react-router';

interface ProtectedRouteProps {
  children: React.ReactNode;
  isAuthenticated: boolean;
  redirectTo?: string;
}

export function ProtectedRoute({ children, isAuthenticated, redirectTo = '/login' }: ProtectedRouteProps) {
  if (!isAuthenticated) {
    return <Navigate to={redirectTo} replace />;
  }

  return <>{children}</>;
}
