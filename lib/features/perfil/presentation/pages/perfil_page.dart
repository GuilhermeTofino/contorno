import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contorno/core/theme/theme_controller.dart';
import 'package:contorno/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:image_picker/image_picker.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _crpController = TextEditingController(text: '00/000000');
  final _valorSessaoController = TextEditingController(text: '150.00');
  final ScreenshotController _screenshotController = ScreenshotController();

  String _duracaoSessao = '50 minutos';
  String? _fotoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('psicologos')
            .select('crp, valor_padrao, duracao_sessao_padrao, foto_url')
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          if (data['crp'] != null) _crpController.text = data['crp'].toString();
          if (data['foto_url'] != null) {
            setState(() {
              _fotoUrl = data['foto_url'].toString();
            });
          }
          if (data['valor_padrao'] != null) {
            _valorSessaoController.text = (data['valor_padrao'] as num)
                .toDouble()
                .toStringAsFixed(2);
          }
          if (data['duracao_sessao_padrao'] != null) {
            final durStr = data['duracao_sessao_padrao'].toString();
            setState(() {
              if (durStr.contains('60')) {
                _duracaoSessao = '60 minutos';
              } else {
                _duracaoSessao = '50 minutos';
              }
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _salvarPerfil() async {
    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final valSessao = double.tryParse(_valorSessaoController.text) ?? 150.0;
        await Supabase.instance.client.from('psicologos').upsert({
          'id': user.id,
          'crp': _crpController.text.trim(),
          'foto_url': _fotoUrl,
          'valor_padrao': valSessao,
          'duracao_sessao_padrao': _duracaoSessao,
          'updated_at': DateTime.now().toIso8601String(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configurações salvas com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _fazerUploadFotoGaleria() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final fileBytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final filePath = '$userId/avatar.$fileExt';

      await Supabase.instance.client.storage
          .from('perfis')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$fileExt',
            ),
          );

      final publicUrl = Supabase.instance.client.storage
          .from('perfis')
          .getPublicUrl(filePath);

      setState(() {
        _fotoUrl = publicUrl;
      });
      await _salvarPerfil();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no upload da foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _alterarFotoPerfil() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da Galeria (Upload Supabase)'),
              onTap: () {
                Navigator.of(ctx).pop();
                _fazerUploadFotoGaleria();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_outlined),
              title: const Text('Inserir Link / URL da Foto'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final controller = TextEditingController(text: _fotoUrl ?? '');
                final novaUrl = await showDialog<String>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('URL da Foto de Perfil'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'URL da Imagem',
                        prefixIcon: Icon(Icons.link),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(dialogCtx).pop(controller.text.trim()),
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                );

                if (novaUrl != null) {
                  setState(() {
                    _fotoUrl = novaUrl.isEmpty ? null : novaUrl;
                  });
                  _salvarPerfil();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _abrirCartaoVisita() {
    final user = Supabase.instance.client.auth.currentUser;
    final nome = user?.userMetadata?['nome'] ?? 'Psicólogo(a)';
    final email = user?.email ?? 'contato@contorno.app';
    final crp = _crpController.text;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A345C), Color(0xFF1E1A33)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFE4B363),
                      backgroundImage:
                          (_fotoUrl != null && _fotoUrl!.isNotEmpty)
                          ? NetworkImage(_fotoUrl!) as ImageProvider
                          : null,
                      child: (_fotoUrl == null || _fotoUrl!.isEmpty)
                          ? Text(
                              nome.isNotEmpty ? nome[0].toUpperCase() : 'P',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3A345C),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      nome,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Psicologia Clínica',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CRP: $crp',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE4B363),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Feito com Contorno Psi',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3A345C),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4B363),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _compartilharCartao,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _compartilharCartao() async {
    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/cartao_apresentacao.png',
        ).create();
        await file.writeAsBytes(imageBytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Confira meu Cartão de Apresentação Profissional!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar cartão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _redefinirSenha() async {
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email != null) {
      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('E-mail de redefinição enviado para $email'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao solicitar redefinição: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _abrirUrl(String urlStr) async {
    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir a URL.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmarExclusaoConta() async {
    final seguro = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conta Permanentemente?'),
        content: const Text(
          'Esta ação é irreversível. Todos os seus pacientes, agendamentos, '
          'evoluções clínicas e recibos serão excluídos permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (seguro == true) {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await Supabase.instance.client
              .from('pacientes')
              .delete()
              .eq('psicologo_id', userId);
          await Supabase.instance.client
              .from('psicologos')
              .delete()
              .eq('id', userId);
        }
        if (mounted) {
          context.read<AuthCubit>().logout();
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir conta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'psicologo@contorno.app';
    final nome = user?.userMetadata?['nome'] ?? 'Psicólogo(a)';

    final cardBgColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final secondaryTextColor = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF4F3F8),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // 1. HEADER DO PERFIL (Com suporte a foto e toque para alterar)
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _alterarFotoPerfil,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          backgroundImage:
                              (_fotoUrl != null && _fotoUrl!.isNotEmpty)
                              ? NetworkImage(_fotoUrl!) as ImageProvider
                              : null,
                          child: (_fotoUrl == null || _fotoUrl!.isEmpty)
                              ? Text(
                                  nome.isNotEmpty ? nome[0].toUpperCase() : 'P',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  nome,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(fontSize: 13, color: secondaryTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 2. DADOS PROFISSIONAIS & CARTÃO DE APRESENTAÇÃO
          _buildGroupHeader('Dados Profissionais', secondaryTextColor),
          Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _crpController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Número do CRP',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      helperText: 'Exibido nos recibos e prontuários PDF',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _abrirCartaoVisita,
                      icon: const Icon(Icons.badge, size: 18),
                      label: const Text('Gerar Cartão de Apresentação'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. CONFIGURAÇÕES DE ATENDIMENTO
          _buildGroupHeader('Configurações de Atendimento', secondaryTextColor),
          Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valorSessaoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Valor Padrão (R\$)',
                      prefixIcon: const Icon(Icons.attach_money, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue:
                        ['50 minutos', '60 minutos'].contains(_duracaoSessao)
                        ? _duracaoSessao
                        : '50 minutos',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Duração',
                      prefixIcon: const Icon(Icons.timer_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '50 minutos',
                        child: Text('50 min'),
                      ),
                      DropdownMenuItem(
                        value: '60 minutos',
                        child: Text('60 min'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _duracaoSessao = val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // // 4. PREFERÊNCIAS DO APP
          // _buildGroupHeader('Preferências', secondaryTextColor),
          // Container(
          //   decoration: BoxDecoration(
          //     color: cardBgColor,
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: borderColor),
          //   ),
          //   child: SwitchListTile(
          //     secondary: const Icon(Icons.dark_mode_outlined, size: 20),
          //     title: const Text(
          //       'Modo Escuro (Dark Mode)',
          //       style: TextStyle(fontSize: 14),
          //     ),
          //     value: isDark,
          //     onChanged: (val) {
          //       themeController.toggleTheme(val);
          //     },
          //   ),
          // ),
          // const SizedBox(height: 20),

          // 5. SUPORTE E LEGAL
          _buildGroupHeader('Suporte e Legal', secondaryTextColor),
          Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset_outlined, size: 20),
                  title: const Text(
                    'Redefinir Senha',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: _redefinirSenha,
                ),
                Divider(height: 1, color: borderColor),
                ListTile(
                  leading: const Icon(Icons.description_outlined, size: 20),
                  title: const Text(
                    'Termos de Uso',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _abrirUrl(
                    'https://politicas-contorno.vercel.app/termos.html',
                  ),
                ),
                Divider(height: 1, color: borderColor),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, size: 20),
                  title: const Text(
                    'Política de Privacidade',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () =>
                      _abrirUrl('https://politicas-contorno.vercel.app/'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // BOTÃO ÚNICO DE SALVAR CONFIGURAÇÕES
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _salvarPerfil,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Salvar Alterações',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 28),

          // 6. ZONA DE CONTA
          _buildGroupHeader('Zona de Conta', Colors.red.shade400),
          Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.grey,
                    size: 20,
                  ),
                  title: const Text(
                    'Sair do Aplicativo',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    context.read<AuthCubit>().logout();
                    context.go('/login');
                  },
                ),
                Divider(height: 1, color: borderColor),
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 20,
                  ),
                  title: const Text(
                    'Excluir Minha Conta',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  onTap: _confirmarExclusaoConta,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}
