import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fe/src/data/model/model.dart';
import 'package:fe/src/data/source/source.dart';
import 'package:fe/src/shared/constants/constants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'controller.freezed.dart';
part 'controller.g.dart';

part 'auth/auth_controller.dart';
part 'auth/auth_state.dart';
part 'error/error_controller.dart';
part 'error/error_state.dart';
part 'news/news_controller.dart';
part 'news/news_state.dart';
