# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: poketwo/database/v1/service.proto
"""Generated protocol buffer code."""
from google.protobuf import descriptor as _descriptor
from google.protobuf import descriptor_pool as _descriptor_pool
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import symbol_database as _symbol_database
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


from poketwo.database.v1 import models_pb2 as poketwo_dot_database_dot_v1_dot_models__pb2


DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n!poketwo/database/v1/service.proto\x12\x13poketwo.database.v1\x1a poketwo/database/v1/models.proto\":\n\x11GetSpeciesRequest\x12\x0c\n\x02id\x18\x01 \x01(\x05H\x00\x12\x0e\n\x04name\x18\x02 \x01(\tH\x00\x42\x07\n\x05query\"C\n\x12GetSpeciesResponse\x12-\n\x07species\x18\x01 \x01(\x0b\x32\x1c.poketwo.database.v1.Species\":\n\x11GetVariantRequest\x12\x0c\n\x02id\x18\x01 \x01(\x05H\x00\x12\x0e\n\x04name\x18\x02 \x01(\tH\x00\x42\x07\n\x05query\"C\n\x12GetVariantResponse\x12-\n\x07variant\x18\x01 \x01(\x0b\x32\x1c.poketwo.database.v1.Variant2\xc8\x01\n\x08\x44\x61tabase\x12]\n\nGetSpecies\x12&.poketwo.database.v1.GetSpeciesRequest\x1a\'.poketwo.database.v1.GetSpeciesResponse\x12]\n\nGetVariant\x12&.poketwo.database.v1.GetVariantRequest\x1a\'.poketwo.database.v1.GetVariantResponseb\x06proto3')



_GETSPECIESREQUEST = DESCRIPTOR.message_types_by_name['GetSpeciesRequest']
_GETSPECIESRESPONSE = DESCRIPTOR.message_types_by_name['GetSpeciesResponse']
_GETVARIANTREQUEST = DESCRIPTOR.message_types_by_name['GetVariantRequest']
_GETVARIANTRESPONSE = DESCRIPTOR.message_types_by_name['GetVariantResponse']
GetSpeciesRequest = _reflection.GeneratedProtocolMessageType('GetSpeciesRequest', (_message.Message,), {
  'DESCRIPTOR' : _GETSPECIESREQUEST,
  '__module__' : 'poketwo.database.v1.service_pb2'
  # @@protoc_insertion_point(class_scope:poketwo.database.v1.GetSpeciesRequest)
  })
_sym_db.RegisterMessage(GetSpeciesRequest)

GetSpeciesResponse = _reflection.GeneratedProtocolMessageType('GetSpeciesResponse', (_message.Message,), {
  'DESCRIPTOR' : _GETSPECIESRESPONSE,
  '__module__' : 'poketwo.database.v1.service_pb2'
  # @@protoc_insertion_point(class_scope:poketwo.database.v1.GetSpeciesResponse)
  })
_sym_db.RegisterMessage(GetSpeciesResponse)

GetVariantRequest = _reflection.GeneratedProtocolMessageType('GetVariantRequest', (_message.Message,), {
  'DESCRIPTOR' : _GETVARIANTREQUEST,
  '__module__' : 'poketwo.database.v1.service_pb2'
  # @@protoc_insertion_point(class_scope:poketwo.database.v1.GetVariantRequest)
  })
_sym_db.RegisterMessage(GetVariantRequest)

GetVariantResponse = _reflection.GeneratedProtocolMessageType('GetVariantResponse', (_message.Message,), {
  'DESCRIPTOR' : _GETVARIANTRESPONSE,
  '__module__' : 'poketwo.database.v1.service_pb2'
  # @@protoc_insertion_point(class_scope:poketwo.database.v1.GetVariantResponse)
  })
_sym_db.RegisterMessage(GetVariantResponse)

_DATABASE = DESCRIPTOR.services_by_name['Database']
if _descriptor._USE_C_DESCRIPTORS == False:

  DESCRIPTOR._options = None
  _GETSPECIESREQUEST._serialized_start=92
  _GETSPECIESREQUEST._serialized_end=150
  _GETSPECIESRESPONSE._serialized_start=152
  _GETSPECIESRESPONSE._serialized_end=219
  _GETVARIANTREQUEST._serialized_start=221
  _GETVARIANTREQUEST._serialized_end=279
  _GETVARIANTRESPONSE._serialized_start=281
  _GETVARIANTRESPONSE._serialized_end=348
  _DATABASE._serialized_start=351
  _DATABASE._serialized_end=551
# @@protoc_insertion_point(module_scope)
