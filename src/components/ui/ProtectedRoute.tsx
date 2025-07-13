import React, { ReactNode } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import { Navigate } from 'react-router-dom';

interface ProtectedRouteProps {
  children: ReactNode;
  requireAdmin?: boolean;
  requireStudent?: boolean;
}

export function ProtectedRoute({ children, requireAdmin = false, requireStudent = false }: ProtectedRouteProps) {
  const { user, profile, loading } = useAuth();

  console.log('ProtectedRoute - User:', user?.id, 'Profile:', profile?.role, 'Loading:', loading);

  // Show loading spinner while checking authentication
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  // Redirect to login if not authenticated
  if (!user) {
    console.log('No user, redirecting to login');
    return <Navigate to="/login" replace />;
  }

  // Wait for profile to load - show loading if we have user but no profile yet
  if (!profile) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading profile...</p>
        </div>
      </div>
    );
  }

  // Check role-based access
  if (requireAdmin && profile.role !== 'admin') {
    console.log('Admin required but user is:', profile.role);
    return <Navigate to="/dashboard" replace />;
  }

  if (requireStudent && profile.role !== 'student') {
    console.log('Student required but user is:', profile.role);
    return <Navigate to="/admin" replace />;
  }

  console.log('Access granted for role:', profile.role);
  return <>{children}</>;
}