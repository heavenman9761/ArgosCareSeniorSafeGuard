extension InputValidate on String {
  //이메일 포맷 검증
  bool isValidEmailFormat() {
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this);
  }
  //대쉬를 포함하는 010 휴대폰 번호 포맷 검증 (010-1234-5678)
  bool isValidPhoneNumberFormat() {
    return RegExp(r'^010-?([0-9]{4})-?([0-9]{4})$').hasMatch(this);
  }

  //영문(소문자, 대문자), 숫자, 특수문자로 이루어진 n~m 자릿수
  bool isValidPasswordFormatType1() {
    return RegExp(r'^(?!((?:[A-Za-z]+)|(?:[~!@#$%^&*()_+=-]+)|(?:[0-9]+))$)[A-Za-z\d~!@#$%^&*()_+=-]{6,12}$').hasMatch(this);
  }

  //영문(소문자, 대문자), 숫자로 이루어진 n~m 자릿수
  bool isValidPasswordFormatType2() {
    return RegExp(r'^(?=.*[a-zA-z])(?=.*[0-9])(?!.*[^a-zA-z0-9]).{6,12}$').hasMatch(this);
  }

  //영문(소문자, 대문자)로 이루어진 n~m 자릿수
  bool isValidPasswordFormatType3() {
    return RegExp(r'^(?=.*[A-Za-z])[A-Za-z\d$@$!%*#?~^<>,.&+=]{6,12}$').hasMatch(this);
  }


}