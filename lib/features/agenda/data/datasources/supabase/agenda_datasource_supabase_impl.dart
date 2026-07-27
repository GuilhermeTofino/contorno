import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:contorno/core/error/exceptions.dart';
import 'package:contorno/features/agenda/data/datasources/agenda_datasource.dart';
import 'package:contorno/features/agenda/data/models/agendamento_model.dart';
import 'package:contorno/features/agenda/domain/enums/agenda_enums.dart';

class AgendaDatasourceSupabaseImpl implements IAgendaDatasource {
  final SupabaseClient supabase;

  AgendaDatasourceSupabaseImpl(this.supabase);

  static const String _tableName = 'agendamentos';

  @override
  Future<void> cadastrarAgendamento(AgendamentoModel agendamento, {int repeticoes = 1}) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'Sessão expirada. Faça login novamente.');
      }

      final grupoId = agendamento.isRecorrente
          ? (agendamento.grupoRecorrenciaId ?? const Uuid().v4())
          : null;

      final List<Map<String, dynamic>> registros = [];

      if (!agendamento.isRecorrente) {
        final map = agendamento.toMap();
        map['psicologo_id'] = userId;
        registros.add(map);
      } else {
        final int semanas = repeticoes > 0 ? repeticoes : 4;
        DateTime dataAtual = agendamento.dataHora;

        switch (agendamento.frequencia) {
          case FrequenciaRecorrencia.semanal:
            for (int i = 0; i < semanas; i++) {
              final map = agendamento.toMap();
              map['id'] = i == 0 ? agendamento.id : const Uuid().v4();
              map['psicologo_id'] = userId;
              map['data_hora'] = dataAtual.add(Duration(days: 7 * i)).toIso8601String();
              map['grupo_recorrencia_id'] = grupoId;
              map['frequencia'] = agendamento.frequencia.name;
              registros.add(map);
            }
            break;

          case FrequenciaRecorrencia.quinzenal:
            final totalQuinzenas = (semanas / 2).ceil();
            for (int i = 0; i < totalQuinzenas; i++) {
              final map = agendamento.toMap();
              map['id'] = i == 0 ? agendamento.id : const Uuid().v4();
              map['psicologo_id'] = userId;
              map['data_hora'] = dataAtual.add(Duration(days: 14 * i)).toIso8601String();
              map['grupo_recorrencia_id'] = grupoId;
              map['frequencia'] = agendamento.frequencia.name;
              registros.add(map);
            }
            break;

          case FrequenciaRecorrencia.duasVezesSemana:
            for (int i = 0; i < semanas; i++) {
              final primeiraDaSemana = dataAtual.add(Duration(days: 7 * i));
              final segundaDaSemana = primeiraDaSemana.add(const Duration(days: 3));

              final map1 = agendamento.toMap();
              map1['id'] = i == 0 ? agendamento.id : const Uuid().v4();
              map1['psicologo_id'] = userId;
              map1['data_hora'] = primeiraDaSemana.toIso8601String();
              map1['grupo_recorrencia_id'] = grupoId;
              map1['frequencia'] = agendamento.frequencia.name;
              registros.add(map1);

              final map2 = agendamento.toMap();
              map2['id'] = const Uuid().v4();
              map2['psicologo_id'] = userId;
              map2['data_hora'] = segundaDaSemana.toIso8601String();
              map2['grupo_recorrencia_id'] = grupoId;
              map2['frequencia'] = agendamento.frequencia.name;
              registros.add(map2);
            }
            break;

          case FrequenciaRecorrencia.nenhuma:
            final map = agendamento.toMap();
            map['psicologo_id'] = userId;
            registros.add(map);
            break;
        }
      }

      await supabase.from(_tableName).insert(registros);

      if (agendamento.isRecorrente) {
        await supabase
            .from('pacientes')
            .update({'tem_recorrencia': true})
            .eq('id', agendamento.pacienteId);
      }
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AgendamentoModel>> listarAgendamentosPorData(DateTime data) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'Sessão expirada. Faça login novamente.');
      }

      final inicioDia = DateTime(data.year, data.month, data.day).toIso8601String();
      final fimDia = DateTime(data.year, data.month, data.day, 23, 59, 59).toIso8601String();

      final response = await supabase
          .from(_tableName)
          .select('*, pacientes(nome)')
          .eq('psicologo_id', userId)
          .gte('data_hora', inicioDia)
          .lte('data_hora', fimDia)
          .order('data_hora', ascending: true);

      final list = response as List<dynamic>;
      return list.map((e) => AgendamentoModel.fromMap(e as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AgendamentoModel>> listarTodosAgendamentos() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'Sessão expirada. Faça login novamente.');
      }

      final response = await supabase
          .from(_tableName)
          .select('*, pacientes(nome)')
          .eq('psicologo_id', userId)
          .order('data_hora', ascending: true);

      final list = response as List<dynamic>;
      return list.map((e) => AgendamentoModel.fromMap(e as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AgendamentoModel>> listarAgendamentosPorPaciente(String pacienteId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'Sessão expirada. Faça login novamente.');
      }

      final response = await supabase
          .from(_tableName)
          .select('*, pacientes(nome)')
          .eq('psicologo_id', userId)
          .eq('paciente_id', pacienteId)
          .order('data_hora', ascending: true);

      final list = response as List<dynamic>;
      return list.map((e) => AgendamentoModel.fromMap(e as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> atualizarStatusAgendamento(String agendamentoId, String status) async {
    try {
      await supabase
          .from(_tableName)
          .update({'status': status})
          .eq('id', agendamentoId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> alternarStatusPagamento(String agendamentoId, String statusPagamento) async {
    try {
      await supabase
          .from(_tableName)
          .update({'status_pagamento': statusPagamento})
          .eq('id', agendamentoId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> reagendarSessao(String agendamentoId, DateTime novaDataHora) async {
    try {
      await supabase
          .from(_tableName)
          .update({'data_hora': novaDataHora.toIso8601String()})
          .eq('id', agendamentoId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
