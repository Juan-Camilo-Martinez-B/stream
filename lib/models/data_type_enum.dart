enum DataType { 
  stringType, 
  intType, 
  doubleType, 
  boolType, 
  dateTimeType, 
  listType, 
  voidType,
  custom 
}

String dataTypeToString(DataType type) {
  switch (type) {
    case DataType.stringType: return 'String';
    case DataType.intType: return 'int';
    case DataType.doubleType: return 'double';
    case DataType.boolType: return 'bool';
    case DataType.dateTimeType: return 'DateTime';
    case DataType.listType: return 'List';
    case DataType.voidType: return 'void';
    case DataType.custom: return 'Custom';
  }
}
