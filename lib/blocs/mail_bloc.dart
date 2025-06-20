import 'dart:async';
import 'dart:io';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mail_sending_app/blocs/mail_event.dart';
import 'package:mail_sending_app/blocs/mail_states.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailBloc extends Bloc<MailEvent,MailState>{
  MailBloc() : super(MailInitialState()) {
    on<SendEmailEvent>(_onSendMail);
  }

  FutureOr<void> _onSendMail(SendEmailEvent event, Emitter<MailState> emit) async {
    emit(MailSendingState());

    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      username: dotenv.env['EMAIL_USERNAME'] ?? '',
      password: dotenv.env['EMAIL_PASSWORD'] ?? '',
      port: 587,
      ignoreBadCertificate: false,
    );

    final message = Message()
      ..from = Address(dotenv.env['EMAIL_USERNAME'] ?? '')
      ..recipients.add(event.recipient)
      ..subject = event.subject
      ..text = event.body;

    log('Sending email...To: ${event.recipient} Subject: ${event.subject} Body: ${event.body} Attachment: ${event.attachmentPath ?? "No attachment"}');

    if (event.attachmentPath != null) {
      message.attachments.add(FileAttachment(File(event.attachmentPath!)));
    }

    try {
      await send(message, smtpServer);
      log('Email sent successfully!');
      emit(MailSentSuccessState());
    } catch (e, stackTrace) {
      log('❌ Failed to send email');
      log('Error: $e');
      log('StackTrace: $stackTrace'); // ← this line shows detailed error trace
      emit(MailSentFailureState(e.toString()));
    }

  }
}