import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:contorno/core/error/exceptions.dart';
import 'package:contorno/features/paciente/data/datasources/paciente_datasource.dart';
import 'package:contorno/features/paciente/data/models/paciente_model.dart';
import 'package:contorno/features/paciente/domain/enums/paciente_enums.dart';

class PacienteDatasourceSupabaseImpl implements IPacienteDatasource {
  final SupabaseClient supabase;

  PacienteDatasourceSupabaseImpl(this.supabase);

  static const String _tableName = 'pacientes';

  @override
  Future<void> cadastrarPaciente(PacienteModel paciente) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'Sessão expirada. Faça login novamente.');
      }

      final patientMap = paciente.toMap();
      patientMap['psicologo_id'] = userId;

      await supabase.from(_tableName).insert(patientMap);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> atualizarPaciente(PacienteModel paciente) async {
    try {
      await supabase
          .from(_tableName)
          .update(paciente.toMap())
          .eq('id', paciente.id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PacienteModel>> buscarPacientesAtivos() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'Sessão expirada. Faça login novamente.');
      }

      final response = await supabase
          .from(_tableName)
          .select()
          .eq('psicologo_id', userId)
          .eq('status', StatusPaciente.ativo.name);

      final list = response as List<dynamic>;
      return list.map((e) => PacienteModel.fromMap(e as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PacienteModel?> buscarPacientePorId(String id) async {
    try {
      final response = await supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return PacienteModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
