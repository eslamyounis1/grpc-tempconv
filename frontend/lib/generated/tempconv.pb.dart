//
//  Generated code. Do not modify.
//

// ignore_for_file: annotate_overrides, constant_identifier_names, library_prefixes, non_constant_identifier_names, prefer_final_fields, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ConvertRequest extends $pb.GeneratedMessage {
  factory ConvertRequest({
    $core.double? value,
    $core.String? from,
    $core.String? to,
  }) {
    final result = create();
    if (value != null) {
      result.value = value;
    }
    if (from != null) {
      result.from = from;
    }
    if (to != null) {
      result.to = to;
    }
    return result;
  }
  ConvertRequest._() : super();
  factory ConvertRequest.fromBuffer(
    $core.List<$core.int> i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) => create()..mergeFromBuffer(i, r);
  factory ConvertRequest.fromJson(
    $core.String i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          _omitMessageNames ? '' : 'ConvertRequest',
          package: const $pb.PackageName(
            _omitMessageNames ? '' : 'tempconv.v1',
          ),
          createEmptyInstance: create,
        )
        ..a<$core.double>(1, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OD)
        ..aOS(2, _omitFieldNames ? '' : 'from')
        ..aOS(3, _omitFieldNames ? '' : 'to')
        ..hasRequiredFields = false;

  @$core.Deprecated(
    'Use deepCopy instead. Will be removed in next major version',
  )
  ConvertRequest clone() => ConvertRequest()..mergeFromMessage(this);
  @$core.Deprecated(
    'Use rebuild instead. Will be removed in next major version',
  )
  ConvertRequest copyWith(void Function(ConvertRequest) updates) =>
      super.copyWith((message) => updates(message as ConvertRequest))
          as ConvertRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConvertRequest create() => ConvertRequest._();
  ConvertRequest createEmptyInstance() => create();
  static $pb.PbList<ConvertRequest> createRepeated() =>
      $pb.PbList<ConvertRequest>();
  @$core.pragma('dart2js:noInline')
  static ConvertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConvertRequest>(create);
  static ConvertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($core.double v) {
    $_setDouble(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get from => $_getSZ(1);
  @$pb.TagNumber(2)
  set from($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get to => $_getSZ(2);
  @$pb.TagNumber(3)
  set to($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTo() => $_has(2);
  @$pb.TagNumber(3)
  void clearTo() => clearField(3);
}

class ConvertResponse extends $pb.GeneratedMessage {
  factory ConvertResponse({$core.double? result}) {
    final result$ = create();
    if (result != null) {
      result$.result = result;
    }
    return result$;
  }
  ConvertResponse._() : super();
  factory ConvertResponse.fromBuffer(
    $core.List<$core.int> i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) => create()..mergeFromBuffer(i, r);
  factory ConvertResponse.fromJson(
    $core.String i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          _omitMessageNames ? '' : 'ConvertResponse',
          package: const $pb.PackageName(
            _omitMessageNames ? '' : 'tempconv.v1',
          ),
          createEmptyInstance: create,
        )
        ..a<$core.double>(
          1,
          _omitFieldNames ? '' : 'result',
          $pb.PbFieldType.OD,
        )
        ..hasRequiredFields = false;

  @$core.Deprecated(
    'Use deepCopy instead. Will be removed in next major version',
  )
  ConvertResponse clone() => ConvertResponse()..mergeFromMessage(this);
  @$core.Deprecated(
    'Use rebuild instead. Will be removed in next major version',
  )
  ConvertResponse copyWith(void Function(ConvertResponse) updates) =>
      super.copyWith((message) => updates(message as ConvertResponse))
          as ConvertResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConvertResponse create() => ConvertResponse._();
  ConvertResponse createEmptyInstance() => create();
  static $pb.PbList<ConvertResponse> createRepeated() =>
      $pb.PbList<ConvertResponse>();
  @$core.pragma('dart2js:noInline')
  static ConvertResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConvertResponse>(create);
  static ConvertResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get result => $_getN(0);
  @$pb.TagNumber(1)
  set result($core.double v) {
    $_setDouble(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => clearField(1);
}

class HealthRequest extends $pb.GeneratedMessage {
  factory HealthRequest() => create();
  HealthRequest._() : super();
  factory HealthRequest.fromBuffer(
    $core.List<$core.int> i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) => create()..mergeFromBuffer(i, r);
  factory HealthRequest.fromJson(
    $core.String i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    _omitMessageNames ? '' : 'HealthRequest',
    package: const $pb.PackageName(_omitMessageNames ? '' : 'tempconv.v1'),
    createEmptyInstance: create,
  )..hasRequiredFields = false;

  @$core.Deprecated(
    'Use deepCopy instead. Will be removed in next major version',
  )
  HealthRequest clone() => HealthRequest()..mergeFromMessage(this);
  @$core.Deprecated(
    'Use rebuild instead. Will be removed in next major version',
  )
  HealthRequest copyWith(void Function(HealthRequest) updates) =>
      super.copyWith((message) => updates(message as HealthRequest))
          as HealthRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HealthRequest create() => HealthRequest._();
  HealthRequest createEmptyInstance() => create();
  static $pb.PbList<HealthRequest> createRepeated() =>
      $pb.PbList<HealthRequest>();
  @$core.pragma('dart2js:noInline')
  static HealthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HealthRequest>(create);
  static HealthRequest? _defaultInstance;
}

class HealthResponse extends $pb.GeneratedMessage {
  factory HealthResponse({$core.String? status}) {
    final result = create();
    if (status != null) {
      result.status = status;
    }
    return result;
  }
  HealthResponse._() : super();
  factory HealthResponse.fromBuffer(
    $core.List<$core.int> i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) => create()..mergeFromBuffer(i, r);
  factory HealthResponse.fromJson(
    $core.String i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          _omitMessageNames ? '' : 'HealthResponse',
          package: const $pb.PackageName(
            _omitMessageNames ? '' : 'tempconv.v1',
          ),
          createEmptyInstance: create,
        )
        ..aOS(1, _omitFieldNames ? '' : 'status')
        ..hasRequiredFields = false;

  @$core.Deprecated(
    'Use deepCopy instead. Will be removed in next major version',
  )
  HealthResponse clone() => HealthResponse()..mergeFromMessage(this);
  @$core.Deprecated(
    'Use rebuild instead. Will be removed in next major version',
  )
  HealthResponse copyWith(void Function(HealthResponse) updates) =>
      super.copyWith((message) => updates(message as HealthResponse))
          as HealthResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HealthResponse create() => HealthResponse._();
  HealthResponse createEmptyInstance() => create();
  static $pb.PbList<HealthResponse> createRepeated() =>
      $pb.PbList<HealthResponse>();
  @$core.pragma('dart2js:noInline')
  static HealthResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HealthResponse>(create);
  static HealthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => clearField(1);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment(
  'protobuf.omit_message_names',
);
