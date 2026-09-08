import 'package:nexo/domain/unified_models.dart';

/// Regla de aprobación vigente para un estudiante.
///
/// La nota mínima aprobatoria no es la misma para todos: a mitad de 2026 se
/// anunció subirla de 11 a 13 **solo para quienes ingresaron en la matrícula
/// 2026-1**. Mientras eso no esté confirmado por resolución, la app sigue
/// aplicando la regla de siempre; el cambio está escrito y probado, pero
/// apagado detrás de [stricterConfirmed].
///
/// Existe para que el umbral viva en un único sitio. Antes estaba repetido a
/// mano como `10.5` en media docena de archivos, y con dos reglas conviviendo
/// eso se vuelve imposible de mantener.
class PassingRule {
  const PassingRule({required this.minimumGrade});

  /// Nota mínima con la que se aprueba, en la escala vigesimal.
  final int minimumGrade;

  /// La regla de toda la vida.
  static const standard = PassingRule(minimumGrade: 11);

  /// La regla anunciada para los ingresantes de 2026-1.
  static const stricter = PassingRule(minimumGrade: 13);

  /// Pásalo a `true` cuando salga la resolución. Nada más hay que tocar.
  ///
  /// Ojo al confirmarla: hay que verificar también si el redondeo se mantiene
  /// (¿aprueba un 12.5 o hace falta un 13 exacto?), porque eso cambia quién
  /// aprueba y no se deduce del anuncio.
  static bool stricterConfirmed = false;

  /// Regla aplicable en toda la app. La resuelve [resolveFrom] al cargar los
  /// periodos del estudiante; hasta entonces, la de siempre.
  static PassingRule current = standard;

  /// Umbral para comparar un promedio con decimales.
  ///
  /// Las notas se publican redondeadas, así que un 10.5 se convierte en 11 y
  /// aprueba. Por eso el umbral es medio punto por debajo del mínimo, no el
  /// mínimo exacto.
  double get threshold => minimumGrade - 0.5;

  bool passes(double? average) => average != null && average >= threshold;

  /// Regla según el periodo en que el estudiante ingresó.
  static PassingRule forEntry({int? year, int? term}) {
    if (!stricterConfirmed || year == null || term == null) return standard;
    // 2026-1 en adelante. El alcance exacto está sin confirmar: si al final
    // solo aplica a esa cohorte y no a las siguientes, la condición cambia
    // aquí y en ningún otro sitio.
    final desde2026 = year > 2026 || (year == 2026 && term >= 1);
    return desde2026 ? stricter : standard;
  }

  /// El periodo más antiguo en el que el estudiante estuvo matriculado es su
  /// cohorte de ingreso: es el dato más fiable que tenemos sin preguntar.
  static PassingRule forTerms(List<Term>? terms) {
    if (terms == null || terms.isEmpty) return standard;
    final ordenados = [...terms]
      ..sort((a, b) {
        final porAnio = a.year.compareTo(b.year);
        return porAnio != 0 ? porAnio : a.number.compareTo(b.number);
      });
    final primero = ordenados.first;
    return forEntry(year: primero.year, term: primero.number);
  }

  static void resolveFrom(List<Term>? terms) {
    current = forTerms(terms);
  }

  @override
  bool operator ==(Object other) =>
      other is PassingRule && other.minimumGrade == minimumGrade;

  @override
  int get hashCode => minimumGrade.hashCode;

  @override
  String toString() => 'PassingRule($minimumGrade)';
}
