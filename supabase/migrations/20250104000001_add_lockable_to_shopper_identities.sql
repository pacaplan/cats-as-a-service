-- Migration: Add lockable columns for brute force protection
-- These columns support Devise's :lockable module for account security

-- Add failed_attempts counter for tracking consecutive failed sign-in attempts
ALTER TABLE identity.shopper_identities
ADD COLUMN failed_attempts INTEGER NOT NULL DEFAULT 0;

-- Add locked_at timestamp to track when account was locked
-- NULL means account is not locked
-- When set, account remains locked until unlock_in period (1 hour) has elapsed
ALTER TABLE identity.shopper_identities
ADD COLUMN locked_at TIMESTAMP NULL;
