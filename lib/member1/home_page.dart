import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'widgets/sidebar.dart';
import '../member2/cpu/cpu_page.dart';
import '../member2/page_replacement/page_replacement_page.dart';
import '../member3/memory/memory_page.dart';
import '../member3/deadlock/deadlock_page.dart';
import '../member3/disk/disk_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _ambient = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();

  @override
  void dispose() { _ambient.dispose(); super.dispose(); }

  void _selectPage(int index) { HapticFeedback.selectionClick(); setState(() => _selectedIndex = index); }

  Widget _page() => switch (_selectedIndex) {
    1 => const CpuPage(),
    2 => const PageReplacementPage(),
    3 => const MemoryPage(),
    4 => const DeadlockPage(),
    5 => const DiskPage(),
    _ => _dashboard(),
  };

  Widget _dashboard() {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 1260 ? 3 : width > 760 ? 2 : 1;
    final modules = <_ModuleInfo>[
      _ModuleInfo('CPU scheduling', 'Watch processes compete for the processor.', Icons.memory_rounded, AppTheme.cyan, 'FCFS · SJF · SRTF · Priority · Round Robin', 1),
      _ModuleInfo('Page replacement', 'See memory frames respond to every page request.', Icons.layers_rounded, AppTheme.blue, 'FIFO · LRU · Optimal', 2),
      _ModuleInfo('Memory management', 'Compare placement strategies and fragmentation.', Icons.storage_rounded, AppTheme.violet, 'First Fit · Best Fit · Worst Fit', 3),
      _ModuleInfo('Deadlock lab', 'Test whether a resource state is safe.', Icons.account_tree_rounded, const Color(0xFFFFB86B), "Banker's safety algorithm", 4),
      _ModuleInfo('Disk scheduling', 'Trace the head as it serves a request queue.', Icons.album_rounded, const Color(0xFFFF7FA6), 'FCFS · SSTF · SCAN · C-SCAN · LOOK', 5),
    ];
    return AnimatedBuilder(
      animation: _ambient,
      builder: (context, _) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(width < 700 ? 18 : 36, 24, width < 700 ? 18 : 36, 44),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1280), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _hero(_ambient.value),
          const SizedBox(height: 28),
          Row(children: [const _SectionLabel('SIMULATION MODULES'), const Spacer(), Text('05 interactive labs', style: TextStyle(color: Colors.white.withValues(alpha: .48), fontSize: 12))]),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: modules.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, mainAxisExtent: 168),
            itemBuilder: (context, index) => _ModuleTile(info: modules[index], delay: index * 75, onTap: () => _selectPage(modules[index].index)),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _footnote(Icons.auto_awesome_rounded, 'Built for exploration', 'Change inputs and compare how each algorithm behaves.')),
            if (width > 700) const SizedBox(width: 14),
            if (width > 700) Expanded(child: _footnote(Icons.school_rounded, 'Made for OS concepts', 'Every visual maps back to a core operating systems idea.')),
          ]),
        ]))),
      ),
    );
  }

  Widget _hero(double t) => Container(
    width: double.infinity, height: 272, clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF142A3D), Color(0xFF151A36), Color(0xFF201636)], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: Colors.white.withValues(alpha: .09))),
    child: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _CircuitPainter(t))),
      Positioned(right: 20, top: -90, child: Container(width: 290, height: 290, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.cyan.withValues(alpha: .15), Colors.transparent])))),
      Padding(padding: const EdgeInsets.fromLTRB(30, 28, 24, 26), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: AppTheme.cyan.withValues(alpha: .1), borderRadius: BorderRadius.circular(30), border: Border.all(color: AppTheme.cyan.withValues(alpha: .23))), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 7, color: AppTheme.cyan), SizedBox(width: 8), Text('SYSTEM ONLINE  /  OS LAB', style: TextStyle(color: AppTheme.cyan, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800))])),
        const Spacer(),
        const Text('See the invisible\nwork of an OS.', style: TextStyle(fontSize: 36, height: 1.08, letterSpacing: -1.2, fontWeight: FontWeight.w800, color: Color(0xFFF3F6FF))),
        const SizedBox(height: 11),
        Text('Five visual labs. Real algorithms. Your inputs.', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: .68))),
        const Spacer(),
      ])),
      Positioned(right: 34, bottom: 33, child: SizedBox(width: 195, height: 195, child: CustomPaint(painter: _CorePainter(t)))),
    ]),
  );

  Widget _footnote(IconData icon, String title, String text) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFF0E1625), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: .06))), child: Row(children: [Icon(icon, color: AppTheme.cyan, size: 20), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(text, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: .52)))]))]));

  String _title => const ['Dashboard', 'CPU scheduling', 'Page replacement', 'Memory management', 'Deadlock lab', 'Disk scheduling'][_selectedIndex];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      appBar: AppBar(title: Row(children: [Container(width: 31, height: 31, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.cyan, AppTheme.blue]), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.hub_rounded, size: 18, color: AppTheme.ink)), const SizedBox(width: 11), Text(_title)]), actions: [if (MediaQuery.sizeOf(context).width > 620) Padding(padding: const EdgeInsets.only(right: 28), child: Center(child: Text('OS SANDBOX  •  TEAM OF 3', style: TextStyle(letterSpacing: 1.15, fontSize: 10, color: Colors.white.withValues(alpha: .42), fontWeight: FontWeight.w700))))]),
      drawer: wide ? null : Drawer(child: SafeArea(child: Sidebar(selectedIndex: _selectedIndex, onItemSelected: (i) { Navigator.pop(context); _selectPage(i); }))),
      body: Row(children: [if (wide) Sidebar(selectedIndex: _selectedIndex, onItemSelected: _selectPage), Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 420), switchInCurve: Curves.easeOutCubic, switchOutCurve: Curves.easeInCubic, transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(.025, 0), end: Offset.zero).animate(animation), child: child)), child: KeyedSubtree(key: ValueKey(_selectedIndex), child: _page())))]),
    );
  }
}

