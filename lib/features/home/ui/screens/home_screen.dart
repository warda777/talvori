import 'package:flutter/material.dart';
import 'package:talvori/features/home/ui/widgets/top_bar.dart';
import 'package:talvori/features/home/ui/widgets/word_card.dart' as wc;
import 'package:talvori/features/home/ui/widgets/bottom_nav.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/home/ui/screens/profile_screen.dart';
import 'package:talvori/features/words/ui/screens/vocab_sort_screen.dart';
import 'package:talvori/features/words/ui/screens/my_words_screen.dart';
import 'package:talvori/features/push/data/daily_picks_store.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

import 'dart:async';
import 'dart:convert';
// import 'package:share_handler/share_handler.dart'; // Temporär deaktiviert für Web-Build
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:app_links/app_links.dart';
import 'package:talvori/core/browser_return_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/last_shared_word_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  // Share-Listener (temporär deaktiviert für Web-Build)
  // StreamSubscription<SharedMedia>? _shareSub;
  // final _share = ShareHandlerPlatform.instance;
  StreamSubscription<String>? _savedUrlSub;

  // UI-State
  bool _imageExpanded = false;
  bool _imageIsDark = false;
  bool _categoriesActive = false;

  final String _currentWord = 'to assume';

  // Repo + Live-Zähler „My Words“
  final SupabaseWordRepository _wordRepo = SupabaseWordRepository();
  int _myWordsCount = 0;

  Future<void> _refreshMyWordsCount() async {
    try {
      final c = await _wordRepo.countMyWords();
      if (!mounted) return;
      setState(() => _myWordsCount = c);
    } catch (_) {
      // z. B. nicht eingeloggt → still
    }
  }

  void _toggleImage() => setState(() => _imageExpanded = !_imageExpanded);
  void _setImageDark(bool v) => setState(() => _imageIsDark = v);

  // Deep-Linking
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linksSub;

  // Helper
  bool _looksLikePdf(String url) => url.toLowerCase().trim().endsWith('.pdf');

  // URL aus geteiltem Text extrahieren und speichern
  Future<void> _captureUrlIfPresent(String text) async {
    final m = RegExp(r'(https?:\/\/[^\s<>()\[\]]+)').firstMatch(text);
    if (m != null) {
      await BrowserReturnService.setLastUrl(m.group(1)!);
    }
  }

  // Erstes markiertes Wort aus dem geteilten Text extrahieren
  String? _extractMarkedWord(String text) {
    debugPrint('🔍 _extractMarkedWord input: "$text"');
    
    // Entferne URLs und extrahiere nur den Text vor der URL
    final urlPattern = RegExp(r'https?://[^\s]+');
    final textWithoutUrl = text.replaceAll(urlPattern, '').trim();
    
    debugPrint('🔍 Text ohne URL: "$textWithoutUrl"');
    
    // Wenn der Text leer ist, versuche das erste Wort aus dem gesamten Text zu extrahieren
    final sourceText = textWithoutUrl.isEmpty ? text : textWithoutUrl;
    
    final matches = RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ'-]+")
        .allMatches(sourceText)
        .map((m) => m.group(0)!)
        .toList();
    
    debugPrint('🔍 Gefundene Wörter: $matches');
    
    if (matches.isEmpty) return null;
    
    // Nimm das ERSTE Wort (das markierte Wort), nicht das letzte
    final result = matches.first;
    debugPrint('🔍 Extrahieres Wort: "$result"');
    return result;
  }

  // ===== Android: „Teilen an App“ einhängen =====

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final user = Supabase.instance.client.auth.currentUser;
    debugPrint('AUTH USER: ${user?.id}');

    // 1) Laufende Shares (temporär deaktiviert für Web-Build)
    /*
    _shareSub = _share.sharedMediaStream.listen((SharedMedia media) {
      final text = media.content?.trim();
      if (text != null && text.isNotEmpty) {
        _handleIncomingShare(text);
      }
    });

    // 2) Initial (App via Share gestartet)
    _share.getInitialSharedMedia().then((media) {
      final text = media?.content?.trim();
      if (text != null && text.isNotEmpty) {
        _handleIncomingShare(text);
      }
    });
    */

    // AppLinks initialisieren
    _appLinks = AppLinks();

    // 1) Initialer Link (App via Share geöffnet)
    _appLinks.getInitialLink().then((uri) {
      final t = uri?.queryParameters['text']?.trim();
      if (t != null && t.isNotEmpty) {
        _handleIncomingShare(t);
      }
    });

    _savedUrlSub = BrowserReturnService.onSavedUrl.listen((url) {
      if (!mounted) return;
      final isPdf = _looksLikePdf(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isPdf ? 'PDF-Position gespeichert'
                                : 'Seitenposition gespeichert')),
      );
    });

    // 2) Laufende Links (App bereits offen)
    _linksSub = _appLinks.uriLinkStream.listen((uri) {
      final t = uri.queryParameters['text']?.trim();
      if (t != null && t.isNotEmpty) {
        _handleIncomingShare(t);
      }
    });

    _refreshMyWordsCount();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Zurück aus Chrome/Share → Wort neu laden
      ref.invalidate(lastSharedWordProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linksSub?.cancel(); // Deep Link stream
    // _shareSub?.cancel(); // Android Share stream (temporär deaktiviert)
    _savedUrlSub?.cancel();
    super.dispose();
  }

  Future<void> _handleIncomingShare(String raw) async {
    final text = raw.trim();
    if (text.isEmpty) return;

    // URL aus dem geteilten Text abgreifen (falls vorhanden)
    await _captureUrlIfPresent(text);

    // markiertes Wort persistieren (+ UI refresh)
    final markedWord = _extractMarkedWord(text);
    if (markedWord != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_shared_word', markedWord);
      if (mounted) {
        ref.invalidate(lastSharedWordProvider);
      }
    }

    final sb = Supabase.instance.client;

    // 1) Login sicherstellen (nutzt TEST_EMAIL/TEST_PASSWORD aus .env, wenn kein User)
    if (sb.auth.currentUser == null) {
      final email = dotenv.env['TEST_EMAIL'];
      final pw = dotenv.env['TEST_PASSWORD'];
      if (email != null && pw != null && email.isNotEmpty && pw.isNotEmpty) {
        try {
          await sb.auth.signInWithPassword(email: email, password: pw);
          if (mounted) {
            await _refreshMyWordsCount();
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login fehlgeschlagen: $e')),
          );
          return;
        }
      }
    }

    // 2) Token holen (falls nötig frisch)
    var session = sb.auth.currentSession;
    session ??= await sb.auth.refreshSession().then((_) => sb.auth.currentSession);
    final token = session?.accessToken;

    // — Direkt an Functions-Domain posten —
    final functionsUrl =
        'https://naplllscmpqexahxtbwg.functions.supabase.co/ingest_word';

    try {
      final resp = await http.post(
        Uri.parse(functionsUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'text': text,
          'fromLang': 'EN',
          'toLang': 'DE',
        }),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final added = (data['text'] as String?) ?? _currentWord;
        final tr = (data['translation'] as String?) ?? '—';
        final wasNew = (data['wasNewWord'] as bool?) ?? false;

        final msg =
            wasNew ? 'Hinzugefügt: $added — $tr' : 'Schon vorhanden: $added — $tr';

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

        await _refreshMyWordsCount();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share-Fehler: $e')),
      );
    }
  }

  // ===== Ende Android-Share =====

  void _todo(BuildContext ctx, String what) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$what – TODO')));
  }

  // Picker für „Practice“ (Course / Vocab)
  void _showPracticePicker(BuildContext context) {
    const double btnWidth = 140;
    const double btnHeight = 52;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        final bottomInset = MediaQuery.of(ctx).padding.bottom;
        const navBottomPadding = 12.0;
        const overlapAdjust = 6.0;
        final bottom = bottomInset + navBottomPadding + overlapAdjust;

        final ButtonStyle pillTonal = FilledButton.styleFrom(
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          shape: const StadiumBorder(),
          padding: EdgeInsets.zero,
          minimumSize: const Size(btnWidth, btnHeight),
          fixedSize: const Size(btnWidth, btnHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );

        const TextStyle labelStyle =
            TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.2);

        return Stack(
          children: [
            // Tap außerhalb schließt
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(ctx),
              ),
            ),
            // Buttons unten
            Positioned(
              left: 0,
              right: 0,
              bottom: bottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // COURSE (oben)
                  SizedBox(
                    width: btnWidth,
                    height: btnHeight,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CourseScreen()),
                        );
                      },
                      style: pillTonal,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_rounded, size: 22),
                          SizedBox(width: 8),
                          Text('course', style: labelStyle),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // VOCAB (unten)
                  SizedBox(
                    width: btnWidth,
                    height: btnHeight,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const VocabScreen()),
                        );
                      },
                      style: pillTonal,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 22),
                          SizedBox(width: 8),
                          Text('vocab', style: labelStyle),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCategoryPopup(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const gold = Color(0xFFF1C86B);

    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        final ButtonStyle pill = FilledButton.styleFrom(
          backgroundColor: cs.surfaceContainerHighest,
          foregroundColor: cs.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: EdgeInsets.zero,
          fixedSize: const Size(110, 48),
          minimumSize: const Size(110, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );

        final Widget content = Material(
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: gold, width: 1.6),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Category',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _todo(context, 'All words');
                      },
                      style: pill,
                      child: const Text('All words'),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final nav = Navigator.of(context);
                        Future.microtask(() async {
                          await nav.push(
                            MaterialPageRoute(builder: (_) => const MyWordsScreen()),
                          );
                          if (!context.mounted) return;
                          await _refreshMyWordsCount();
                        });
                      },
                      style: pill,
                      child: const Text('My words'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _todo(context, 'Favorites');
                      },
                      style: pill,
                      child: const Text('Favorites'),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _todo(context, 'Daily picks');
                      },
                      style: pill,
                      child: const Text('Daily picks'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Word hub (tap -> WordHubScreen)
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WordHubScreen()),
                      );
                    },
                    child: Container(
                      width: 232,
                      height: 103,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
                      ),
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Word hub',
                        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.9)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // CTA
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 180,
                    height: 40,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _todo(context, 'Make your own mix');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text('Make your own mix'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return Stack(
          children: [
            // Tap außerhalb schließt
            PositionedFill(
              onTapOutside: () => Navigator.pop(ctx),
            ),
            Builder(
              builder: (context) {
                const double navBtn = 52;
                const double navPad = 12;
                const double leftPad = 16;
                const double gap = 10;
                const double offsetX = 8;
                const double offsetY = 32;

                final bottomInset = MediaQuery.of(context).padding.bottom;
                final double baseBottom = bottomInset + navPad + navBtn + gap;

                final double posLeft = leftPad + offsetX;
                final double posBottom = baseBottom + offsetY;

                final screen = MediaQuery.of(context).size;
                final safeLeft = posLeft.clamp(0.0, screen.width - 280);
                final safeBottom = posBottom.clamp(8.0, screen.height - 415 - 8);

                return Positioned(
                  left: safeLeft,
                  bottom: safeBottom,
                  child: SizedBox(
                    width: 280,
                    height: 415,
                    child: content,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: DailyPicksStore.I,
                builder: (context, _) {
                  final count = DailyPicksStore.I.items.length;
                  final max = DailyPicksStore.I.maxCount;

                  return HomeTopBar(
                    onAllWords: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VocabSortScreen()),
                    ),
                    onRewards: () => _todo(context, 'Rewards/Leaderboard/Stats'),
                    onProgressTap: () => _todo(context, 'Daily picks settings'),
                    selected: count,
                    max: max,
                    showProgress: count < max,
                  );
                },
              ),
              const SizedBox(height: 16),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: LayoutBuilder(
                    builder: (ctx, box) {
                      final w = box.maxWidth;
                      final h = w * (570 / 360);

                      return SizedBox(
                        width: w,
                        height: h,
                        child: wc.WordCard(
                          key: ValueKey((_imageIsDark, _imageExpanded)),
                          initialWord: null, // WordCard verwendet lastSharedWordProvider
                          onQuickSend: () async {
                            // Aktuelles Wort aus dem Provider holen
                            final currentWord = await ref.read(lastSharedWordProvider.future) ?? 'to assume';
                            final res = DailyPicksStore.I.add(currentWord);
                            
                            // Context nach await prüfen
                            if (!context.mounted) return;
                            
                            switch (res) {
                              case AddResult.ok:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Added to today's picks")),
                                );
                                break;
                              case AddResult.duplicate:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Already in today\'s picks')),
                                );
                                break;
                              case AddResult.full:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Limit reached (${DailyPicksStore.I.maxCount})')),
                                );
                                break;
                              case AddResult.invalid:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cannot add empty word')),
                                );
                                break;
                            }
                          },
                          isImageExpanded: _imageExpanded,
                          onToggleImage: _toggleImage,
                          isImageDark: _imageIsDark,
                          onImageBrightnessChanged: _setImageDark,
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 16),

                          userWordCount: _myWordsCount,
                          onCountTap: () async {
                            final nav = Navigator.of(context); // vor await
                            await nav.push(
                              MaterialPageRoute(builder: (_) => const MyWordsScreen()),
                            );
                            if (!context.mounted) return;
                            await _refreshMyWordsCount();
                          },
                          onSpeak: () => _todo(context, 'Speak word'),
                          onMarkWords: () => _todo(context, 'Open Mark Words (web)'),
                          onGo: () => _todo(context, 'Start: My Words practice'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: HomeBottomNav(
            onCategories: () {
              setState(() => _categoriesActive = true);
              _showCategoryPopup(context).whenComplete(() {
                if (!mounted) return;
                setState(() => _categoriesActive = false);
              });
            },
            onPractice: () => _showPracticePicker(context),
            onProfile: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            categoriesActive: _categoriesActive,
          ),
        ),
      ),
    );
  }
}

/// Kleiner Helfer um „Tap außerhalb“ ohne Boilerplate zu ermöglichen.
class PositionedFill extends StatelessWidget {
  final VoidCallback onTapOutside;
  const PositionedFill({super.key, required this.onTapOutside});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTapOutside,
      ),
    );
  }
}
