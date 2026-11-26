/// Representasi state UI yang seragam di seluruh ViewModel aplikasi.
enum ViewState {
  /// State awal sebelum aksi/request dijalankan.
  initial,

  /// Request HTTP sedang berjalan.
  loading,

  /// Data berhasil dimuat dan tersedia untuk ditampilkan.
  loaded,

  /// Request berhasil atau state lokal valid, namun data kosong.
  empty,

  /// Terjadi kegagalan jaringan, timeout, atau kesalahan parsing API.
  error,
}
