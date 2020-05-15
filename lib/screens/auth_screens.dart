import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sattvik_mess/models/auth.dart';
import '../models/http_exception.dart';
enum AuthMode {Signup,Login}

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0,1]
              )
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Flexible(
                  //   child: Container(
                  //     margin: EdgeInsets.only(bottom: 20),
                  //     padding: EdgeInsets.symmetric(vertical: 8,horizontal: 94),
                  //     transform: Matrix4.rotationZ(-8*pi/180)..translate(-10.0),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(20),
                  //       color: Colors.deepOrange.shade900,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           blurRadius: 8,
                  //           color: Colors.black26,
                  //           offset: Offset(0,2)
                  //         )
                  //       ]
                  //     ),
                  //     child: Text('Sattvik Mess',
                  //       style: TextStyle(fontSize: 50),
                  //     ),
                  //   ),
                  // ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String,String> _authData = {
    'email':'',
    'password':''
  };
  bool _isLoading = false;
  final _passwordController = TextEditingController();
  String mess = 'Please select your mess';

  void _showErrorDialogue(String message){
    showDialog(context: context,builder: (context)=>AlertDialog(
      title: Text('An Error Occured'),
      content: Text(message),
      actions: <Widget>[
        FlatButton(child: Text('Okay'),onPressed: (){
          Navigator.of(context).pop();
        },)
      ],
    ));
  }

  Future<void> _submit()async{
    if(!_formKey.currentState.validate()){
      //invalid
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    
    try{
      if(_authMode == AuthMode.Login){
        //log user
        await Provider.of<Auth>(context,listen: false).login(_authData['email'], _authData['password'], mess);
      }else{
        //sign up
        await Provider.of<Auth>(context,listen: false).signUp(_authData['email'], _authData['password'],mess);
      }
    }on HttpException catch(error){
      var message = 'Authentication failed';
      if(error.toString().contains('EMAIL_EXISTS')){
        message = 'Email already in use';
      }else if(error.toString().contains('INVALID_EMAIL')){
        message = 'Please enter a valid email address';
      }else if(error.toString().contains('EMAIL_NOT_FOUND')){
        message = 'Could not find the user with that email. Please SignUp';
      }else if(error.toString().contains('WEAK_PASSWORD')){
        message = 'Your password is too weak';
      }else if(error.toString().contains('INVALID_PASSWORD')){
        message = 'Invalid password';
      }else if(error.toString().contains('Register First')){
        message = 'Register First';
      }
      _showErrorDialogue(message);
    }catch(error){
      const message = 'Could not authenticate. Please check your internet connection';
      _showErrorDialogue(message);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode(){
    if(_authMode==AuthMode.Login){
      setState(() {
        _authMode = AuthMode.Signup;
      });
    }else{
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      elevation: 8,
      child: Container(
        height: _authMode == AuthMode.Signup ? 380 : 320,
        constraints: BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width*0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value){
                    if(value.isEmpty||!value.contains('@')){
                      return 'Invalid Email';
                    }
                  },
                  onSaved: (value){
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value){
                    if(value.isEmpty||value.length<5){
                      return 'Password is too short';
                    }
                  },
                  onSaved: (value){
                    _authData['password'] = value;
                  },
                ),
                if(_authMode == AuthMode.Signup)
                TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  validator: _authMode == AuthMode.Signup?(value){
                    if(value!=_passwordController.text){
                      return 'Passwords do not match';
                    }
                  }:null,
                ),
                SizedBox(height: 20,),
                DropdownButton<String>(
                  value: mess,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(
                    color: Colors.deepPurple
                  ),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      mess = newValue;
                    });
                  },
                  items: <String>['Please select your mess', 'Mess 1', 'Mess 2']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
                ),
                SizedBox(height: 20,),
                if(_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child: Text(_authMode == AuthMode.Login?'LOGIN':'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(horizontal: 30,vertical: 8),
                    color: Theme.of(context).primaryColor,
                  ),
                  if(!_isLoading)
                  FlatButton(
                    child: Text('${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                    onPressed: _switchAuthMode,
                    padding: EdgeInsets.symmetric(horizontal: 30,vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Theme.of(context).primaryColor,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}