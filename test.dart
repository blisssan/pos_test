import 'payment_terminal_service.dart';
void main(){
  PaymentTerminalService.instance.makePayment(100).listen((event) {
    print(event);
  });
}