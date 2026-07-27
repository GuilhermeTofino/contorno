import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:contorno/core/inject/inject.dart';
import 'package:contorno/features/agenda/domain/entities/agendamento_entity.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_cubit.dart';
import 'package:contorno/features/agenda/presentation/cubit/agenda_state.dart';
import 'package:contorno/features/paciente/domain/entities/paciente_entity.dart';
import 'package:contorno/features/prontuario/domain/entities/evolucao_entity.dart';
import 'package:contorno/features/prontuario/presentation/cubit/evolucao_cubit.dart';
import 'package:contorno/features/prontuario/presentation/cubit/evolucao_state.dart';

class PacienteDetalhesPage extends StatefulWidget {
  final PacienteEntity paciente;

  const PacienteDetalhesPage({super.key, required this.paciente});

  @override
  State<PacienteDetalhesPage> createState() => _PacienteDetalhesPageState();
}

class _PacienteDetalhesPageState extends State<PacienteDetalhesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _abrirModalNovaEvolucao(BuildContext context) {
    final evolucaoCubit = context.read<EvolucaoCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider<EvolucaoCubit>.value(
          value: evolucaoCubit,
          child: _NovaEvolucaoModal(paciente: widget.paciente),
        );
      },
    );
  }

  void _abrirModalReagendar(BuildContext context, AgendamentoEntity sessao) {
    final agendaCubit = context.read<AgendaCubit>();
    DateTime dataHoraSelecionada = sessao.dataHora;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Reagendar Sessão',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      DateFormat(
                        "dd/MM/yyyy 'às' HH:mm",
                        'pt_BR',
                      ).format(dataHoraSelecionada),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final novaData = await showDatePicker(
                        context: context,
                        initialDate: dataHoraSelecionada,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (novaData != null && modalContext.mounted) {
                        final novoHorario = await showTimePicker(
                          context: modalContext,
                          initialTime: TimeOfDay.fromDateTime(
                            dataHoraSelecionada,
                          ),
                        );
                        if (novoHorario != null) {
                          setModalState(() {
                            dataHoraSelecionada = DateTime(
                              novaData.year,
                              novaData.month,
                              novaData.day,
                              novoHorario.hour,
                              novoHorario.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      agendaCubit.reagendarSessao(
                        sessao.id,
                        dataHoraSelecionada,
                        widget.paciente.id,
                      );
                      Navigator.pop(modalContext);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirmar Reagendamento',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _enviarCobrancaWhatsapp(AgendamentoEntity sessao) async {
    final telefoneLimpo = widget.paciente.telefone.replaceAll(
      RegExp(r'\D'),
      '',
    );
    if (telefoneLimpo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Paciente não possui telefone cadastrado para cobrança.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dataFormatted = DateFormat(
      "dd/MM/yyyy 'às' HH:mm",
      'pt_BR',
    ).format(sessao.dataHora);
    final valorFormatted = sessao.valorSessao.toStringAsFixed(2);
    final mensagem =
        "Olá, ${widget.paciente.nome}! Passando para lembrar que nossa sessão do dia $dataFormatted no valor de R\$ $valorFormatted consta em aberto. Segue minha chave Pix: [Sua Chave Aqui]. Qualquer dúvida, estou à disposição!";

    final url = Uri.parse(
      'https://wa.me/55$telefoneLimpo?text=${Uri.encodeComponent(mensagem)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o WhatsApp.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _gerarReciboPdf(AgendamentoEntity sessao) async {
    final pdf = pw.Document();
    final dataSessao = DateFormat(
      "dd 'de' MMMM 'de' yyyy",
      'pt_BR',
    ).format(sessao.dataHora);
    final dataHoje = DateFormat(
      "dd 'de' MMMM 'de' yyyy",
      'pt_BR',
    ).format(DateTime.now());
    final valorFormatted = sessao.valorSessao.toStringAsFixed(2);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RECIBO',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Prestação de Serviços Psicológicos',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.indigo50,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(8),
                      ),
                    ),
                    child: pw.Text(
                      'VALOR: R\$ $valorFormatted',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.indigo900),
              pw.SizedBox(height: 28),

              // Caixa de Valor e Dados Principais
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(12),
                  ),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DECLARAÇÃO DE PAGAMENTO',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.RichText(
                      text: pw.TextSpan(
                        style: const pw.TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: PdfColors.black,
                        ),
                        children: [
                          const pw.TextSpan(text: 'Recebi de '),
                          pw.TextSpan(
                            text: widget.paciente.nome,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          const pw.TextSpan(text: ' a importância de '),
                          pw.TextSpan(
                            text: 'R\$ $valorFormatted',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          const pw.TextSpan(
                            text:
                                ', referente aos serviços de atendimento de psicoterapia prestados na data de ',
                          ),
                          pw.TextSpan(
                            text: dataSessao,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          const pw.TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),
              pw.Text(
                'Por ser verdade, firmo o presente recibo para que surta seus efeitos legais e para fins de comprovação e/ou reembolso junto a convênio de saúde.',
                style: const pw.TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: PdfColors.grey800,
                ),
              ),

              pw.Spacer(),

              // Data de Emissão alinhada à direita
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Emissão: $dataHoje',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey800,
                  ),
                ),
              ),

              pw.SizedBox(height: 48),

              // Linha de Assinatura Profissional
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: 260,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: PdfColors.black,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Psicólogo(a) Responsável',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'CRP 00/000000 | CPF: 000.000.000-00',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'Recibo_${widget.paciente.nome}_${DateFormat("ddMMyyyy").format(sessao.dataHora)}.pdf',
    );
  }

  Future<void> _exportarHistoricoPdf(
    List<EvolucaoEntity> evolucoes,
    PacienteEntity paciente,
  ) async {
    final pdf = pw.Document();
    final dataHoje = DateFormat(
      "dd 'de' MMMM 'de' yyyy",
      'pt_BR',
    ).format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'HISTÓRICO CLÍNICO E EVOLUÇÕES',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Emissão: $dataHoje',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Paciente: ${paciente.nome}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 12),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Contorno - Prontuário Eletrônico',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Página ${context.pageNumber} de ${context.pagesCount}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            ...evolucoes.map((item) {
              final dataStr = DateFormat(
                "dd/MM/yyyy 'às' HH:mm",
                'pt_BR',
              ).format(item.dataHora);
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Sessão / Evolução - $dataStr',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      item.texto,
                      style: const pw.TextStyle(fontSize: 10, height: 1.4),
                    ),
                  ],
                ),
              );
            }),
            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Container(width: 220, child: pw.Divider(thickness: 1)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Assinatura do Profissional Responsável',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'historico_${paciente.nome.replaceAll(' ', '_')}.pdf',
    );
  }

  Color _getStatusColor(StatusAgendamento status) {
    switch (status) {
      case StatusAgendamento.agendada:
        return Colors.blue.shade700;
      case StatusAgendamento.realizada:
        return Colors.green.shade700;
      case StatusAgendamento.cancelada:
        return Colors.red.shade700;
    }
  }

  Color _getStatusBgColor(StatusAgendamento status) {
    switch (status) {
      case StatusAgendamento.agendada:
        return Colors.blue.shade50;
      case StatusAgendamento.realizada:
        return Colors.green.shade50;
      case StatusAgendamento.cancelada:
        return Colors.red.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AgendaCubit>(
          create: (_) =>
              getIt<AgendaCubit>()
                ..carregarAgendamentosPorPaciente(widget.paciente.id),
        ),
        BlocProvider<EvolucaoCubit>(
          create: (_) =>
              getIt<EvolucaoCubit>()..carregarEvolucoes(widget.paciente.id),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.paciente.nome),
          elevation: 0,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: theme.colorScheme.primary,
              child: TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.tertiary,
                indicatorWeight: 3,
                labelColor: theme.colorScheme.tertiary,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 16),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Sessões & Financeiro',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_alt_outlined, size: 16),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Prontuário & Evoluções',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // ABA 1: SESSÕES & FINANCEIRO
            BlocBuilder<AgendaCubit, AgendaState>(
              builder: (context, state) {
                if (state is AgendaLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AgendaLoaded) {
                  final sessoes = state.agendamentos;

                  if (sessoes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 56,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma sessão registrada para este paciente',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: sessoes.length,
                    itemBuilder: (context, index) {
                      final item = sessoes[index];
                      final dataStr = DateFormat(
                        "dd/MM/yyyy 'às' HH:mm",
                        'pt_BR',
                      ).format(item.dataHora);
                      final isPago =
                          item.statusPagamento == StatusPagamento.pago;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.event_outlined,
                                          size: 18,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dataStr,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.grey.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusBgColor(
                                                item.status,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item.status.name.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(
                                                  item.status,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  PopupMenuButton<String>(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onSelected: (val) {
                                      final cubit = context.read<AgendaCubit>();
                                      if (val == 'reagendar') {
                                        _abrirModalReagendar(context, item);
                                      } else if (val == 'cancelar') {
                                        cubit.alterarStatusSessao(
                                          item.id,
                                          StatusAgendamento.cancelada,
                                          widget.paciente.id,
                                        );
                                      } else if (val == 'realizada') {
                                        cubit.alterarStatusSessao(
                                          item.id,
                                          StatusAgendamento.realizada,
                                          widget.paciente.id,
                                        );
                                      } else if (val == 'recibo') {
                                        _gerarReciboPdf(item);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'reagendar',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_calendar, size: 18),
                                            SizedBox(width: 8),
                                            Text('Reagendar'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'realizada',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              size: 18,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Marcar como Realizada'),
                                          ],
                                        ),
                                      ),
                                      if (isPago)
                                        const PopupMenuItem(
                                          value: 'recibo',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.picture_as_pdf,
                                                size: 18,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Gerar Recibo'),
                                            ],
                                          ),
                                        ),
                                      const PopupMenuItem(
                                        value: 'cancelar',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.cancel_outlined,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Cancelar Sessão'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 24, thickness: 0.8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'R\$ ${item.valorSessao.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (!isPago) ...[
                                        IconButton(
                                          onPressed: () =>
                                              _enviarCobrancaWhatsapp(item),
                                          icon: const Icon(
                                            Icons.chat_outlined,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                          tooltip: 'Cobrar via WhatsApp',
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                        ),
                                      ],
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            final novoStatus = isPago
                                                ? StatusPagamento.pendente
                                                : StatusPagamento.pago;
                                            context
                                                .read<AgendaCubit>()
                                                .alternarPagamento(
                                                  item.id,
                                                  novoStatus,
                                                  widget.paciente.id,
                                                );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isPago
                                                  ? Colors.green.withValues(
                                                      alpha: 0.15,
                                                    )
                                                  : Colors.orange.withValues(
                                                      alpha: 0.15,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isPago
                                                      ? Icons.check_circle
                                                      : Icons
                                                            .access_time_filled,
                                                  size: 14,
                                                  color: isPago
                                                      ? Colors.green.shade800
                                                      : Colors.orange.shade800,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  isPago ? 'PAGO' : 'PENDENTE',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: isPago
                                                        ? Colors.green.shade800
                                                        : Colors
                                                              .orange
                                                              .shade800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            // ABA 2: PRONTUÁRIO & EVOLUÇÕES
            Builder(
              builder: (context) {
                return Scaffold(
                  body: BlocBuilder<EvolucaoCubit, EvolucaoState>(
                    builder: (context, state) {
                      if (state is EvolucaoLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is EvolucaoLoaded) {
                        final evolucoes = state.evolucoes;

                        if (evolucoes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note_alt_outlined,
                                  size: 56,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma evolução registrada',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Linha do Tempo (${evolucoes.length})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _exportarHistoricoPdf(
                                      evolucoes,
                                      widget.paciente,
                                    ),
                                    icon: const Icon(
                                      Icons.picture_as_pdf,
                                      size: 16,
                                    ),
                                    label: const Text('Exportar PDF'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: evolucoes.length,
                                itemBuilder: (context, index) {
                                  final item = evolucoes[index];
                                  final dataStr = DateFormat(
                                    "dd/MM/yyyy 'às' HH:mm",
                                    'pt_BR',
                                  ).format(item.dataHora);

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.edit_note_rounded,
                                                size: 16,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                dataStr,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 16),
                                          Text(
                                            item.texto,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: () => _abrirModalNovaEvolucao(context),
                    backgroundColor: theme.colorScheme.tertiary,
                    foregroundColor: Colors.black87,
                    icon: const Icon(Icons.add_comment),
                    label: const Text(
                      'Nova Evolução',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NovaEvolucaoModal extends StatefulWidget {
  final PacienteEntity paciente;

  const _NovaEvolucaoModal({required this.paciente});

  @override
  State<_NovaEvolucaoModal> createState() => _NovaEvolucaoModalState();
}

class _NovaEvolucaoModalState extends State<_NovaEvolucaoModal> {
  final _formKey = GlobalKey<FormState>();
  final _textoController = TextEditingController();
  final DateTime _dataHora = DateTime.now();

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  void _submeter() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (isFormValid) {
      final psicologoId = Supabase.instance.client.auth.currentUser?.id ?? '';

      final evolucao = EvolucaoEntity(
        id: const Uuid().v4(),
        psicologoId: psicologoId,
        pacienteId: widget.paciente.id,
        dataHora: _dataHora,
        texto: _textoController.text.trim(),
      );

      context.read<EvolucaoCubit>().cadastrarEvolucao(evolucao);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<EvolucaoCubit, EvolucaoState>(
      listener: (context, state) {
        if (state is EvolucaoSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else if (state is EvolucaoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is EvolucaoLoading;

        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nova Anotação Clínica',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _textoController,
                    maxLines: 5,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: 'Relato da Evolução Clínica *',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Digite o relato da evolução';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submeter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.tertiary,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black87,
                              ),
                            )
                          : const Text(
                              'Salvar no Prontuário',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
