import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionsGrid extends StatelessWidget {
  final ValueChanged<int> onSelectTab;

  const QuickActionsGrid({
    super.key,
    required this.onSelectTab,
  });

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? tag,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A345C).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF3A345C),
                    size: 20,
                  ),
                ),
                if (tag != null)
                  Positioned(
                    top: -6,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4B363),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A345C),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2448),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2448),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildQuickActionButton(
                context,
                icon: Icons.person_add_alt_1_outlined,
                label: 'Novo Paciente',
                onTap: () => context.push('/cadastrar-paciente'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                context,
                icon: Icons.add_alarm_rounded,
                label: 'Nova Sessão',
                onTap: () => onSelectTab(1),
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                context,
                icon: Icons.note_add_outlined,
                label: 'Adicionar Nota',
                onTap: () => onSelectTab(2),
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                context,
                icon: Icons.insert_chart_outlined_rounded,
                label: 'Relatórios',
                onTap: () => onSelectTab(3),
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                context,
                icon: Icons.folder_open_outlined,
                label: 'Documentos',
                tag: 'Em breve',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Módulo de Documentos e Laudos em breve!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
