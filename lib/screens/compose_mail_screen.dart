import 'dart:io';

import '/utils/barrel.dart';

class ComposeMailScreen extends StatefulWidget {
  const ComposeMailScreen({Key? key}) : super(key: key);

  @override
  State<ComposeMailScreen> createState() => _ComposeMailScreenState();
}

class _ComposeMailScreenState extends State<ComposeMailScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _subject, _body, _recipient, _attachmentPath;
  List<String> _attachmentPaths = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compose Email')),
      body: BlocConsumer<MailBloc, MailState>(
        listener: (context, state) {
          if (state is MailSentSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email sent successfully')),
            );
          } else if (state is MailSentFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Recipient Email'),
                    onSaved: (value) => _recipient = value,
                    validator: (value) {
                      if (value == null || !value.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Subject'),
                    onSaved: (value) => _subject = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Body'),
                    onSaved: (value) => _body = value,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        setState(() {
                          _attachmentPath = result.files.single.path!;
                        });
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Pick Attachment'),
                  ),
                 if (_attachmentPath != null && File(_attachmentPath!).existsSync())
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: _buildAttachmentPreview(_attachmentPath!),
                    ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final form = _formKey.currentState!;
                      if (form.validate()) {
                        form.save();
                        context.read<MailBloc>().add(
                              SendEmailEvent(
                                subject: _subject ?? '',
                                body: _body ?? '',
                                recipient: _recipient!,
                                attachmentPath: _attachmentPath,
                              ),
                            );
                      }
                    },
                    child: state is MailSendingState
                        ? const CircularProgressIndicator()
                        : const Text('Send'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildAttachmentPreview(String path) {
  final extension = path.split('.').last.toLowerCase();

  final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);

  if (isImage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(path),
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      ),
    );
  } else {
    return Row(
      children: [
        const Icon(Icons.insert_drive_file, size: 32),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            path.split('/').last,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

}
