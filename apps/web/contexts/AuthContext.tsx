'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import {
  User,
  RegisterRequest,
  LoginRequest,
  registerUser as apiRegisterUser,
  loginUser as apiLoginUser,
  logoutUser as apiLogoutUser,
  getCurrentUser as apiGetCurrentUser
} from '@/data/auth';

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (data: RegisterRequest) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();

  // Check for existing session on mount
  useEffect(() => {
    const checkSession = async () => {
      try {
        const currentUser = await apiGetCurrentUser();
        setUser(currentUser);
      } catch (error) {
        console.error('Failed to check session:', error);
      } finally {
        setIsLoading(false);
      }
    };

    checkSession();
  }, []);

  const register = async (data: RegisterRequest) => {
    try {
      const newUser = await apiRegisterUser(data);
      setUser(newUser);
      router.push('/');
    } catch (error) {
      throw error; // Re-throw to let the form handle it
    }
  };

  const login = async (email: string, password: string) => {
    try {
      const loginData: LoginRequest = {
        user: { email, password }
      };
      const loggedInUser = await apiLoginUser(loginData);
      setUser(loggedInUser);
      router.push('/');
    } catch (error) {
      throw error; // Re-throw to let the form handle it
    }
  };

  const logout = async () => {
    try {
      await apiLogoutUser();
      setUser(null);
      router.push('/');
    } catch (error) {
      console.error('Logout failed:', error);
      // Even if the API call fails, clear the user locally
      setUser(null);
      router.push('/');
    }
  };

  return (
    <AuthContext.Provider value={{ user, isLoading, register, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
