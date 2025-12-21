String getListingLabel(String value) {
  final v = value.toLowerCase();

  if (v == "sell" || v == "jual" || v == "beli" || v == "buy") {
    return "Beli";
  }

  if (v == "rent" || v == "sewa") {
    return "Sewa";
  }

  return "-";
}
