import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:contorno/core/error/exceptions.dart';
import 'package:contorno/features/prontuario/data/datasources/evolucao_datasource.dart';
import 'package:contorno/features/prontuario/data/models/evolucao_model.dart';

class EvolucaoDatasourceSupabaseImpl implements IEvolucaoDatasource {
  final SupabaseClient supabase;

  EvolucaoDatasourceSupabaseImpl(this.supabase);

  static const String _tableName = 'evolucoes';

  @override
  Future<void> cadastrarEvolucao(EvolucaoModel evolucao) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'Sessão expirada. Faça login novamente.');
      }

      final map = evolucao.toMap();
      map['psicologo_id'] = userId;

      await supabase.from(_tableName).insert(map);
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw ServerException(
          message: 'Permissão negada no banco de dados (RLS). Verifique as políticas da tabela evolucoes.',
          code: e.code,
        );
      }
      throw ServerException(message: 'Erro no banco de dados (${e.code}): ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<EvolucaoModel>> listarEvolucoesPorPaciente(String pacienteId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'Sessão expirada. Faça login novamente.');
      }

      final response = await supabase
          .from(_tableName)
          .select()
          .eq('psicologo_id', userId)
          .eq('paciente_id', pacienteId)
          .order('data_hora', ascending: false);

      final list = response as List<dynamic>;
      return list.map((e) => EvolucaoModel.fromMap(e as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw ServerException(
          message: 'Permissão negada no banco de dados (RLS). Verifique as políticas da tabela evolucoes.',
          code: e.code,
        );
      }
      throw ServerException(message: 'Erro no banco de dados (${e.code}): ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
