import 'package:equatable/equatable.dart';

abstract class MailState extends Equatable {
  const MailState();
}

class MailInitialState extends MailState {
  @override
  List<Object?> get props => [];
}

class MailSendingState extends MailState {
  @override
  List<Object?> get props => [];
}

class MailSentSuccessState extends MailState {
  @override
  List<Object?> get props => [];
}


class MailSentFailureState extends MailState {
  final String error;
  const MailSentFailureState(this.error);

    @override
  List<Object?> get props => [error];
}