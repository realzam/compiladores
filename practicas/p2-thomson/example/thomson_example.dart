import 'package:thomson/src/AF.dart';
import 'package:thomson/thomson.dart';

void main() {
  Thomson thomson = Thomson();
  String ejemplo = 'b(b|a)*c';
  AFN res = thomson.convertir(ejemplo);
  print(res);
}
