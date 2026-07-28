import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contorno/core/inject/inject.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_cubit.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_state.dart';
import 'package:contorno/features/agenda/presentation/pages/agenda_page.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_state.dart';
import 'package:contorno/features/financeiro/presentation/pages/financeiro_page.dart';
import 'package:contorno/features/paciente/domain/repositories/paciente_repository.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_cubit.dart';
import 'package:contorno/features/paciente/presentation/pages/pacientes_page.dart';
import 'package:contorno/features/perfil/presentation/pages/perfil_page.dart';
import 'package:contorno/features/splash/presentation/widgets/brand_backdrop.dart';

import '../widgets/home_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/next_session_card.dart';
import '../widgets/metrics_overview_card.dart';
import '../widgets/today_sessions_list.dart';
import '../widgets/revenue_trend_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Future<void> _enviarLembrete(AgendamentoEntity sessao) async {
    final pacienteRepo = getIt<IPacienteRepository>();
    final paciente = await pacienteRepo.buscarPacientePorId(sessao.pacienteId);

    if (paciente == null || paciente.telefone.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paciente não possui telefone cadastrado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final telefoneLimpo = paciente.telefone.replaceAll(RegExp(r'\D'), '');
    final horaStr = DateFormat('HH:mm').format(sessao.dataHora);
    final mensagem =
        "Olá, ${paciente.nome}! Passando para lembrar da nossa sessão hoje às $horaStr. Te aguardo!";

    final url = Uri.parse(
      'https://wa.me/55$telefoneLimpo?text=${Uri.encodeComponent(mensagem)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o WhatsApp.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildHomeDashboard(BuildContext context, AuthState authState) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CABEÇALHO DA HOME
          HomeHeader(authState: authState),
          const SizedBox(height: 24),

          // 2. AÇÕES RÁPIDAS
          QuickActionsGrid(
            onSelectTab: (index) {
              setState(() => _currentIndex = index);
            },
          ),
          const SizedBox(height: 24),

          // 3. AGENDAMENTOS E CONTEÚDO DINÂMICO
          BlocProvider<AgendaCubit>(
            create: (_) =>
                getIt<AgendaCubit>()..carregarAgendamentos(DateTime.now()),
            child: BlocBuilder<AgendaCubit, AgendaState>(
              builder: (context, agendaState) {
                List<AgendamentoEntity> agendamentosHoje = [];
                if (agendaState is AgendaLoaded) {
                  agendamentosHoje = agendaState.agendamentos;
                }

                AgendamentoEntity? proximaSessao;
                final agora = DateTime.now();
                for (final a in agendamentosHoje) {
                  if (a.dataHora.isAfter(agora) ||
                      a.dataHora.isAtSameMomentAs(agora)) {
                    proximaSessao = a;
                    break;
                  }
                }
                proximaSessao ??= agendamentosHoje.isNotEmpty
                    ? agendamentosHoje.first
                    : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CARD PRÓXIMA SESSÃO
                    if (proximaSessao != null) ...[
                      NextSessionCard(
                        sessao: proximaSessao,
                        onEnviarLembrete: _enviarLembrete,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // METRICAS
                    const MetricsOverviewCard(),
                    const SizedBox(height: 24),

                    // LISTA DE SESSÕES DO DIA (HOJE)
                    TodaySessionsList(
                      agendamentos: agendamentosHoje,
                      onVerAgenda: (index) {
                        setState(() => _currentIndex = index);
                      },
                    ),
                    const SizedBox(height: 28),

                    // GRÁFICO TENDÊNCIA DE RECEITA
                    const RevenueTrendChart(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE4B363) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF3A345C) : Colors.white70,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF3A345C),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthState authState) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeDashboard(context, authState);
      case 1:
        return BlocProvider<AgendaCubit>(
          create: (_) => getIt<AgendaCubit>(),
          child: const AgendaPage(),
        );
      case 2:
        return BlocProvider<PacienteCubit>(
          create: (_) => getIt<PacienteCubit>(),
          child: const PacientesPage(),
        );
      case 3:
        return const FinanceiroPage();
      case 4:
        return const PerfilPage();
      default:
        return _buildHomeDashboard(context, authState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return Scaffold(
            body: Stack(
              children: [
                BrandBackdrop(
                  child: SafeArea(child: _buildBody(context, authState)),
                ),

                // BARRA DE NAVEGAÇÃO FLUTUANTE EM PÍLULA
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A345C),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          index: 0,
                          icon: Icons.grid_view_rounded,
                          label: 'Home',
                        ),
                        _buildNavItem(
                          index: 1,
                          icon: Icons.calendar_today_rounded,
                          label: 'Agenda',
                        ),
                        _buildNavItem(
                          index: 2,
                          icon: Icons.people_outline_rounded,
                          label: 'Pacientes',
                        ),
                        _buildNavItem(
                          index: 3,
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Finanças',
                        ),
                        _buildNavItem(
                          index: 4,
                          icon: Icons.settings_outlined,
                          label: 'Perfil',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
