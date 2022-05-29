import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

/*

Hız göstergesi ekranı.
Kullanıcı hız değerlerini sürekli olarak dinler ve hızdaki değişimi ekranda gösterir.
Ayrıca uygulama açıldığı andan itibaren ulaşılmış en yüksek hız değerini de gösterir.


 */

class Speedometer extends StatelessWidget {
  const Speedometer({
    Key? key,
    required this.gaugeBegin,
    required this.gaugeEnd,
    required this.velocity,
    required this.maxVelocity,
  }) : super(key: key);

  final double gaugeBegin;
  final double gaugeEnd;
  final double? velocity;
  final double? maxVelocity;

  @override
  Widget build(BuildContext context) {
    const TextStyle _annotationTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: gaugeBegin,
          maximum: gaugeEnd,
          labelOffset: 15,
          axisLineStyle: const AxisLineStyle(
            thicknessUnit: GaugeSizeUnit.factor,
            thickness: 0.03,
          ),
          majorTickStyle: const MajorTickStyle(
            length: 6,
            thickness: 4,
            color: Colors.white,
          ),
          minorTickStyle: const MinorTickStyle(
            length: 3,
            thickness: 3,
            color: Colors.white,
          ),
          axisLabelStyle: const GaugeTextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          ranges: <GaugeRange>[
            GaugeRange(
              startValue: gaugeBegin,
              endValue: gaugeEnd,
              sizeUnit: GaugeSizeUnit.factor,
              startWidth: 0.03,
              endWidth: 0.03,
              gradient: const SweepGradient(
                colors: <Color>[Colors.green, Colors.green, Colors.yellow, Colors.yellow, Colors.red],
                stops: <double>[0.0, 0.25, 0.5, 0.75, 1],
              ),
            ),
          ],
          pointers: <GaugePointer>[
            // Current Speed pointer
            NeedlePointer(
              value: maxVelocity!,
              needleLength: 0.95,
              enableAnimation: true,
              animationType: AnimationType.ease,
              needleStartWidth: 1.5,
              needleEndWidth: 6,
              needleColor: Colors.white54,
              knobStyle: const KnobStyle(knobRadius: 0.09),
            ),
            // Highest Speed pointer
            NeedlePointer(
              value: velocity!,
              needleLength: 0.95,
              enableAnimation: true,
              animationType: AnimationType.ease,
              needleStartWidth: 1.5,
              needleEndWidth: 6,
              needleColor: Colors.red,
              knobStyle: const KnobStyle(knobRadius: 0.09),
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    velocity!.toStringAsFixed(2),
                    style: _annotationTextStyle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('km/h', style: _annotationTextStyle),
                ],
              ),
              angle: 90,
              positionFactor: 0.75,
            )
          ],
        ),
      ],
    );
  }
}