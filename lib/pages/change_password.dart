import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/utils/string_extensions.dart';

class ChangePassword extends StatefulWidget {
  final String userID;

  const ChangePassword({super.key, required this.userID});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();

  bool isProcessing = false;

  String _password = '';
  String _newPassword = '';
  String _confirmNewPassword = '';

  bool _passwordVisible = true;
  bool _newPasswordVisible = true;
  bool _confirmNewPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(Constants.APP_TITLE),
          centerTitle: true,

        ),
        body: SingleChildScrollView (
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox (
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        renderTextFormField(
                          context: context,
                          label: '이전 비밀 번호',
                          keyNumber: 1,
                          icon: const Icon(Icons.lock, color: Colors.grey,),
                          suffixIcon: IconButton(
                            icon: Icon( _passwordVisible ? Icons.visibility : Icons.visibility_off, ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: _passwordVisible,
                          onSaved: (val) {
                            setState(() {
                              _password = val;
                            });

                          },
                          validator: (val) {
                            if (val.length < 6 || val.length > 12) {
                              return '비밀번호는 6글자 이상 12글자 이하로 입력해 주셔야합니다.';
                            }

                            //return val.isValidPasswordFormatType1() ? null : '비밀번호는 영문(소문자, 대문자), 숫자, 특수문자로 이루어진 6 ~ 12 자리입니다.';
                            return (val as String).isValidOnlyNumber() ? null : '비밀번호는 숫자로 이루어진 6 ~ 12 자리입니다.';
                          },
                        ),

                        const SizedBox(height: 10),

                        renderTextFormField(
                          context: context,
                          label: '새로운 비밀 번호',
                          keyNumber: 2,
                          icon: const Icon(Icons.lock, color: Colors.grey,),
                          suffixIcon: IconButton(
                            icon: Icon( _newPasswordVisible ? Icons.visibility : Icons.visibility_off, ),
                            onPressed: () {
                              setState(() {
                                _newPasswordVisible = !_newPasswordVisible;
                              });
                            },
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: _newPasswordVisible,
                          onSaved: (val) {
                            setState(() {
                              _newPassword = val;
                            });
                          },
                          onChanged: (val) {
                            _confirmNewPassword = val;
                          },
                          validator: (val) {
                            if (val.length < 6 || val.length > 12) {
                              return '비밀번호는 6글자 이상 12글자 이하로 입력해 주셔야합니다.';
                            }

                            return (val as String).isValidOnlyNumber() ? null : '비밀번호는 숫자로 이루어진 6 ~ 12 자리입니다.';
                          },
                        ),

                        const SizedBox(height: 10),

                        renderTextFormField(
                          context: context,
                          label: '새로운 비밀 번호 확인',
                          keyNumber: 3,
                          icon: const Icon(Icons.lock, color: Colors.grey,),
                          suffixIcon: IconButton(
                            icon: Icon( _confirmNewPasswordVisible ? Icons.visibility : Icons.visibility_off, ),
                            onPressed: () {
                              setState(() {
                                _confirmNewPasswordVisible = !_confirmNewPasswordVisible;
                              });
                            },
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: _confirmNewPasswordVisible,
                          onSaved: (val) {},
                          validator: (val) {
                            if (val.length < 6 || val.length > 12) {
                              return '비밀번호는 6글자 이상 12글자 이하로 입력해 주셔야합니다.';
                            }

                            String value = val as String;
                            if (_confirmNewPassword != value) {
                              return "패스워드확인이 올바르지 않습니다.";
                            } else {
                              return null;
                            }
                          },
                        ),

                        const SizedBox(height: 10),

                        _processWidget(),

                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 100),
                      ],
                    ),
                  )
                ),
              )
            ),
          ),
        )
    );
  }

  Widget _processWidget() {
    if (isProcessing) {
      return const CircularProgressIndicator();
    } else {
      return MyButton(
        onTap: () { _changePassword(context); },
        text: "Change Password",
      );
    }
  }

  void _changePassword(BuildContext context) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {

      setState(() {
        isProcessing = true;
      });
      _formKey.currentState!.save();

      final response = await dio.post('/auth/changepassword',
          data: jsonEncode({
            "userID": widget.userID,
            "oldpassword": _password,
            "newpassword": _newPassword,
          })
      );

      setState(() {
        isProcessing = false;
      });

      if (!context.mounted) return;
      if (response.statusCode == 201) {
        _failureDialog(context, response.data['message']);
      } else {
        _successDialog(context, "비밀번호 변경 신청이 완료되었습니다.");
      }
    }
  }

  void _successDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("비밀번호 변경"),
              content: Text(text),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((val) {
      if (val == true) {
        Navigator.pop(context);
      }
    });
  }

  void _failureDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("비밀번호 변경"),
              content: Text(text),
              actions: <Widget>[
                TextButton(
                  child: const Text("Close"),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
