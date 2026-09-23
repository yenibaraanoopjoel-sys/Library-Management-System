import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../routing/route_names.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../enums/user_role.dart';

/// Navigation item definition
class NavItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final List<UserRole> allowedRoles;

  const NavItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.allowedRoles = const [UserRole.admin, UserRole.librarian, UserRole.member],
  });
}

/// The Main Responsive Application Shell (Desktop Sidebar + TopBar, Tablet Rail, Mobile Drawer + BottomBar)
class AppShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isSidebarCollapsed = false;

  static const List<NavItem> _allNavItems = [
    NavItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: RouteNames.dashboard,
    ),
    NavItem(
      title: 'Books',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      route: RouteNames.books,
    ),
    NavItem(
      title: 'Members',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      route: RouteNames.members,
      allowedRoles: [UserRole.admin, UserRole.librarian],
    ),
    NavItem(
      title: 'Borrowings',
      icon: Icons.swap_horiz_outlined,
      activeIcon: Icons.swap_horiz,
      route: RouteNames.borrowing,
    ),
    NavItem(
      title: 'Returns',
      icon: Icons.assignment_return_outlined,
      activeIcon: Icons.assignment_return,
      route: RouteNames.returns,
      allowedRoles: [UserRole.admin, UserRole.librarian],
    ),
    NavItem(
      title: 'Fines',
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments,
      route: RouteNames.fines,
    ),
    NavItem(
      title: 'Search',
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      route: RouteNames.search,
    ),
    NavItem(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      route: RouteNames.notifications,
    ),
    NavItem(
      title: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: RouteNames.profile,
    ),
    NavItem(
      title: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      route: RouteNames.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppDimensions.tabletBreakpoint;
    final isTablet = width >= AppDimensions.mobileBreakpoint && width < AppDimensions.tabletBreakpoint;

    // Filter nav items based on user's role
    final userRole = auth.role;
    final visibleNavItems = _allNavItems.where((item) => item.allowedRoles.contains(userRole)).toList();

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(context, visibleNavItems, auth),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(context, auth),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            _buildCollapsedSidebar(context, visibleNavItems, auth),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(context, auth),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getPageTitle(widget.currentRoute),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          _buildNotificationBell(context),
          _buildUserAvatarMenu(context, auth),
        ],
      ),
      drawer: _buildMobileDrawer(context, visibleNavItems, auth),
      body: widget.child,
      bottomNavigationBar: _buildMobileBottomBar(context, visibleNavItems),
    );
  }

  String _getPageTitle(String route) {
    for (var item in _allNavItems) {
      if (route == item.route || route.startsWith(item.route)) {
        return item.title;
      }
    }
    return 'Library System';
  }

  Widget _buildTopBar(BuildContext context, AuthProvider auth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(widget.currentRoute),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const Spacer(),
          // Quick Search Button
          IconButton(
            tooltip: 'Search Library',
            icon: const Icon(Icons.search),
            onPressed: () {
              if (widget.currentRoute != RouteNames.search) {
                Navigator.pushReplacementNamed(context, RouteNames.search);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildNotificationBell(context),
          const SizedBox(width: 16),
          _buildUserAvatarMenu(context, auth),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final unread = notifProvider.unreadCount;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            if (widget.currentRoute != RouteNames.notifications) {
              Navigator.pushReplacementNamed(context, RouteNames.notifications);
            }
          },
        ),
        if (unread > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserAvatarMenu(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    final initials = user != null && user.name.isNotEmpty
        ? user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'U';

    return PopupMenuButton<String>(
      tooltip: 'User Account',
      offset: const Offset(0, 48),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? 'User',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: _getRoleColor(auth.role).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  auth.role.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _getRoleColor(auth.role),
                  ),
                ),
              ),
            ],
          ),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.pushReplacementNamed(context, RouteNames.profile);
        } else if (value == 'settings') {
          Navigator.pushReplacementNamed(context, RouteNames.settings);
        } else if (value == 'switch_admin') {
          auth.loginAsRole(UserRole.admin);
        } else if (value == 'switch_librarian') {
          auth.loginAsRole(UserRole.librarian);
        } else if (value == 'switch_student') {
          auth.loginAsRole(UserRole.member);
        } else if (value == 'logout') {
          auth.logout();
          Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (route) => false);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? 'Account',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(user?.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [Icon(Icons.person, size: 18), SizedBox(width: 10), Text('My Profile')],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [Icon(Icons.settings, size: 18), SizedBox(width: 10), Text('Settings')],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          enabled: false,
          child: Text('SWITCH DEMO ROLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        PopupMenuItem(
          value: 'switch_admin',
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, size: 18, color: auth.isAdmin ? AppColors.primary : Colors.grey),
              const SizedBox(width: 10),
              Text('Admin View', style: TextStyle(fontWeight: auth.isAdmin ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'switch_librarian',
          child: Row(
            children: [
              Icon(Icons.badge, size: 18, color: auth.role == UserRole.librarian ? AppColors.secondary : Colors.grey),
              const SizedBox(width: 10),
              Text('Librarian View', style: TextStyle(fontWeight: auth.role == UserRole.librarian ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'switch_student',
          child: Row(
            children: [
              Icon(Icons.school, size: 18, color: auth.isStudent ? AppColors.accent : Colors.grey),
              const SizedBox(width: 10),
              Text('Student / Member View', style: TextStyle(fontWeight: auth.isStudent ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [Icon(Icons.logout, size: 18, color: AppColors.error), SizedBox(width: 10), Text('Logout', style: TextStyle(color: AppColors.error))],
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.primaryLight;
      case UserRole.librarian:
        return AppColors.secondary;
      case UserRole.member:
        return AppColors.accent;
    }
  }

  Widget _buildSidebar(BuildContext context, List<NavItem> items, AuthProvider auth) {
    return Container(
      width: _isSidebarCollapsed ? 80 : 260,
      color: AppColors.sidebarBgLight,
      child: Column(
        children: [
          // Branding Header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.local_library, color: Colors.white, size: 28),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'LIBRA SYSTEM',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                IconButton(
                  icon: Icon(
                    _isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    color: AppColors.sidebarTextLight,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSidebarCollapsed = !_isSidebarCollapsed;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E293B), height: 1),
          // Nav Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: items.map((item) {
                final isSelected = widget.currentRoute == item.route ||
                    (item.route != RouteNames.dashboard && widget.currentRoute.startsWith(item.route));

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.sidebarActiveLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? Colors.white : AppColors.sidebarTextLight,
                      size: 22,
                    ),
                    title: _isSidebarCollapsed
                        ? null
                        : Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.sidebarTextLight,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                    onTap: () {
                      if (widget.currentRoute != item.route) {
                        Navigator.pushReplacementNamed(context, item.route);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          // Role & Version info at bottom
          if (!_isSidebarCollapsed) ...[
            const Divider(color: Color(0xFF1E293B), height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: _getRoleColor(auth.role),
                    child: const Icon(Icons.shield, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.role.displayName,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          'v1.0.0 • Production Ready',
                          style: TextStyle(color: AppColors.sidebarTextLight, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapsedSidebar(BuildContext context, List<NavItem> items, AuthProvider auth) {
    return Container(
      width: 72,
      color: AppColors.sidebarBgLight,
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.local_library, color: Colors.white, size: 28),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E293B), height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: items.map((item) {
                final isSelected = widget.currentRoute == item.route;
                return IconButton(
                  tooltip: item.title,
                  icon: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? Colors.white : AppColors.sidebarTextLight,
                  ),
                  onPressed: () {
                    if (widget.currentRoute != item.route) {
                      Navigator.pushReplacementNamed(context, item.route);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, List<NavItem> items, AuthProvider auth) {
    return Drawer(
      backgroundColor: AppColors.sidebarBgLight,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0B1120)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_library, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'LIBRA SYSTEM',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  auth.currentUser?.name ?? 'User',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  auth.role.displayName,
                  style: TextStyle(color: _getRoleColor(auth.role), fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: items.map((item) {
                final isSelected = widget.currentRoute == item.route;
                return ListTile(
                  leading: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? Colors.white : AppColors.sidebarTextLight,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.sidebarTextLight,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  tileColor: isSelected ? AppColors.sidebarActiveLight : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != item.route) {
                      Navigator.pushReplacementNamed(context, item.route);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildMobileBottomBar(BuildContext context, List<NavItem> items) {
    // Show top 4 primary tabs for mobile
    final primaryTabs = items.take(4).toList();
    int currentIndex = primaryTabs.indexWhere((i) => i.route == widget.currentRoute);
    if (currentIndex == -1) currentIndex = 0;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        final targetRoute = primaryTabs[index].route;
        if (widget.currentRoute != targetRoute) {
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      },
      items: primaryTabs.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          activeIcon: Icon(item.activeIcon),
          label: item.title,
        );
      }).toList(),
    );
  }
}
