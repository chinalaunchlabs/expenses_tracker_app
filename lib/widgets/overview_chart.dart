import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverviewChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  OverviewChart({this.seriesList, this.animate});

  factory OverviewChart.withRandomData() {
    return new OverviewChart(seriesList: _createRandomData(), animate: true);
  }

  factory OverviewChart.withData(List<OverviewData> data) {
    List<charts.Series<OverviewData, String>> series = [charts.Series<OverviewData, String>(
      id: 'Overview',
      domainFn: (OverviewData d, _) => d.title,
      measureFn: (OverviewData d, _) => d.amount,
      colorFn: (OverviewData d, _) => d.color,
      data: data
    )];

    return new OverviewChart(seriesList: series, animate: true);
  }

  @override
  Widget build(BuildContext context) {
    // For horizontal bar charts, set the [vertical] flag to false.
    return new charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      defaultRenderer: new charts.BarRendererConfig(
          minBarLengthPx: 1,
        // By default, bar renderer will draw rounded bars with a constant
        // radius of 100.
        // To not have any rounded corners, use [NoCornerStrategy]
        // To change the radius of the bars, use [ConstCornerStrategy]
          cornerStrategy: const charts.ConstCornerStrategy(5)),
    );
  }

  static List<charts.Series<OrdinalSales, String>> _createRandomData() {
    final random = new Random();

    final data = [
      new OrdinalSales('Income', random.nextInt(100)),
      new OrdinalSales('Expense', random.nextInt(100))
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }


}

class OverviewData {
  final String title; // income or expense
  final double amount;
  final charts.Color color;

  OverviewData({this.title, this.amount, color}) :
      this.color = new charts.Color(
        r: color.red, g: color.green, b: color.blue, a: color.alpha
      );
}

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}