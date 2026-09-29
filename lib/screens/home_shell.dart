import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ads/fullscreen_ad_gate.dart';
import '../state/app_network_state.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_ad_bar.dart';
import 'tabs/channel_tab.dart';
import 'tabs/devices_tab.dart';
import 'tabs/network_tab.dart';
import 'tabs/tools_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    this.state,
    this.autoRefreshWifi = true,
  });

  final AppNetworkState? state;
  final bool autoRefreshWifi;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final AppNetworkState _state;
  late final bool _ownsState;
  int _lastTabIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(_onTabChanged);
    _ownsState = widget.state == null;
    _state = widget.state ?? AppNetworkState();
    if (widget.autoRefreshWifi) {
      _state.refreshWifi();
    }
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    if (_tabs.index == _lastTabIndex) return;
    _lastTabIndex = _tabs.index;
    // Rewarded when switching NETWORK / DEVICES / CHANNEL / TOOLS.
    FullscreenAdGate.withRewarded(() {});
  }

  void _refreshWifi() {
    FullscreenAdGate.withRewarded(_state.refreshWifi);
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    if (_ownsState) {
      _state.dispose();
    }
    super.dispose();
  }

  void _showOverflowMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.navy),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(ctx);
                  showAboutDialog(
                    context: context,
                    applicationName: 'WPSApp: WiFi Analyzer & Scanner',
                    applicationVersion: '1.0.0 (1)',
                    applicationLegalese:
                        'Educational Wi-Fi security guidance and LAN utilities. '
                        'Use only on networks you own or administer.',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh, color: AppColors.navy),
                title: const Text('Refresh Wi-Fi'),
                onTap: () {
                  Navigator.pop(ctx);
                  _refreshWifi();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bodyBg,
          body: Column(
            children: [
              _AppHeader(
                loading: _state.loadingWifi,
                onRefresh: _state.loadingWifi ? null : _refreshWifi,
                onMore: _showOverflowMenu,
                tabs: TabBar(
                  controller: _tabs,
                  isScrollable: false,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    letterSpacing: 0.4,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                    letterSpacing: 0.4,
                  ),
                  tabs: const [
                    Tab(text: 'NETWORK'),
                    Tab(text: 'DEVICES'),
                    Tab(text: 'CHANNEL'),
                    Tab(text: 'TOOLS'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    NetworkTab(state: _state),
                    DevicesTab(state: _state),
                    ChannelTab(state: _state),
                    ToolsTab(state: _state),
                  ],
                ),
              ),
              const BannerAdBar(),
            ],
          ),
        );
      },
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({
    required this.tabs,
    required this.onMore,
    this.onRefresh,
    this.loading = false,
  });

  final Widget tabs;
  final VoidCallback? onRefresh;
  final VoidCallback onMore;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8, top + 6, 8, 12),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Color(0x331A325F),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(Icons.wifi_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WPSApp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'WiFi Analyzer & Scanner',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
              IconButton(
                tooltip: 'More',
                onPressed: onMore,
                icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: tabs,
            ),
          ),
        ],
      ),
    );
  }
}
