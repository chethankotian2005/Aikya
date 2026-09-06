import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_tokens.dart';

/// Login screen: hero gradient header → white card with USN/Email tabs.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isUsnTab = true;
  bool _obscurePassword = true;

  late final AnimationController _cardController;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardFade = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: Column(
        children: [
          _buildHero(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SlideTransition(
                position: _cardSlide,
                child: FadeTransition(
                  opacity: _cardFade,
                  child: _buildCard(context),
                ),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // ─── Hero gradient strip ──────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo row
              Row(
                children: [
                  // AIKYA logo mark
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/branding/aikya_logo_cropped.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      children: const [
                        TextSpan(text: 'AIML Hub'),
                        TextSpan(
                          text: '.',
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Welcome back',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sign in to your department portal',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Login card ───────────────────────────────────────────────────
  Widget _buildCard(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0, -20, 0),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabs
          _buildTabs(),
          const SizedBox(height: AppSpacing.lg),

          // Tab content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isUsnTab ? _buildUsnContent() : _buildEmailContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isUsnTab = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isUsnTab ? AppColors.surfaceElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _isUsnTab ? AppShadows.sm : null,
                ),
                child: Center(
                  child: Text(
                    'USN Login',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isUsnTab
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isUsnTab = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isUsnTab ? AppColors.surfaceElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !_isUsnTab ? AppShadows.sm : null,
                ),
                child: Center(
                  child: Text(
                    'Email',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: !_isUsnTab
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── USN tab ──────────────────────────────────────────────────────
  Widget _buildUsnContent() {
    return Column(
      key: const ValueKey('usn'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('University Seat Number'),
        const SizedBox(height: 6),
        _inputField(
          hint: '4MW21AI045',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 6),
        _microCopy(
          icon: Icons.shield_outlined,
          text: 'Verified 4MWxxAIxxx students only',
        ),
        const SizedBox(height: AppSpacing.base),
        _label('Password'),
        const SizedBox(height: 6),
        _passwordField(),
        _forgotLink(),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          icon: const Icon(Icons.login_rounded, size: 18),
          label: const Text('Sign In with USN'),
        ),
      ],
    );
  }

  // ─── Email tab ────────────────────────────────────────────────────
  Widget _buildEmailContent() {
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('College Email'),
        const SizedBox(height: 6),
        _inputField(
          hint: 'name@smvitm.ac.in',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.base),
        _label('Password'),
        const SizedBox(height: 6),
        _passwordField(),
        _forgotLink(),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          icon: const Icon(Icons.email_outlined, size: 18),
          label: const Text('Continue with College Email'),
        ),
        const SizedBox(height: AppSpacing.base),
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'OR',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  letterSpacing: 1,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: AppSpacing.base),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Image.network(
            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
            width: 18,
            height: 18,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.g_mobiledata_rounded, size: 22),
          ),
          label: const Text('Sign in with Google'),
        ),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────
  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _inputField({
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 52,
      child: TextField(
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textTertiary),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return SizedBox(
      height: 52,
      child: TextField(
        obscureText: _obscurePassword,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Enter your password',
          prefixIcon: const Icon(Icons.lock_outline_rounded,
              size: 20, color: AppColors.textTertiary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
              color: AppColors.textTertiary,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _forgotLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Forgot password?',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  Widget _microCopy({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 8,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New student? ',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textTertiary),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Request access',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/admin_shell');
            },
            child: Text(
              'Faculty Login Preview',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small spinning ring for the login hero logo mark.
class _MiniSpinRing extends StatefulWidget {
  @override
  State<_MiniSpinRing> createState() => _MiniSpinRingState();
}

class _MiniSpinRingState extends State<_MiniSpinRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Transform.rotate(
        angle: _controller.value * 2 * 3.14159,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.transparent, width: 2),
          ),
          child: CustomPaint(
            painter: _LoginRingPainter(),
          ),
        ),
      ),
    );
  }
}

class _LoginRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = const SweepGradient(
        colors: [
          AppColors.accent,
          Color(0x991F5C99),
          Colors.transparent,
          Colors.transparent,
        ],
        stops: [0.0, 0.4, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawArc(rect.deflate(2), 0, 2 * 3.14159, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
