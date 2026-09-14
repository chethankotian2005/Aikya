import { FirebaseError } from "firebase/app";

const MESSAGES: Record<string, string> = {
  "auth/invalid-credential": "Incorrect ID or password.",
  "auth/wrong-password": "Incorrect ID or password.",
  "auth/user-not-found": "Incorrect ID or password.",
  "auth/invalid-email": "Incorrect ID or password.",
  "auth/email-already-in-use": "An account with this USN already exists. Please log in instead.",
  "auth/weak-password": "Password is too weak — use at least 6 characters.",
  "auth/too-many-requests": "Too many attempts. Please wait a minute and try again.",
  "auth/network-request-failed": "No internet connection. Please try again.",
  "auth/requires-recent-login": "For security, please log out, log in again and retry.",
  "auth/user-disabled": "This account has been disabled. Contact the HOD office.",
  "permission-denied": "You don't have permission to do that.",
  unavailable: "Service unavailable. Check your connection and try again.",
  "failed-precondition": "This list is still being set up. Please try again in a few minutes.",
  "storage/unauthorized": "That file couldn't be uploaded — check it's an image under 10 MB.",
};

/** Turns Firebase/API errors into a sentence a student can act on. */
export function friendlyError(error: unknown): string {
  if (error instanceof FirebaseError) {
    return MESSAGES[error.code] ?? "Something went wrong. Please try again.";
  }
  if (error instanceof Error && error.message) return error.message;
  return "Something went wrong. Please try again.";
}
