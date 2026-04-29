enum UmlVisibility { public, private, protected }

String visibilityToString(UmlVisibility v) {
  switch (v) {
    case UmlVisibility.public:
      return '+';
    case UmlVisibility.private:
      return '-';
    case UmlVisibility.protected:
      return '#';
  }
}
