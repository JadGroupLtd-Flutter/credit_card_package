import 'package:credit_card_package/constants.dart';
import 'package:credit_card_package/credit_card_model.dart';
import 'package:credit_card_package/credit_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({
    Key? key,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    this.obscureCvv = false,
    this.obscureNumber = false,
    required this.onCreditCardModelChange,
    required this.themeColor,
    this.textColor = Colors.black,
    this.cursorColor,
    required this.errorLangMessage,
    this.cardHolderDecoration = const InputDecoration(
      labelText: 'Card holder',
    ),
    this.cardNumberDecoration = const InputDecoration(
      labelText: 'Card number',
      hintText: 'XXXX XXXX XXXX XXXX',
    ),
    this.expiryDateDecoration = const InputDecoration(
      labelText: 'Expired Date',
      hintText: 'MM/YY',
    ),
    this.cvvCodeDecoration = const InputDecoration(
      labelText: 'CVV',
      hintText: 'XXX',
    ),
    required this.formKey,
    this.cardNumberKey,
    this.cardHolderKey,
    this.expiryDateKey,
    this.cvvCodeKey,
    this.cvvValidationMessage = 'Please input a valid CVV',
    this.dateValidationMessage = 'Please input a valid date',
    this.numberValidationMessage = 'Please input a valid number',
    this.isHolderNameVisible = true,
    this.isCardNumberVisible = true,
    this.isExpiryDateVisible = true,
    this.enableCvv = true,
    this.autovalidateMode,
    this.cardNumberValidator,
    this.expiryDateValidator,
    this.cvvValidator,
    this.cardHolderValidator,
    this.onFormComplete,
    this.disableCardNumberAutoFillHints = false,
    this.textAlign,
    this.textDirection,
    this.onChanged,
  }) : super(key: key);

  /// A string indicating card number in the text field.
  final String cardNumber;

  /// A string indicating expiry date in the text field.
  final String expiryDate;

  /// A string indicating card holder name in the text field.
  final String cardHolderName;

  /// A string indicating cvv code in the text field.
  final String cvvCode;

  /// Error message string when invalid cvv is entered.
  final String cvvValidationMessage;

  /// Error message string when invalid expiry date is entered.
  final String dateValidationMessage;

  /// Error message string when invalid credit card number is entered.
  final String numberValidationMessage;

  /// Provides callback when there is any change in [CreditCardModel].
  final void Function(CreditCardModel) onCreditCardModelChange;

  /// Color of the theme of the credit card form.
  final Color themeColor;

  /// Color of text in the credit card form.
  final Color textColor;

  /// Cursor color in the credit card form.
  final Color? cursorColor;
  final String errorLangMessage;

  /// When enabled cvv gets hidden with obscuring characters. Defaults to
  /// false.
  final bool obscureCvv;

  /// When enabled credit card number get hidden with obscuring characters.
  /// Defaults to false.
  final bool obscureNumber;

  /// Allow editing the holder name by enabling this in the credit card form.
  /// Defaults to true.
  final bool isHolderNameVisible;

  /// Allow editing the credit card number by enabling this in the credit
  /// card form. Defaults to true.
  final bool isCardNumberVisible;

  /// Allow editing the cvv code by enabling this in the credit card form.
  /// Defaults to true.
  final bool enableCvv;

  /// Allows editing the expiry date by enabling this in the credit
  /// card form. Defaults to true.
  final bool isExpiryDateVisible;

  /// A form state key for this credit card form.
  final GlobalKey<FormState> formKey;

  /// Provides a callback when text field provides callback in
  /// [onEditingComplete].
  final Function? onFormComplete;

  /// A FormFieldState key for card number text field.
  final GlobalKey<FormFieldState<String>>? cardNumberKey;

  /// A FormFieldState key for card holder text field.
  final GlobalKey<FormFieldState<String>>? cardHolderKey;

  /// A FormFieldState key for expiry date text field.
  final GlobalKey<FormFieldState<String>>? expiryDateKey;

  /// A FormFieldState key for cvv code text field.
  final GlobalKey<FormFieldState<String>>? cvvCodeKey;

  /// Provides decoration to card number text field.
  final InputDecoration cardNumberDecoration;

  /// Provides decoration to card holder text field.
  final InputDecoration cardHolderDecoration;

  /// Provides decoration to expiry date text field.
  final InputDecoration expiryDateDecoration;

  /// Provides decoration to cvv code text field.
  final InputDecoration cvvCodeDecoration;

  /// Used to configure the auto validation of [FormField] and [Form] widgets.
  final AutovalidateMode? autovalidateMode;

  /// A validator for card number text field.
  final String? Function(String?)? cardNumberValidator;

  /// A validator for expiry date text field.
  final String? Function(String?)? expiryDateValidator;

  /// A validator for cvv code text field.
  final String? Function(String?)? cvvValidator;

  /// A validator for card holder text field.
  final String? Function(String?)? cardHolderValidator;

  /// A text align to manage text alignment.
  final TextAlign? textAlign;

  /// A text direction to handle typing from ltr or rtl.
  final TextDirection? textDirection;

  /// A method to handle when on change.
  final void Function(String)? onChanged;

  /// Setting this flag to true will disable autofill hints for Credit card
  /// number text field. Flutter has a bug when auto fill hints are enabled for
  /// credit card numbers it shows keyboard with characters. But, disabling
  /// auto fill hints will show correct keyboard.
  ///
  /// Defaults to false.
  ///
  /// You can follow the issue here
  /// [https://github.com/flutter/flutter/issues/104604](https://github.com/flutter/flutter/issues/104604).
  final bool disableCardNumberAutoFillHints;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;
  bool isCvvFocused = false;
  late Color themeColor;

  late void Function(CreditCardModel) onCreditCardModelChange;
  late CreditCardModel creditCardModel;

  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _cvvCodeController =
      MaskedTextController(mask: '0000');

  FocusNode cvvFocusNode = FocusNode();
  FocusNode expiryDateNode = FocusNode();
  FocusNode cardHolderNode = FocusNode();
  bool isKeyboardVisible = false;

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber;
    expiryDate = widget.expiryDate;
    cardHolderName = widget.cardHolderName;
    cvvCode = widget.cvvCode;

    creditCardModel = CreditCardModel(
        cardNumber, expiryDate, cardHolderName, cvvCode, isCvvFocused);
  }

  @override
  void initState() {
    super.initState();

    createCreditCardModel();

    _cardNumberController.text = widget.cardNumber;
    _expiryDateController.text = widget.expiryDate;
    _cardHolderNameController.text = widget.cardHolderName;
    _cvvCodeController.text = widget.cvvCode;

    onCreditCardModelChange = widget.onCreditCardModelChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);

    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    cardHolderNode.dispose();
    cvvFocusNode.dispose();
    expiryDateNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    themeColor = widget.themeColor;
    super.didChangeDependencies();
  }

  bool isEnglish(String text) {
    // Check if the text contains only ASCII characters, which might indicate English
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) > 127) {
        return false; // Contains non-ASCII character
      }
    }
    return true; // Contains only ASCII characters (potential English)
  }

  void showLanguageToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        )
        .closed
        .then((value) {
      if (context.mounted) ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: themeColor.withOpacity(0.8),
        primaryColorDark: themeColor,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          children: <Widget>[
            Visibility(
              visible: widget.isCardNumberVisible,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
                child: TextFormField(
                  key: widget.cardNumberKey,
                  obscureText: widget.obscureNumber,
                  controller: _cardNumberController,
                  textAlign: TextAlign.left, // Aligns text to the left
                  textDirection: TextDirection.ltr,
                  onChanged: (String value) {
                    if (isKeyboardVisible && !isEnglish(value)) {
                      showLanguageToast(widget.errorLangMessage);
                    } else {
                      setState(() {
                        cardNumber = _cardNumberController.text;

                        creditCardModel.cardNumber = cardNumber;
                        onCreditCardModelChange(creditCardModel);
                      });
                    }
                  },
                  cursorColor: widget.cursorColor ?? themeColor,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(expiryDateNode);
                  },
                  style: TextStyle(
                    color: widget.textColor,
                  ),
                  decoration: widget.cardNumberDecoration,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: widget.disableCardNumberAutoFillHints
                      ? null
                      : const <String>[AutofillHints.creditCardNumber],
                  autovalidateMode: widget.autovalidateMode,
                  validator: widget.cardNumberValidator ??
                      (String? value) {
                        // Validate less that 13 digits +3 white spaces
                        if (value!.isEmpty || value.length < 16) {
                          return widget.numberValidationMessage;
                        }
                        return null;
                      },
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Visibility(
                  visible: widget.isExpiryDateVisible,
                  child: Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      margin:
                          const EdgeInsets.only(left: 16, top: 8, right: 16),
                      child: TextFormField(
                        key: widget.expiryDateKey,
                        textAlign: TextAlign.left, // Aligns text to the left
                        textDirection: TextDirection.ltr,
                        controller: _expiryDateController,
                        onChanged: (String value) {
                          if (isKeyboardVisible && !isEnglish(value)) {
                            showLanguageToast(widget.errorLangMessage);
                          } else {
                            if (_expiryDateController.text
                                .startsWith(RegExp('[2-9]'))) {
                              _expiryDateController.text =
                                  '0' + _expiryDateController.text;
                            }
                            setState(() {
                              expiryDate = _expiryDateController.text;
                              creditCardModel.expiryDate = expiryDate;
                              onCreditCardModelChange(creditCardModel);
                            });
                          }
                        },
                        cursorColor: widget.cursorColor ?? themeColor,
                        focusNode: expiryDateNode,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(cvvFocusNode);
                        },
                        style: TextStyle(
                          color: widget.textColor,
                        ),
                        decoration: widget.expiryDateDecoration,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[
                          AutofillHints.creditCardExpirationDate
                        ],
                        validator: widget.expiryDateValidator ??
                            (String? value) {
                              if (value!.isEmpty) {
                                return widget.dateValidationMessage;
                              }
                              final DateTime now = DateTime.now();
                              final List<String> date =
                                  value.split(RegExp(r'/'));
                              final int month = int.parse(date.first);
                              final int year = int.parse('20${date.last}');
                              final int lastDayOfMonth = month < 12
                                  ? DateTime(year, month + 1, 0).day
                                  : DateTime(year + 1, 1, 0).day;
                              final DateTime cardDate = DateTime(
                                  year, month, lastDayOfMonth, 23, 59, 59, 999);

                              if (cardDate.isBefore(now) ||
                                  month > 12 ||
                                  month == 0) {
                                return widget.dateValidationMessage;
                              }
                              return null;
                            },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Visibility(
                    visible: widget.enableCvv,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      margin:
                          const EdgeInsets.only(left: 16, top: 8, right: 16),
                      child: TextFormField(
                        key: widget.cvvCodeKey,
                        obscureText: widget.obscureCvv,
                        textAlign: TextAlign.left, // Aligns text to the left
                        textDirection: TextDirection.ltr,
                        focusNode: cvvFocusNode,
                        controller: _cvvCodeController,
                        cursorColor: widget.cursorColor ?? themeColor,
                        onEditingComplete: () {
                          if (widget.isHolderNameVisible)
                            FocusScope.of(context).requestFocus(cardHolderNode);
                          else {
                            FocusScope.of(context).unfocus();
                            onCreditCardModelChange(creditCardModel);
                            widget.onFormComplete?.call();
                          }
                        },
                        style: TextStyle(
                          color: widget.textColor,
                        ),
                        decoration: widget.cvvCodeDecoration,
                        keyboardType: TextInputType.number,
                        textInputAction: widget.isHolderNameVisible
                            ? TextInputAction.next
                            : TextInputAction.done,
                        autofillHints: const <String>[
                          AutofillHints.creditCardSecurityCode
                        ],
                        onChanged: (String text) {
                          if (isKeyboardVisible && !isEnglish(text)) {
                            showLanguageToast(widget.errorLangMessage);
                          } else {
                            setState(() {
                              cvvCode = text;
                              creditCardModel.cvvCode = cvvCode;
                              onCreditCardModelChange(creditCardModel);
                            });
                          }
                        },
                        validator: widget.cvvValidator ??
                            (String? value) {
                              if (value!.isEmpty || value.length < 3) {
                                return widget.cvvValidationMessage;
                              }
                              return null;
                            },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: widget.isHolderNameVisible,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                child: TextFormField(
                  key: widget.cardHolderKey,
                  controller: _cardHolderNameController,
                  textAlign: widget.textAlign ?? TextAlign.start,
                  textDirection: widget.textDirection,
                  onChanged: widget.onChanged ?? (String value) {
                    setState(() {
                       cardHolderName = _cardHolderNameController.text;
                       creditCardModel.cardHolderName = cardHolderName;
                       onCreditCardModelChange(creditCardModel);
                    });
                  },
                  cursorColor: widget.cursorColor ?? themeColor,
                  focusNode: cardHolderNode,
                  style: TextStyle(
                    color: widget.textColor,
                  ),
                  decoration: widget.cardHolderDecoration,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.creditCardName],
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    onCreditCardModelChange(creditCardModel);
                    widget.onFormComplete?.call();
                  },
                  validator: widget.cardHolderValidator,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeyboardInputDirectionalityAwareWidget extends StatelessWidget {
  const KeyboardInputDirectionalityAwareWidget({
    required this.controller,
    required this.child,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final text = value.text;
        return Directionality(
          textDirection: text.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      child: child,
    );
  }
}



