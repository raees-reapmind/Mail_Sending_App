import 'package:equatable/equatable.dart';

abstract class MailEvent extends Equatable {
  const MailEvent();
}

class SendEmailEvent extends MailEvent {
  final String subject;
  final String body;
  final String recipient;
  final String? attachmentPath;

  const SendEmailEvent({
    required this.subject,
    required this.body,
    required this.recipient,
    this.attachmentPath,
  });

  @override
  List<Object?> get props => [subject, body, recipient, attachmentPath];

}