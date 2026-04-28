import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
//.1 importar timer
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //control  para mostrar o ocultar contraseña
  bool _obscureText = true;

  //cerebro de la logica de la animacion
  StateMachineController? _controller;
  //State machine input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  //2.1 variable para controlar el recorrido de la mirada
  SMINumber? _numLook;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  //1.1 Crear variables para FocusNode
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();

  //3.2Timer para detener la mirada al dejar de escribir
  Timer? _typingDebounce;

  //4.1 controllers para manipular texto
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  //4.2 Errores para mostrar en UI
  String? emailError;
  String? passwordError;

  //4.3 validadores
  // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  //4.4 accion al boton
  void onLogin() {
    //De lo que escribio el usuario quita espacios
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    //recalcular errores
    final emailUIError = isValidEmail(email) ? null : 'Email no válido';
    final passwordUIError = isValidPassword(password)
        ? null
        : 'Contraseña invalida';

    //4.5 notifique cambios en la UI
    setState(() {
      emailError = emailUIError;
      passwordError = passwordUIError;
    });

    //4.6 cerrar el teclado y bajar manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0; //mirada neutra

    //4.7 activar los triggers
    if (emailUIError == null && passwordUIError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        if (_isHandsUp != null) {
          //manos abajo en el email
          _isHandsUp?.change(false);
          //2.2 mirada neutal
          _numLook?.value = 50;
        }
      }
    });
    _passwordFocusNode.addListener(() {
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      //evita nudge o camaras frontales
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: Column(
              children: [
                SizedBox(
                  width: size.width,
                  height: size.height * 0.4,
                  child: RiveAnimation.asset(
                    'animated_login_character.riv',
                    stateMachines: ["Login Machine"],
                    // al iniciansrse la animacion se ejecuta esta funcion
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );

                      //vrificae que inicio bien la animacion
                      if (_controller == null) return;
                      artboard.addController(_controller!);

                      //vinculando los input de la animacion con las variables del codigo
                      _isChecking =
                          _controller!.findSMI('isChecking') as SMIBool;
                      _isHandsUp = _controller!.findSMI('isHandsUp') as SMIBool;
                      _numLook = _controller!.findSMI('numLook') as SMINumber;
                      _trigSuccess =
                          _controller!.findSMI('trigSuccess') as SMITrigger;
                      _trigFail =
                          _controller!.findSMI('trigFail') as SMITrigger;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                //Email
                TextField(
                  //4.8 vincular controladores de texto
                  controller: emailCtrl,
                  //1.3 Vincular focus al campo de texto
                  focusNode: _emailFocusNode,

                  onChanged: (value) {
                    if (_isHandsUp != null) {
                      _isHandsUp!.change(false);
                    }
                    if (_isChecking == null) return;
                    //activar el modo chismoso
                    _isChecking!.change(true);

                    //2.4 implementar logica para el movimiento de la mirada
                    //ajustes sonde del 0 al 100.  80 medida de calibracion
                    //clamp es un rango de valores, en este caso de 0 a 100
                    final double look = (value.length / 80.0 * 100.0).clamp(
                      0,
                      100,
                    );
                    _numLook?.value = look;

                    //3.3 implementar debounce(temporizador)
                    //cancelar cualquier posible timer existente
                    _typingDebounce?.cancel();
                    //crear un nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 1), () {
                      //si se cierra la pantalla. quita el contador
                      if (!mounted) return;
                      //mirada neutra
                      _isChecking?.change(false);
                    });
                  },

                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    //4.9 mostrar error en la UI
                    errorText: emailError,
                    prefixIcon: const Icon(Icons.email),
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                //Password
                TextField(
                  //4.8 vincular controladores de texto
                  controller: passwordCtrl,
                  focusNode: _passwordFocusNode,
                  onChanged: (value) {
                    if (_isChecking != null) {
                      //_isChecking!.change(false);
                    }
                    if (_isHandsUp == null) return;
                    //_isHandsUp!.change(true);
                  },
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    //4.9 mostrar error en la UI
                    errorText: passwordError,
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 10),

                SizedBox(
                  width: size.width,
                  child: const Text(
                    "forgot password?",
                    //alinear a la derecha
                    textAlign: TextAlign.right,
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),

                SizedBox(height: 10),
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: onLogin,
                  child: Text("Login", style: TextStyle(color: Colors.white)),
                ),

                SizedBox(
                  width: size.width,
                  child: Row(
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
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

  //1.4 liberar memorea de los focus node
  @override
  void dispose() {
    //4.11 liberar memoria de los controladores de texto
    emailCtrl.dispose();
    passwordCtrl.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    //3.4 cancelar el timer al cerrar la pantalla
    _typingDebounce?.cancel();
    super.dispose();
  }
}
