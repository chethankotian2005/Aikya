import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function proxy(request: NextRequest) {
  const session = request.cookies.get('session');
  
  // Public paths that don't require authentication
  const isPublicPath = request.nextUrl.pathname.startsWith('/login') ||
                       request.nextUrl.pathname.startsWith('/signup') ||
                       request.nextUrl.pathname.startsWith('/api/') ||
                       request.nextUrl.pathname.startsWith('/_next') ||
                       request.nextUrl.pathname.match(/\.(.*)$/); // static files

  if (!session && !isPublicPath) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  if (session && (request.nextUrl.pathname.startsWith('/login') || request.nextUrl.pathname.startsWith('/signup'))) {
    return NextResponse.redirect(new URL('/', request.url));
  }

  // Fine-grained role checks (e.g. for /admin or /coordinator) 
  // will be handled by Server Components where firebase-admin can run,
  // or we could use 'jwt-decode' here if needed.
  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico|firebase-messaging-sw.js).*)'],
};