class _SectionLabel extends StatelessWidget { final String text; const _SectionLabel(this.text); @override Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 11, letterSpacing: 1.7, fontWeight: FontWeight.w800, color: Color(0xFF9DAAC4))); }
class _ModuleInfo { final String title, description, chips; final IconData icon; final Color color; final int index; const _ModuleInfo(this.title, this.description, this.icon, this.color, this.chips, this.index); }

class _ModuleTile extends StatefulWidget { final _ModuleInfo info; final int delay; final VoidCallback onTap; const _ModuleTile({required this.info, required this.delay, required this.onTap}); @override State<_ModuleTile> createState() => _ModuleTileState(); }
class _ModuleTileState extends State<_ModuleTile> with SingleTickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 520))..forward(); bool _hover = false;
  @override void dispose() { _entry.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { final m = widget.info; return AnimatedBuilder(animation: _entry, builder: (context, child) => Opacity(opacity: _entry.value, child: Transform.translate(offset: Offset(0, (1 - _entry.value) * 18), child: child)), child: MouseRegion(onEnter: (_) => setState(() => _hover = true), onExit: (_) => setState(() => _hover = false), child: AnimatedContainer(duration: const Duration(milliseconds: 220), transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0), decoration: BoxDecoration(color: const Color(0xFF111A2B), borderRadius: BorderRadius.circular(21), border: Border.all(color: _hover ? m.color.withValues(alpha: .55) : const Color(0xFF263149)), boxShadow: _hover ? [BoxShadow(color: m.color.withValues(alpha: .12), blurRadius: 24, spreadRadius: 1)] : []), child: Material(color: Colors.transparent, child: InkWell(onTap: widget.onTap, borderRadius: BorderRadius.circular(21), child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: m.color.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)), child: Icon(m.icon, color: m.color)), const Spacer(), AnimatedRotation(turns: _hover ? .12 : 0, duration: const Duration(milliseconds: 200), child: Icon(Icons.arrow_outward_rounded, size: 18, color: _hover ? m.color : Colors.white38))]), const Spacer(), Text(m.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 4), Text(m.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .55))), const SizedBox(height: 10), Text(m.chips, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, letterSpacing: .3, color: m.color.withValues(alpha: .9), fontWeight: FontWeight.w700))])))))))); }
}

class _CircuitPainter extends CustomPainter { final double t; _CircuitPainter(this.t); @override void paint(Canvas canvas, Size size) { final p = Paint()..color = Colors.white.withValues(alpha: .035)..strokeWidth = 1; for (double x=0; x<size.width; x+=28) canvas.drawLine(Offset(x,0), Offset(x,size.height), p); for (double y=0; y<size.height; y+=28) canvas.drawLine(Offset(0,y), Offset(size.width,y), p); final sweep = size.width * ((t*1.4)%1); canvas.drawRect(Rect.fromLTWH(sweep-34,0,68,size.height), Paint()..shader=LinearGradient(colors:[Colors.transparent,AppTheme.cyan.withValues(alpha:.035),Colors.transparent]).createShader(Rect.fromLTWH(sweep-34,0,68,size.height))); }
@override bool shouldRepaint(covariant _CircuitPainter old)=>old.t!=t; }
class _CorePainter extends CustomPainter { final double t; _CorePainter(this.t); @override void paint(Canvas canvas, Size size) { final c=Offset(size.width/2,size.height/2); final glow=Paint()..shader=RadialGradient(colors:[AppTheme.cyan.withValues(alpha:.20),AppTheme.blue.withValues(alpha:.07),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:size.width*.49)); canvas.drawCircle(c,size.width*.49,glow); for(int ring=0;ring<3;ring++){final radius=size.width*(.23+ring*.105); canvas.drawCircle(c,radius,Paint()..color=AppTheme.cyan.withValues(alpha:.16-ring*.035)..style=PaintingStyle.stroke..strokeWidth=1);} for(int i=0;i<10;i++){final a=(i*math.pi*2/10)+t*math.pi*2; final r=size.width*(.25+(i%3)*.1); final pos=c+Offset(math.cos(a)*r, math.sin(a)*r*.66); canvas.drawLine(c,pos,Paint()..color=AppTheme.cyan.withValues(alpha:.12)..strokeWidth=1); canvas.drawCircle(pos,i%3==0?3.4:2.2,Paint()..color=i%2==0?AppTheme.cyan:AppTheme.violet);} canvas.drawCircle(c,25,Paint()..shader=const RadialGradient(colors:[AppTheme.cyan,AppTheme.blue,Color(0xFF3356AE)]).createShader(Rect.fromCircle(center:c,radius:25))); canvas.drawCircle(c,8,Paint()..color=Colors.white.withValues(alpha:.9)); }
@override bool shouldRepaint(covariant _CorePainter old)=>old.t!=t; }
