import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReStckr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class AuthService {
  // Temporary account for testing
  static const String _tempEmail = 'test@example.com';
  static const String _tempPassword = '123456';

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    if (!EmailValidator.validate(email)) {
      throw Exception('Invalid email format');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Check against temporary credentials
    if (email == _tempEmail && password == _tempPassword) {
      return true;
    }
    throw Exception('Invalid credentials');
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google sign in was cancelled');
      }
      return true;
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  Future<bool> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        return true;
      }
      throw Exception('Facebook sign in was cancelled');
    } catch (e) {
      throw Exception('Failed to sign in with Facebook: ${e.toString()}');
    }
  }

  Future<bool> resetPassword(String email) async {
    if (!EmailValidator.validate(email)) {
      throw Exception('Invalid email format');
    }
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return true;
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    if (!EmailValidator.validate(email)) {
      throw Exception('Invalid email format');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    if (fullName.isEmpty) {
      throw Exception('Full name is required');
    }
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return true;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final success = await _authService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        if (success && mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await _authService.signInWithGoogle();
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleFacebookSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await _authService.signInWithFacebook();
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.shopping_bag_outlined,
                        size: 60,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 16),
                // App Name
                const Text(
                  'ReStckr',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your companion in everyday shopping.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                // Login Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Log in to access your grocery lists\nand more.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 24),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onTap: () {
                          _emailController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: _emailController.text.length),
                          );
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onTap: () {
                          _passwordController
                              .selection = TextSelection.fromPosition(
                            TextPosition(
                              offset: _passwordController.text.length,
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
    setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('LOGIN'),
                      ),
                      const SizedBox(height: 16),
                      // Forgot Password
                      Center(
                        child: TextButton(
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                '/forgot-password',
                              ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ),
                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed:
                                () => Navigator.pushNamed(context, '/signup'),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Social Login Divider
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Sign in with'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed:
                                _isLoading ? null : _handleFacebookSignIn,
                            icon: const FaIcon(
                              FontAwesomeIcons.facebook,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: _isLoading ? null : _handleGoogleSignIn,
                            icon: const FaIcon(
                              FontAwesomeIcons.google,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final success = await _authService.signUp(
          _emailController.text,
          _passwordController.text,
          _fullNameController.text,
        );
        if (!mounted) return;
        if (success) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // User Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign Up Text
                const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Create your account',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),
                // Full Name Field
                TextFormField(
                  controller: _fullNameController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  onTap: () {
                    _fullNameController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _fullNameController.text.length),
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onTap: () {
                    _emailController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _emailController.text.length),
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!EmailValidator.validate(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  onTap: () {
                    _passwordController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _passwordController.text.length),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const UnderlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onTap: () {
                    _confirmPasswordController
                        .selection = TextSelection.fromPosition(
                      TextPosition(
                        offset: _confirmPasswordController.text.length,
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm your password',
                    border: const UnderlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('SIGN UP'),
                  ),
                ),
                const SizedBox(height: 16),
                // Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final success = await _authService.resetPassword(_emailController.text);

        if (!mounted) return;
        if (success) {
          setState(() => _emailSent = true);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                if (_emailSent)
                  const Center(
                    child: Text(
                      'Password reset instructions have been sent to your email.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                else ...[
                  const Text(
                    'Enter your email address and we\'ll send you instructions to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onTap: () {
                      _emailController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _emailController.text.length),
                      );
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('SEND RESET LINK'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<PurchaseHistory> _purchaseHistory = [];
  final Map<String, List<CartItem>> _cartItems = {};

  double _calculateTotal() {
    double total = 0;
    for (var section in _cartItems.entries) {
      for (var item in section.value) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  String get _title {
    switch (_selectedIndex) {
      case 0:
        return 'Stocks';
      case 1:
        return 'Cart';
      case 2:
        return 'Activity';
      case 3:
        return 'Events';
      default:
        return '';
    }
  }

  IconData get _titleIcon {
    switch (_selectedIndex) {
      case 0:
        return Icons.inventory_2_outlined;
      case 1:
        return Icons.shopping_bag_outlined;
      case 2:
        return Icons.history;
      case 3:
        return Icons.calendar_today;
      default:
        return Icons.error;
    }
  }

  void addToCart(String section, String itemName, double price) {
    setState(() {
      if (!_cartItems.containsKey(section)) {
        _cartItems[section] = [];
      }

      var existingItem = _cartItems[section]!.firstWhere(
        (item) => item.name == itemName,
        orElse: () => CartItem(name: itemName, quantity: 0, price: price),
      );

      if (existingItem.quantity == 0) {
        // New item
        existingItem = CartItem(name: itemName, quantity: 1, price: price);
        _cartItems[section]!.add(existingItem);
      } else {
        // Existing item
        existingItem.quantity++;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $itemName to cart'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _confirmPurchase() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create a map of all items and their quantities
    Map<String, int> purchasedItems = {};
    for (var section in _cartItems.entries) {
      for (var item in section.value) {
        purchasedItems[item.name] = item.quantity;
      }
    }

    // Add to purchase history
    final purchase = PurchaseHistory(
      date: DateTime.now(),
      amount: _calculateTotal(),
      items: purchasedItems,
    );

    setState(() {
      _purchaseHistory.add(purchase);
    });

    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Purchase Confirmed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
                  'Total Amount: Php ${purchase.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Items purchased:'),
                const SizedBox(height: 4),
                ...purchasedItems.entries.map(
                  (entry) => Text('• ${entry.key} (${entry.value}x)'),
            ),
          ],
        ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Clear cart
                  setState(() {
                    _cartItems.clear();
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [Icon(_titleIcon), const SizedBox(width: 8), Text(_title)],
        ),
        actions: const [
          IconButton(icon: Icon(Icons.notifications), onPressed: null),
          IconButton(icon: Icon(Icons.settings), onPressed: null),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          StocksPage(cartItems: _cartItems, onAddToCart: addToCart),
          CartPage(
            cartItems: _cartItems,
            onConfirmPurchase: _confirmPurchase,
          ),
          ActivityPage(purchaseHistory: _purchaseHistory),
          const EventsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stocks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}

class StocksPage extends StatefulWidget {
  final Map<String, List<CartItem>> cartItems;
  final Function(String section, String itemName, double price) onAddToCart;

  const StocksPage({
    super.key,
    required this.cartItems,
    required this.onAddToCart,
  });

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  final Map<String, List<Map<String, dynamic>>> _sectionItems = {
    'Bakery & Bread': [
      {'name': 'Croissant', 'quantity': 10, 'price': 45.0},
      {'name': 'Donuts', 'quantity': 15, 'price': 35.0},
      {'name': 'Grain', 'quantity': 8, 'price': 55.0},
      {'name': 'Pancakes', 'quantity': 12, 'price': 40.0},
      {'name': 'Waffles', 'quantity': 6, 'price': 50.0},
    ],
    'Dairy': [
      {'name': 'Creamer', 'quantity': 0, 'price': 25.0},
      {'name': 'Kefir', 'quantity': 0, 'price': 75.0},
      {'name': 'Milk', 'quantity': 0, 'price': 85.0},
      {'name': 'Parmesan Cheese', 'quantity': 0, 'price': 120.0},
      {'name': 'Yogurt', 'quantity': 0, 'price': 45.0},
    ],
    'Meat': [
      {'name': 'Chicken Breast', 'quantity': 20, 'price': 180.0},
      {'name': 'Ground Beef', 'quantity': 15, 'price': 220.0},
      {'name': 'Pork Chops', 'quantity': 12, 'price': 200.0},
      {'name': 'Turkey', 'quantity': 8, 'price': 250.0},
    ],
    'Seafood': [
      {'name': 'Salmon', 'quantity': 10, 'price': 350.0},
      {'name': 'Shrimp', 'quantity': 15, 'price': 280.0},
      {'name': 'Tuna', 'quantity': 20, 'price': 220.0},
      {'name': 'Crab', 'quantity': 8, 'price': 400.0},
    ],
    'Frozen Foods': [
      {'name': 'Ice Cream', 'quantity': 25, 'price': 120.0},
      {'name': 'Frozen Pizza', 'quantity': 18, 'price': 180.0},
      {'name': 'Frozen Vegetables', 'quantity': 30, 'price': 85.0},
      {'name': 'TV Dinner', 'quantity': 20, 'price': 150.0},
    ],
    'Snacks': [
      {'name': 'Potato Chips', 'quantity': 40, 'price': 45.0},
      {'name': 'Cookies', 'quantity': 35, 'price': 55.0},
      {'name': 'Popcorn', 'quantity': 25, 'price': 35.0},
      {'name': 'Nuts', 'quantity': 20, 'price': 75.0},
    ],
  };

  final Map<String, bool> _expandedSections = {
    'Bakery & Bread': true,
    'Dairy': true,
    'Meat': false,
    'Seafood': false,
    'Frozen Foods': false,
    'Snacks': false,
  };

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !(_expandedSections[section] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _sectionItems.length,
          itemBuilder: (context, index) {
            final section = _sectionItems.keys.elementAt(index);
            final color = _getColorForSection(section);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(section, color),
                if (_expandedSections[section]!) ...[
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sectionItems[section]?.length ?? 0,
                    itemBuilder: (context, itemIndex) {
                      final item = _sectionItems[section]![itemIndex];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item['name']),
                          subtitle: Text('Php ${item['price'].toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => _showQuantityDialog(section, item),
                                style: TextButton.styleFrom(
                                  backgroundColor: item['quantity'] == 0 
                                      ? Colors.red.withAlpha(26)
                                      : Colors.blue.withAlpha(26),
                                ),
                                child: Text(
                                  '${item['quantity']}',
                                  style: TextStyle(
                                    color: item['quantity'] == 0 ? Colors.red : Colors.blue,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _showDeleteDialog(section, item),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
              ],
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'add_item',
            onPressed: _showAddItemDialog,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(_getIconForSection(title), color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            _expandedSections[title]!
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: Colors.grey,
          ),
          onPressed: () => _toggleSection(title),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 20),
          color: color,
          onPressed: () {
            // Handle section settings
          },
        ),
      ],
    );
  }

  void _showQuantityDialog(String section, Map<String, dynamic> item) {
    final TextEditingController quantityController = TextEditingController(
      text: item['quantity'].toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit ${item['name']} Quantity'),
            content: TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter new quantity',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final newQuantity =
                      int.tryParse(quantityController.text) ?? 0;
                  setState(() {
                    item['quantity'] = newQuantity;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(String section, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _sectionItems[section]?.remove(item);
                if (_sectionItems[section]?.isEmpty ?? false) {
                  _sectionItems.remove(section);
                  _expandedSections.remove(section);
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['name']} has been deleted'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    String selectedSection = _expandedSections.keys.first;
    final TextEditingController itemController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(
      text: '1',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSection,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      _expandedSections.keys.map((String section) {
                        return DropdownMenuItem<String>(
                          value: section,
                          child: Text(section),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedSection = newValue;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: itemController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'Enter item name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Enter quantity',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (itemController.text.isNotEmpty) {
                    final quantity = int.tryParse(quantityController.text) ?? 0;
                    setState(() {
                      _sectionItems[selectedSection]!.add({
                        'name': itemController.text,
                        'quantity': quantity,
                        'price': 0.0,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  IconData _getIconForSection(String section) {
    switch (section) {
      case 'Bakery & Bread':
        return Icons.bakery_dining;
      case 'Dairy':
        return Icons.water_drop_outlined;
      case 'Meat':
        return Icons.restaurant;
      case 'Seafood':
        return Icons.set_meal;
      case 'Frozen Foods':
        return Icons.ac_unit;
      case 'Snacks':
        return Icons.cookie_outlined;
      default:
        return Icons.category;
    }
  }

  Color _getColorForSection(String section) {
    switch (section) {
      case 'Bakery & Bread':
        return Colors.orange;
      case 'Dairy':
        return Colors.blue;
      case 'Meat':
        return Colors.red;
      case 'Seafood':
        return Colors.lightBlue;
      case 'Frozen Foods':
        return Colors.cyan;
      case 'Snacks':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}

class CartItem {
  final String name;
  int quantity;
  final double price;

  CartItem({required this.name, required this.quantity, required this.price});
}

class CartSection {
  String title;
  IconData icon;
  Color color;
  bool isExpanded;
  List<CartItem> items;

  CartSection({
    required this.title,
    required this.icon,
    required this.color,
    this.isExpanded = true,
    required this.items,
  });
}

class CartPage extends StatefulWidget {
  final Map<String, List<CartItem>> cartItems;
  final Function() onConfirmPurchase;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onConfirmPurchase,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.cartItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.cartItems.length,
            itemBuilder: (context, index) {
              final section = widget.cartItems.keys.elementAt(index);
              final items = widget.cartItems[section]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      section,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...items.map((item) => ListTile(
                    title: Text(item.name),
                    subtitle: Text('Php ${item.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${item.quantity}x'),
                        const SizedBox(width: 8),
                        Text(
                          'Php ${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
                  if (index < widget.cartItems.length - 1)
                    const Divider(),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimated Cost:',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Text(
                    'Php ${_calculateTotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onConfirmPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM PURCHASE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var section in widget.cartItems.values) {
      for (var item in section) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }
}

class PurchaseHistory {
  final DateTime date;
  final double amount;
  final Map<String, int> items;

  PurchaseHistory({
    required this.date,
    required this.amount,
    required this.items,
  });
}

class ActivityPage extends StatefulWidget {
  final List<PurchaseHistory> purchaseHistory;

  const ActivityPage({super.key, required this.purchaseHistory});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  Map<String, double> _calculateMostUsedItems() {
    Map<String, int> totalUsage = {};

    // Calculate total usage for each item
    for (var purchase in widget.purchaseHistory) {
      purchase.items.forEach((item, quantity) {
        totalUsage[item] = (totalUsage[item] ?? 0) + quantity;
      });
    }

    // Convert to percentages
    int totalItems = totalUsage.values.fold(0, (sum, count) => sum + count);
    Map<String, double> percentages = {};

    // Sort items by usage and get top 3
    var sortedItems =
        totalUsage.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Take top 3 items and combine rest into "Others"
    double othersPercentage = 100.0;
    for (int i = 0; i < sortedItems.length; i++) {
      if (i < 3) {
        double percentage = (sortedItems[i].value / totalItems) * 100;
        percentages[sortedItems[i].key] = percentage;
        othersPercentage -= percentage;
      }
    }

    if (othersPercentage > 0) {
      percentages['Others'] = othersPercentage;
    }

    return percentages;
  }

  List<double> _calculateMonthlyExpenses() {
    Map<int, double> monthlyTotals = {};
    final now = DateTime.now();

    // Initialize last 6 months with 0
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyTotals[month.month] = 0;
    }

    // Calculate totals for each month
    for (var purchase in widget.purchaseHistory) {
      if (purchase.date.isAfter(DateTime(now.year, now.month - 6))) {
        monthlyTotals[purchase.date.month] =
            (monthlyTotals[purchase.date.month] ?? 0) + purchase.amount;
      }
    }

    // Convert to list of last 6 months
    List<double> expenses = [];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      expenses.add(monthlyTotals[month.month] ?? 0);
    }

    return expenses;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyExpenses = _calculateMonthlyExpenses();
    final mostUsedItems = _calculateMostUsedItems();
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Expenses Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Month With Most Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY:
                          monthlyExpenses.reduce((a, b) => a > b ? a : b) * 1.2,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final month = DateTime(
                                now.year,
                                now.month - 5 + value.toInt(),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat('MMM').format(month),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                'Php ${value.toInt()}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups:
                          monthlyExpenses.asMap().entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value,
                                  color:
                                      entry.key == monthlyExpenses.length - 1
                                          ? Colors.green
                                          : Colors.grey.withAlpha(51),
                                  width: 20,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Most Used Items Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Most Used Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections:
                          mostUsedItems.entries.map((entry) {
                            Color color;
                            switch (entry.key) {
                              case 'Milk':
                                color = Colors.indigo;
                                break;
                              case 'Yogurt':
                                color = Colors.orange;
                                break;
                              case 'Grain':
                                color = Colors.blue;
                                break;
                              case 'Others':
                                color = Colors.pink;
                                break;
                              default:
                                color = Colors.grey;
                            }
                            return PieChartSectionData(
                              color: color,
                              value: entry.value,
                              title:
                                  '${entry.value.toStringAsFixed(0)}%\n${entry.key}',
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  DateTime? _selectedDate;
  final Map<DateTime, bool> _shoppingDates = {};
  final TextEditingController _noteController = TextEditingController();

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _showDateConfirmationDialog(date);
  }

  void _showDateConfirmationDialog(DateTime date) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set Shopping Date'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Date: ${DateFormat('MMMM dd, yyyy').format(date)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Add a note (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _noteController.clear();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _shoppingDates[date] = true;
                  });
                  Navigator.pop(context);
                  _showConfirmationSnackBar(date);
                  _noteController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Set Date'),
              ),
            ],
          ),
    );
  }

  void _showConfirmationSnackBar(DateTime date) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Shopping reminder set for ${DateFormat('MMMM dd, yyyy').format(date)}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _checkUpcomingDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      _showShoppingReminderDialog(date);
    }
  }

  void _showShoppingReminderDialog(DateTime date) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Shopping Reminder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart, size: 48, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'Your set date is coming up, would you like the system to set the next date automatically?',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('NO'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Set next month's date
                  final nextMonth = date.add(const Duration(days: 30));
                  setState(() {
                    _shoppingDates[nextMonth] = true;
                  });
                  Navigator.pop(context);
                  _showConfirmationSnackBar(nextMonth);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('YES'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check for today's shopping date
    _shoppingDates.forEach((date, isSet) {
      if (isSet) _checkUpcomingDate(date);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText:
                  _selectedDate == null
                      ? 'Select a date'
                      : DateFormat('MM/dd/yyyy').format(_selectedDate!),
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                _selectDate(picked);
              }
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _shoppingDates.length,
            itemBuilder: (context, index) {
              final date = _shoppingDates.keys.elementAt(index);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Colors.green),
                  title: Text(
                    'Shopping Day',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('MMMM dd, yyyy').format(date),
                    style: TextStyle(
                      color:
                          date.isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.green,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _shoppingDates.remove(date);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shopping date removed'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
