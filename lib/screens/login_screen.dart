import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //control  para mostrar o ocultar contraseña
  bool _obscureText = true;
  

  //cerebro
  StateMachineController? _controller;
  //SMI: State Machine Input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  //2.1 crear variable para el numero de mirada
  SMINumber? _numLook;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  //1.1 crear variables para focus node

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  //3.2 Timer para detener la mirada al dejar de escribir
  Timer? _typingDebounce;


  @override
  void initState() {
    super.initState();
    //1.2 agregar listeners a los focus nodes
    _emailFocusNode.addListener((){
      if(_emailFocusNode.hasFocus){
        if(_isHandsUp != null){
          _isHandsUp!.change(false);
          //2.2 mirada neutral
          _numLook?.value = 50.0;
        }
      }
    });
    _passwordFocusNode.addListener((){
      _isHandsUp?.change(_passwordFocusNode.hasFocus);   
    });
  }


  @override
  Widget build(BuildContext context) {
    final Size = MediaQuery.of(context).size;

    return Scaffold(
      //evita nudge o camaras frontales
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              SizedBox(
                width: Size.width,
                height: Size.height * 0.4,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ['Login Machine'],
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(artboard, 'Login Machine');
                    //verificar que inicio bien
                    if(_controller == null) return;
                    artboard.addController(_controller!);
                      _isChecking = _controller!.findSMI('isChecking') as SMIBool;
                      _isHandsUp = _controller!.findSMI('isHandsUp') as SMIBool;
                      _numLook = _controller!.findSMI('numLook') as SMINumber;
                      _trigSuccess = _controller!.findSMI('trigSuccess') as SMITrigger;
                      _trigFail = _controller!.findSMI('trigFail') as SMITrigger;
                  }
                ),
              ),
              const SizedBox(height: 10),
              //Email
              TextField(
                focusNode: _emailFocusNode,
                onChanged: (value){
                  if(_isHandsUp != null){
                   _isHandsUp!.change(false);
                  }
                  if(_isChecking == null) return;
                  _isChecking!.change(true);
                  //2.4 Implementar lógica
                  //Ajustes son del 0 al 100. 80 medida de calibración
                  final double look = (value.length / 80.0 * 100).clamp(0, 100);
                  _numLook?.value = look;
                  //3.1 Detener timer previo
                  _typingDebounce?.cancel();
                  //crear nuevo timer
                  _typingDebounce = Timer(const Duration(seconds: 3), (){
                    if(!mounted) return;
                    //mirada neutra
                    _isChecking?.change(false);
                    });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                  ),
      
              ),
              const SizedBox(height: 10),
              //Password
              TextField(
                focusNode: _passwordFocusNode,
                onChanged: (value){
                  if(_isChecking != null){
                    //_isChecking!.change(false);
                  }
                  if(_isHandsUp == null) return;
                  //_isHandsUp!.change(true);
                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'Password',
                  border: const OutlineInputBorder(),
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
              )
            ],
          ),
        ),
      ),
    );
  }

  //1.4 Liberar memoria al salir de la pantalla
  @override
  void dispose() {
    _typingDebounce?.cancel();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}