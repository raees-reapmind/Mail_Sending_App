import 'dart:io';

import '/utils/barrel.dart';

class ComposeMailScreen extends StatefulWidget {
  const ComposeMailScreen({Key? key}) : super(key: key);

  @override
  State<ComposeMailScreen> createState() => _ComposeMailScreenState();
}

class _ComposeMailScreenState extends State<ComposeMailScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _subject, _body, _recipient;
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

            _formKey.currentState?.reset();
            setState(() {
              _attachmentPaths.clear();
              _subject = null;
              _body = null;
              _recipient = null;
              _attachmentPaths = [];
            });
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
                    decoration:
                        const InputDecoration(labelText: 'Recipient Email'),
                    onSaved: (value) => _recipient = value,
                    validator: (value) {
                      if (value == null || !value.contains('@'))
                        return 'Invalid email';
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
                      final result = await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                      );
                      if (result != null) {
                        setState(() {
                          _attachmentPaths =
                              result.paths.whereType<String>().toList();
                        });
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Pick Attachments'),
                  ),
                  if (_attachmentPaths.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _attachmentPaths.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final path = _attachmentPaths[index];
                          return Stack(
                            children: [
                              _buildAttachmentPreview(path),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _attachmentPaths.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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
                                attachmentPaths: _attachmentPaths,
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
    final isImage =
        ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);

    if (isImage && File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(path),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insert_drive_file, size: 32),
            Text(
              path.split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      );
    }
  }
}
