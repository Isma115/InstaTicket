// #region Dashboard | Vista | Importaciones de metricas
import 'package:flutter/material.dart';

import '../../domain/models/dashboard_models.dart';
// #endregion

// #region DashboardMetricsGrid | Vista | Cuadricula de metricas principales
class DashboardMetricsGrid extends StatelessWidget {
  const DashboardMetricsGrid({
    required this.metrics,
    required this.availableWidth,
    required this.singleColumnLayout,
    super.key,
  });

  final List<DashboardMetric> metrics;
  final double availableWidth;
  final bool singleColumnLayout;

  @override
  Widget build(BuildContext context) {
    final useSingleColumnLayout = singleColumnLayout || availableWidth < 250;
    final useDenseGrid = !useSingleColumnLayout && availableWidth < 380;
    final crossAxisCount = useSingleColumnLayout
        ? 1
        : (metrics.length <= 3 && availableWidth > 330 ? metrics.length : 2);
    final spacing = useDenseGrid ? 4.0 : 10.0;
    final outerPadding = useDenseGrid ? 2.0 : 10.0;
    final aspectRatio =
        useSingleColumnLayout ? 3.3 : (useDenseGrid ? 2.15 : 1.26);

    return Padding(
      padding: EdgeInsets.all(outerPadding),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: metrics.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
        ),
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return _MetricCard(
            metric: metric,
            singleColumnLayout: useSingleColumnLayout,
            denseLayout: useDenseGrid,
          );
        },
      ),
    );
  }
}
// #endregion

// #region Dashboard | Vista | Tarjeta de metrica
// #endregion

// #region _MetricIcon | Vista | Icono circular de metrica
class _MetricIcon extends StatelessWidget {
  const _MetricIcon({
    required this.metric,
    required this.size,
    required this.iconSize,
  });

  final DashboardMetric metric;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: metric.iconBackgroundColor,
      ),
      child: Icon(
        metric.icon,
        color: metric.iconColor,
        size: iconSize,
      ),
    );
  }
}
// #endregion

// #region _MetricCard | Vista | Tarjeta de metrica
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.singleColumnLayout,
    required this.denseLayout,
  });

  final DashboardMetric metric;
  final bool singleColumnLayout;
  final bool denseLayout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final compactCard = singleColumnLayout;
    final verticalPadding = compactCard ? 12.0 : (denseLayout ? 5.0 : 14.0);
    final horizontalPadding = compactCard ? 16.0 : (denseLayout ? 8.0 : 14.0);
    final iconSize = denseLayout ? 32.0 : 38.0;
    final iconGlyphSize = denseLayout ? 17.0 : 18.0;
    final valueBottomSpacing = denseLayout ? 1.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: compactCard
          ? Row(
              children: <Widget>[
                _MetricIcon(
                  metric: metric,
                  size: iconSize,
                  iconSize: iconGlyphSize,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    metric.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  metric.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            )
          : denseLayout
              ? Row(
                  children: <Widget>[
                    _MetricIcon(
                      metric: metric,
                      size: iconSize,
                      iconSize: iconGlyphSize,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            metric.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            metric.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _MetricIcon(
                      metric: metric,
                      size: iconSize,
                      iconSize: iconGlyphSize,
                    ),
                    SizedBox(height: denseLayout ? 6 : 10),
                    Text(
                      metric.value,
                      style: (denseLayout
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: denseLayout ? 20 : null,
                      ),
                    ),
                    SizedBox(height: valueBottomSpacing),
                    Text(
                      metric.title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: denseLayout ? 11 : null,
                        height: denseLayout ? 1.0 : 1.1,
                      ),
                    ),
                  ],
                ),
    );
  }
}
// #endregion
