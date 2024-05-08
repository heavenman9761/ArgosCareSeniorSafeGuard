import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:argoscareseniorsafeguard/utils/string_extensions.dart';
import 'package:argoscareseniorsafeguard/pages/change_password.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _id = '';
  String _email = '';
  String _password = '';
  String _name = '';
  String _protectPeople = '';
  String _addr_zip = '';
  String _addr = '';
  String _mobile_phone = '';
  String _tel = '';
  String _snsId = '';
  String _provider = '';
  bool _admin = false;
  String _shareKey = '';

  final int _kind_id = 1;
  final int _kind_email = 2;
  final int _kind_name = 3;
  final int _kind_mobilePhone = 4;
  final int _kind_tel = 5;
  final int _kind_addrZip = 6;
  final int _kind_addr = 7;
  final int _kind_shareKey = 8;
  final int _kind_protectedPeople = 9;

  @override
  void initState() {
    super.initState();

    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(Constants.APP_TITLE),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: "Menu",
              color: Colors.blue,
              onPressed: () {
                _confirmDialog(context);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                          children: [
                            _getWidgetOnlyCopy(_id, _kind_id),

                            _getWidgetOnlyCopy(_email, _kind_email),

                            _getWidget(_name, _kind_name),

                            _getWidget(_mobile_phone, _kind_mobilePhone),

                            _getWidget(_tel, _kind_tel),

                            _getWidget(_addr_zip, _kind_addrZip),

                            _getWidget(_addr, _kind_addr),

                          ]
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        children: [
                          _getWidgetOnlyCopy(_shareKey, _kind_shareKey),

                          _getWidget(_protectPeople, _kind_protectedPeople),
                        ],
                      ),
                    ),
                    _getChangePasswordWidget(),

                    _getLoginProviderWidget(),

                  ],
                ),
              ),
            )
          )
        )
    );
  }

  Widget _getChangePasswordWidget() {
    if (_provider == '') {
      return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 8),
                Text("비밀번호 변경", style: TextStyle(fontSize: deviceFontSize, color: Colors.redAccent),),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 8, height: 50),
                      GestureDetector(
                        onTap: () { _goChangePassword(); },
                        child: const Icon(Icons.edit, size: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 8)
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }

  }

  Widget _getLoginProviderWidget() {
    if (_provider != '') {
      return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 8),
                Text("로그인 경로", style: TextStyle(fontSize: deviceFontSize),),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 8, height: 50),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Text(_provider, style: TextStyle(fontSize: deviceFontSize -2, color: Colors.grey), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
                      ),
                      const SizedBox(width: 8)
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }

  }

  Widget _getWidgetOnlyCopy(String value, int kind) {
    String label = '';
    if (kind == _kind_id) {
      label = "ID";
    } else if (kind == _kind_email) {
      label = "이메일";
    } else if (kind == _kind_shareKey) {
      label = "공유키";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: deviceFontSize),),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(value, style: TextStyle(fontSize: deviceFontSize -2, color: Colors.grey), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
              ),

              const SizedBox(width: 8, height: 50),
              GestureDetector(
                onTap: () { _copyProperty(value); },
                child: const Icon(Icons.copy, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 8)
            ],
          ),
        )
      ],
    );
  }

  Widget _getWidget(String value, int kind) {
    String label = '';

    if (kind == _kind_name) { label = "이름"; }
    else if (kind == _kind_mobilePhone) { label = "핸드폰번호"; }
    else if (kind == _kind_tel) { label = "전화번호"; }
    else if (kind == _kind_addrZip) { label = "우편번호"; }
    else if (kind == _kind_addr) { label = "주소"; }
    else if (kind == _kind_protectedPeople) { label = "피보호자명"; }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: deviceFontSize),),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(value, style: TextStyle(fontSize: deviceFontSize -2, color: Colors.grey), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
              ),
              const SizedBox(width: 8, height: 50),
              GestureDetector(
                onTap: () { _copyProperty(value); },
                child: const Icon(Icons.copy, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => { _editProperty(context, kind, value) },
                child: const Icon(Icons.edit, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 8)
            ],
          ),
        )

      ],
    );
  }

  void _loadUserInfo() async {
    const storage = FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    _id = (await storage.read(key: 'ID'))!;
    _email = (await storage.read(key: 'EMAIL'))!;
    _password = (await storage.read(key: 'PASSWORD'))!;

    final SharedPreferences pref = await SharedPreferences.getInstance();
    _name = pref.getString("name")!;
    _protectPeople = pref.getString("protectPeople")!;
    _addr_zip = pref.getString("addr_zip")!;
    _addr = pref.getString("addr")!;
    _mobile_phone = pref.getString("mobilephone")!;
    _tel = pref.getString("tel")!;
    _snsId = pref.getString("snsId")!;
    _provider = pref.getString("provider")!;
    _admin = pref.getBool("admin")!;
    _shareKey = pref.getString("shareKey")!;

    if (_provider != '') {
      _email = "";
    }

    setState(() {

    });

  }

  void _confirmDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return AlertDialog(
                    title: const Text("변경사항을 저장할까요?"),
                    actions: [
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
                    ]
                );
              }
          );
        }
    ).then((val) {
      if (val) {
        _saveProfile();
      }
    });
  }

  void _saveProfile() async {
    final response = await dio.put(
        "/users",
        queryParameters: {
          "id": _id,
          "email": _email,
          "name": _name,
          "protectPeople": _protectPeople,
          "addr_zip": _addr_zip,
          "addr": _addr,
          "mobilephone": _mobile_phone,
          "tel": _tel,
          "snsId": _snsId,
          "provider": _provider,
          "admin": _admin,
          "shareKey": _shareKey,
        }
    );

    final SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setString("name", response.data['name']);
    pref.setString("protectPeople", response.data['protectPeople']);
    pref.setString("addr_zip", response.data['addr_zip']);
    pref.setString("addr", response.data['addr']);
    pref.setString("mobilephone", response.data['mobilephone']);
    pref.setString("tel", response.data['tel']);
    pref.setString("snsId", response.data['snsId']);
    pref.setString("provider", response.data['provider']);
    pref.setBool("admin", response.data['admin']);
    pref.setString("shareKey", response.data['shareKey']);

    _loadUserInfo();
  }

  void _copyProperty(String value) {
    Clipboard.setData(ClipboardData(text: value));
  }

  void _editProperty(BuildContext context, int kind, String oldValue) {
    String label = '';

    if (kind == _kind_name) { label = "이름 변경"; }
    else if (kind == _kind_mobilePhone) { label = "핸드폰번호 변경"; }
    else if (kind == _kind_tel) { label = "전화번호 변경"; }
    else if (kind == _kind_addrZip) { label = "우편번호 변경"; }
    else if (kind == _kind_addr) { label = "주소 변경"; }
    else if (kind == _kind_protectedPeople) { label = "피보호자명 변경"; }

    final controller = TextEditingController(text: oldValue);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: oldValue.length,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(label),
              content: TextFormField(
                controller: controller,
                autofocus: true,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context, controller.text);
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((val) {
      if (val != null) {
        String value = val;
        setState(() {
          if (kind == _kind_name) {
            _name = val;
          }
          else if (kind == _kind_mobilePhone) {
            if (value.isValidPhoneNumberFormat()) {
              _mobile_phone = val;
            } else {
              _showErrorMessage(context, "핸드폰 번호 형식이 아닙니다.");
            }
          }
          else if (kind == _kind_tel) {
            if (value.isValidTelNumberFormat()) {
              _tel = val;
            } else {
              _showErrorMessage(context, "전화 번호 형식이 아닙니다.");
            }
          }
          else if (kind == _kind_addrZip) {
            if (value.isValidZipAddrNumberFormat()) {
              _addr_zip = val;
            } else {
              _showErrorMessage(context, "우편 번호 형식이 아닙니다.");
            }
          }
          else if (kind == _kind_addr) {
            _addr = val;
          }
          else if (kind == _kind_protectedPeople) {
            _protectPeople = val;
          }
        });
      }
    });
  }

  void _showErrorMessage(BuildContext context, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(msg),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _goChangePassword() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) {
          return ChangePassword(userID: _id);
        })
    );
  }
}
