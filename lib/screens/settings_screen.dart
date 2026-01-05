import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../engine/theme_engine.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeEngine>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SETTINGS',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSectionHeader('GAMEPLAY'),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'Sound Effects',
              'Play sounds on move and capture',
              Icons.volume_up_rounded,
              theme.soundEnabled,
              (val) => theme.setSound(val),
              theme.primaryColor,
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'Haptic Vibration',
              'Vibrate on interaction',
              Icons.vibration_rounded,
              theme.hapticsEnabled,
              (val) => theme.setHaptics(val),
              theme.primaryColor,
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('CUSTOMIZATION'),
            const SizedBox(height: 12),
            _buildThemeSelector(theme),

            const SizedBox(height: 32),
            _buildSectionHeader('SYSTEM'),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'Notifications',
              'Get alerts for new matches',
              Icons.notifications_active_rounded,
              theme.notificationsEnabled,
              (val) => theme.setNotifications(val),
              theme.primaryColor,
            ),
            
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                   Text(
                    'Chess Master Pro',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                   const SizedBox(height: 4),
                   const Text('Version 1.0.0 (Nexus Edition)', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: Colors.white10)),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged, Color activeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: activeColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(ThemeEngine theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Board Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildThemeOption('Classic', Colors.brown, theme),
              const SizedBox(width: 12),
              _buildThemeOption('Nexus', const Color(0xFF6366F1), theme),
              const SizedBox(width: 12),
              _buildThemeOption('Coral', const Color(0xFFF43F5E), theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String name, Color color, ThemeEngine theme) {
    final isSelected = theme.boardTheme == name;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => theme.setBoardTheme(name),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white60,
            ),
          ),
        ),
      ),
    );
  }
}
