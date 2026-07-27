import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contorno/core/inject/inject.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_cubit.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_state.dart';
import 'package:contorno/features/agenda/presentation/pages/agenda_page.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_state.dart';
import 'package:contorno/features/financeiro/presentation/pages/financeiro_page.dart';
import 'package:contorno/features/paciente/domain/repositories/paciente_repository.dart';
import 'package:contorno/features/paciente/presentation/cubit/paciente_cubit.dart';
import 'package:contorno/features/paciente/presentation/pages/paciente_detalhes_page.dart';
import 'package:contorno/features/paciente/presentation/pages/pacientes_page.dart';
import 'package:contorno/features/perfil/presentation/pages/perfil_page.dart';

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
    final mensagem = "Olá, ${paciente.nome}! Passando para lembrar da nossa sessão hoje às $horaStr. Te aguardo!";

    final url = Uri.parse('https://wa.me/55$telefoneLimpo?text=${Uri.encodeComponent(mensagem)}');

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

  Widget _buildMetricCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(
    BuildContext context,
    ThemeData theme,
    AuthState authState,
  ) {
    String nomePsicologo = 'Profissional';
    if (authState is AuthAuthenticated) {
      nomePsicologo = authState.user.nome.split(' ').first;
    }

    final dataHojeFormatada = DateFormat(
      "EEEE, d 'de' MMMM",
      'pt_BR',
    ).format(DateTime.now());
    final dataHojeCapitalizada =
        dataHojeFormatada[0].toUpperCase() + dataHojeFormatada.substring(1);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Elegante
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.tertiary,
                    child: Text(
                      nomePsicologo.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, Dr(a). $nomePsicologo',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dataHojeCapitalizada,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Métricas Rápida
            BlocProvider<AgendaCubit>(
              create: (_) =>
                  getIt<AgendaCubit>()..carregarAgendamentos(DateTime.now()),
              child: BlocBuilder<AgendaCubit, AgendaState>(
                builder: (context, agendaState) {
                  int totalHoje = 0;
                  if (agendaState is AgendaLoaded) {
                    totalHoje = agendaState.agendamentos.length;
                  }

                  return Row(
                    children: [
                      _buildMetricCard(
                        theme: theme,
                        title: 'Consultas Hoje',
                        value: '$totalHoje',
                        icon: Icons.calendar_today_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        theme: theme,
                        title: 'Status',
                        value: totalHoje > 0 ? 'Com sessões' : 'Livre',
                        icon: Icons.spa_outlined,
                        color: theme.colorScheme.tertiary,
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Título Agenda de Hoje
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agenda de Hoje',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de Consultas da Home
            Expanded(
              child: BlocProvider<AgendaCubit>(
                create: (_) =>
                    getIt<AgendaCubit>()..carregarAgendamentos(DateTime.now()),
                child: BlocBuilder<AgendaCubit, AgendaState>(
                  builder: (context, state) {
                    if (state is AgendaLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AgendaLoaded) {
                      final agendamentos = state.agendamentos;

                      if (agendamentos.isEmpty) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 36,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_available_outlined,
                                  size: 56,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Nenhum atendimento para hoje',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Aproveite o seu dia! Suas próximas consultas estarão no calendário.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: agendamentos.length,
                        itemBuilder: (context, index) {
                          final item = agendamentos[index];
                          final hora =
                              '${item.dataHora.hour.toString().padLeft(2, '0')}:${item.dataHora.minute.toString().padLeft(2, '0')}';
                          final bool isPassada = item.dataHora.isBefore(
                            DateTime.now(),
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: isPassada
                                ? Colors.grey.shade100
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: isPassada
                                  ? BorderSide(color: Colors.grey.shade300)
                                  : BorderSide.none,
                            ),
                            elevation: isPassada ? 0 : 1,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                final pacienteRepo =
                                    getIt<IPacienteRepository>();
                                final paciente = await pacienteRepo
                                    .buscarPacientePorId(item.pacienteId);
                                if (paciente != null && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PacienteDetalhesPage(
                                        paciente: paciente,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Horário à Esquerda
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPassada
                                            ? Colors.grey.shade300
                                            : theme.colorScheme.primary
                                                  .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        hora,
                                        style: TextStyle(
                                          color: isPassada
                                              ? Colors.grey.shade700
                                              : theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Detalhes à Direita
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.pacienteNome ?? 'Paciente',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isPassada
                                                  ? Colors.grey.shade700
                                                  : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Valor: R\$ ${item.valorSessao.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isPassada
                                                  ? Colors.grey.shade500
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                          if (item.isRecorrente) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isPassada
                                                    ? Colors.grey.shade200
                                                    : theme.colorScheme.primary
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.repeat,
                                                    size: 12,
                                                    color: isPassada
                                                        ? Colors.grey.shade600
                                                        : theme
                                                              .colorScheme
                                                              .primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Recorrente',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: isPassada
                                                          ? Colors.grey.shade600
                                                          : theme
                                                                .colorScheme
                                                                .primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (!isPassada && item.status == StatusAgendamento.agendada) ...[
                                      IconButton(
                                        onPressed: () => _enviarLembrete(item),
                                        icon: const Icon(
                                          Icons.notifications_active_outlined,
                                          color: Colors.green,
                                          size: 22,
                                        ),
                                        tooltip: 'Enviar Lembrete pré-sessão',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    AuthState authState,
  ) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab(context, theme, authState);
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
        return _buildHomeTab(context, theme, authState);
    }
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.tertiary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black87 : Colors.white,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
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

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Agenda';
      case 1:
        return 'Calendário de Sessões';
      case 2:
        return 'Meus Pacientes';
      case 3:
        return 'Relatório Financeiro';
      case 4:
        return 'Perfil Profissional';
      default:
        return 'Contorno';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            appBar: AppBar(
              title: Text(_getAppBarTitle()),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sair',
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                  },
                ),
              ],
            ),
            body: _buildBody(context, theme, authState),
            bottomNavigationBar: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
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
                    icon: Icons.home_rounded,
                    label: 'Home',
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.calendar_month_outlined,
                    label: 'Agenda',
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.people_outline,
                    label: 'Pacientes',
                  ),
                  _buildNavItem(
                    index: 3,
                    icon: Icons.attach_money_rounded,
                    label: 'Financeiro',
                  ),
                  _buildNavItem(
                    index: 4,
                    icon: Icons.settings_outlined,
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
