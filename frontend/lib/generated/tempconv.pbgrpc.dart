//
//  Generated code. Do not modify.
//

// ignore_for_file: annotate_overrides, constant_identifier_names, library_prefixes, non_constant_identifier_names, prefer_final_fields, unused_import, use_super_parameters

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;

import 'tempconv.pb.dart' as $0;

export 'tempconv.pb.dart';

class TempConverterClient extends $grpc.Client {
  TempConverterClient(
    $grpc.ClientChannel channel, {
    $grpc.CallOptions? options,
    $core.Iterable<$grpc.ClientInterceptor>? interceptors,
  }) : super(channel, options: options, interceptors: interceptors);

  static final _$convert =
      $grpc.ClientMethod<$0.ConvertRequest, $0.ConvertResponse>(
        '/tempconv.v1.TempConverter/Convert',
        ($0.ConvertRequest value) => value.writeToBuffer(),
        ($core.List<$core.int> value) => $0.ConvertResponse.fromBuffer(value),
      );
  static final _$health =
      $grpc.ClientMethod<$0.HealthRequest, $0.HealthResponse>(
        '/tempconv.v1.TempConverter/Health',
        ($0.HealthRequest value) => value.writeToBuffer(),
        ($core.List<$core.int> value) => $0.HealthResponse.fromBuffer(value),
      );

  $grpc.ResponseFuture<$0.ConvertResponse> convert(
    $0.ConvertRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$convert, request, options: options);
  }

  $grpc.ResponseFuture<$0.HealthResponse> health(
    $0.HealthRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$health, request, options: options);
  }
}

abstract class TempConverterServiceBase extends $grpc.Service {
  TempConverterServiceBase() {
    $addMethod(
      $grpc.ServiceMethod<$0.ConvertRequest, $0.ConvertResponse>(
        'Convert',
        convert_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConvertRequest.fromBuffer(value),
        ($0.ConvertResponse value) => value.writeToBuffer(),
      ),
    );
    $addMethod(
      $grpc.ServiceMethod<$0.HealthRequest, $0.HealthResponse>(
        'Health',
        health_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HealthRequest.fromBuffer(value),
        ($0.HealthResponse value) => value.writeToBuffer(),
      ),
    );
  }

  $async.Future<$0.ConvertResponse> convert_Pre(
    $grpc.ServiceCall call,
    $async.Future<$0.ConvertRequest> request,
  ) async {
    return convert(call, await request);
  }

  $async.Future<$0.HealthResponse> health_Pre(
    $grpc.ServiceCall call,
    $async.Future<$0.HealthRequest> request,
  ) async {
    return health(call, await request);
  }

  $async.Future<$0.ConvertResponse> convert(
    $grpc.ServiceCall call,
    $0.ConvertRequest request,
  );
  $async.Future<$0.HealthResponse> health(
    $grpc.ServiceCall call,
    $0.HealthRequest request,
  );
}
