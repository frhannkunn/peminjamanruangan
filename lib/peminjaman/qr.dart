import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart'; 
import 'peminjaman.dart';

class QrScreen extends StatefulWidget {
  final PeminjamanData peminjaman;

  const QrScreen({super.key, required this.peminjaman});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Color _getStatusColor(String statusText) {
    if (statusText == 'Disetujui') return Colors.green;
    if (statusText == 'Ditolak' || statusText == 'Expired') return Colors.red;
    return const Color(0xFFF59B17);
  }

  // --- FUNGSI SIMPAN GAMBAR BARU (MENGGUNAKAN GAL) ---
  Future<void> _saveQrToGallery() async {
    if (!await Gal.hasAccess()) {
      await Gal.requestAccess();
    }

    // 2. Capture Gambar
    final Uint8List? image = await _screenshotController.capture();

    if (image != null) {
      try {
        await Gal.putImageBytes(image, name: "QR_Peminjaman_${widget.peminjaman.id}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("QR Code berhasil disimpan ke Galeri! ✅"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on GalException catch (e) {
        // Error handling khusus Gal
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menyimpan: ${e.type.message}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text("Terjadi kesalahan: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengambil gambar.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String waktuPinjam =
        "${DateFormat('dd MMMM yyyy').format(widget.peminjaman.tanggalPinjam)} | ${widget.peminjaman.jamMulai} - ${widget.peminjaman.jamSelesai}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "QR CODE",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(4.0),
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey.shade400,
                  strokeWidth: 2,
                  dashPattern: const [8, 4],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: QrImageView(
                          // Ganti IP sesuai laptop Anda
                          data: "http://127.0.0.1:8000/loan-check/${widget.peminjaman.id}",
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildQrInfoRow("ID Peminjam:", widget.peminjaman.id),
                      _buildQrInfoRow("Peminjam:", widget.peminjaman.namaPengaju),
                      _buildQrInfoRow("Waktu Pinjam:", waktuPinjam),
                      _buildQrInfoRow("Ruangan:", widget.peminjaman.ruangan),
                      _buildQrInfoRow("Jenis Kegiatan:", widget.peminjaman.jenisKegiatan),
                      if (widget.peminjaman.jenisKegiatan == 'Lainnya' && 
                      widget.peminjaman.activityOther != null &&
                      widget.peminjaman.activityOther != '-' &&
                      widget.peminjaman.activityOther!.isNotEmpty) 
                      _buildQrInfoRow("Kegiatan (Lainnya)", widget.peminjaman.activityOther!),
                      _buildQrInfoRow("Nama Kegiatan:", widget.peminjaman.namaKegiatan),
                      const Divider(height: 32),
                      Text(
                        "Persetujuan PIC dan Penanggung Jawab",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildQrInfoRow("Penanggung Jawab:", widget.peminjaman.penanggungJawab),
                      _buildQrInfoRow("Persetujuan Penanggung Jawab:", widget.peminjaman.statusPjText, isStatus: true),
                      _buildQrInfoRow("PIC Ruangan:", widget.peminjaman.namaPic),
                      _buildQrInfoRow("Persetujuan PIC Ruangan:", widget.peminjaman.statusPicText, isStatus: true),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Silakan Unduh atau Screenshot QR Code ini sebagai Bukti Peminjaman.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveQrToGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B4AF5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Unduh",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Kembali",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQrInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: isStatus
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        value,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(value),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}