// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../services/khatm.dart';
import '../theme.dart';

/// Hatim ilerlemesi. Bir sayfaya gidilmek istenirse sayfa numarasını döner.
Future<int?> showKhatmSheet(
  BuildContext context, {
  required KhatmTracker khatm,
  required int totalPages,
  required int currentPage,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => KhatmSheet(
        khatm: khatm, totalPages: totalPages, currentPage: currentPage),
  );
}

String _formatDate(DateTime d) =>
    "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}";

class KhatmSheet extends StatelessWidget {
  const KhatmSheet({
    super.key,
    required this.khatm,
    required this.totalPages,
    required this.currentPage,
  });

  final KhatmTracker khatm;
  final int totalPages;
  final int currentPage;

  Future<bool> _confirm(BuildContext context, String title, String body) async {
    final pal = Palette.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style: TextStyle(color: pal.primary, fontWeight: FontWeight.bold)),
        content: Text(body, style: TextStyle(color: pal.textPrimary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text("بىكار قىلىش",
                  style: TextStyle(color: pal.textSecondary))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: pal.primary),
              child: const Text("ماقۇل")),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    return ListenableBuilder(
      listenable: khatm,
      builder: (context, _) {
        final read = khatm.readCount(totalPages);
        final progress = khatm.progress(totalPages);
        final firstUnread = khatm.firstUnread(totalPages);
        final days = DateTime.now().difference(khatm.startedAt).inDays + 1;
        final isCurrentRead = khatm.isRead(currentPage);
        final completed = khatm.completed.reversed.toList();

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                Text("خەتمە",
                    style: TextStyle(
                        color: pal.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          color: pal.primary,
                          backgroundColor: pal.primary.withValues(alpha: 0.15),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("${(progress * 100).floor()}%",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: pal.textPrimary)),
                              Text("$read / $totalPages",
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      fontSize: 13, color: pal.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${_formatDate(khatm.startedAt)} دىن باشلاپ · $days كۈن",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: pal.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "ئېكراندا 3 سېكۇنت تۇرغان بەت ئوقۇلدى دەپ ھېسابلىنىدۇ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: pal.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 16),
                if (firstUnread != null)
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context, firstUnread),
                    icon: const Icon(Icons.play_arrow),
                    label: Text("ئوقۇلمىغان بەتكە ئۆتۈش ($firstUnread)"),
                    style: FilledButton.styleFrom(backgroundColor: pal.primary),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => khatm.setRead(currentPage, !isCurrentRead),
                  icon: Icon(isCurrentRead
                      ? Icons.remove_done
                      : Icons.check_circle_outline),
                  label: Text(isCurrentRead
                      ? "$currentPage-بەتنى ئوقۇلمىدى دەپ بەلگىلەش"
                      : "$currentPage-بەتنى ئوقۇلدى دەپ بەلگىلەش"),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (await _confirm(context, "خەتمىنى تاماملاش",
                              "بۇ خەتمە تاماملاندى دەپ ساقلىنىپ، يېڭى خەتمە باشلىنىدۇ.")) {
                            khatm.completeKhatm();
                          }
                        },
                        icon: const Icon(Icons.emoji_events_outlined),
                        label: const Text("تاماملاش"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (await _confirm(context, "قايتا باشلاش",
                              "نۆۋەتتىكى خەتمىدىكى ئوقۇلغان بەتلەر ئۆچۈرۈلىدۇ.")) {
                            khatm.resetCurrent();
                          }
                        },
                        icon: const Icon(Icons.restart_alt),
                        label: const Text("قايتا باشلاش"),
                      ),
                    ),
                  ],
                ),
                if (completed.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text("تاماملانغان خەتمىلەر (${completed.length})",
                      style: TextStyle(
                          color: pal.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  for (int i = 0; i < completed.length; i++)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.emoji_events,
                          color: pal.primary, size: 20),
                      title: Text("${completed.length - i}-خەتمە",
                          style: TextStyle(color: pal.textPrimary)),
                      trailing: Text(_formatDate(completed[i]),
                          textDirection: TextDirection.ltr,
                          style: TextStyle(color: pal.textSecondary)),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
