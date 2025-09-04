import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../error_screen.dart';


final _firebase = FirebaseAuth.instance;



class SignUpLoadingScreen extends StatefulWidget{
  const SignUpLoadingScreen({super.key,required this.userName,required this.userEmail,required this.userPassword,});

  final String userName;
  final String userEmail;
  final String userPassword;


  @override
  State<SignUpLoadingScreen> createState() {
    return _SignUpLoadingScreenState();
  }
}

class _SignUpLoadingScreenState extends State<SignUpLoadingScreen> {


  void _signingUp() async {
    try {
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: widget.userEmail, password: widget.userPassword);


      await FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid)
          .set({
        'username':widget.userName,
        'email':widget.userEmail,
      });

      await _firebase.signOut();
      await Future.delayed(const Duration(seconds: 3));
      await _firebase.signInWithEmailAndPassword(email: widget.userEmail, password: widget.userPassword);

      if(!context.mounted){
        return;
      }

      Navigator.of(context).pop();

    } on FirebaseAuthException catch (error) {
      String _errorMsg = error.message ?? "Authentication Failed!";
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx){
        return ErrorScreen(errorMsg: _errorMsg);
      }));
    }
  }

  @override
  void initState(){
    super.initState();
    _signingUp();
  }

  @override
  Widget build(context){
    return const Scaffold(
      body: SpinKitWave(
        color: Colors.white,
      ),
    );
  }
}