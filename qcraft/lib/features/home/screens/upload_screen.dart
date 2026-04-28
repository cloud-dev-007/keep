import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/features/home/widgets/upload_document_list.dart';

import '../../../injection_container.dart';
import '../bloc/upload_bloc.dart';
import '../bloc/upload_state.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<UploadBloc>.value(
      value: sl<UploadBloc>(),
      child: BlocBuilder<UploadBloc, UploadState>(
        buildWhen: (stateA, stateB) {
          if (stateB is RetrievedUploadedDocument) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          return UploadDocumentList(
            documents: state.documents ?? [],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
