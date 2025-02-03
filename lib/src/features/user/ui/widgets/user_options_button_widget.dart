import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class UserOptionsButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String userName;
  final ExtendedUser user;

  const UserOptionsButton({
    Key? key,
    required this.onEdit,
    required this.onDelete,
    required this.userName,
    required this.user,
  }) : super(key: key);

  Future<void> _generatePdf(BuildContext context) async {
    try {
      final userController =
          Provider.of<UserController>(context, listen: false);
      final pdfFile = await userController.generateUserPdf(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('PDF generated successfully! Saved at: ${pdfFile.path}')),
      );

      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Sharing the client profile PDF for ${user.name}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating or sharing PDF: $e')),
      );
      print('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        } else if (value == 'generate_pdf') {
          _generatePdf(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
        const PopupMenuItem<String>(
          value: 'generate_pdf',
          child: Text('Generate PDF'),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
